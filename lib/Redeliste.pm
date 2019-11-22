package Redeliste;
use Mojo::Base 'Mojolicious', -signatures;

use Redeliste::Model;
use Mojo::JSON qw(true false);

sub init ($self) {

    # Load configuration from redeliste.conf
    $self->plugin('Config');
    $self->secrets([$self->config('secret')]);

    # In-memory "database"
    $self->helper(model => sub { state $model = Redeliste::Model->new });

    # Full state dump for clients (pre-JSON)
    $self->helper(state_dump => sub ($c) {
        my $session = $c->stash('session');
        return {
            session      => $session->to_hash,
            nextSpeakers => $session->get_next_speaker_ids,
            listOpen     => $session->list_open ? true : false,
            personId     => $c->stash('person_id'),
            wsURL        => $c->url_for('sync')->to_abs->to_string,
        };
    });

    # Send state to all clients for the given session
    $self->helper(broadcast => sub ($c) {
        my $persons = $c->stash('session')->persons;
        my $conns   = $persons->map('tx')->grep(sub {defined});
        $conns->each(sub {$_->send({json => $c->state_dump})});
    });

    # Close all connections
    $self->helper(broadclose => sub ($c) {
        my $persons = $c->stash('session')->persons;
        my $conns   = $persons->map('tx')->grep(sub {defined});
        $conns->each('finish');
    });
}

sub startup ($self) {

	# Load config and add helpers
	$self->init;

	# Prepare routes
	my $r = $self->routes;

	# Static pages
	$r->get('/')->name('choose');
	$r->get("/$_") for qw(start join bye);

    # Create a session and generate a token for session members
    $r->post('/start' => sub ($c) {

        # Init
        my $session = $c->model->add_session(name => $c->param('name'));
        my $chair   = $session->add_person(
            name => $c->param('pname') // ('Anonymous' . int(rand 10_000)),
            star => $c->param('sex') ne 'male'
        );

        # Store and work with it
        $c->session(
            token       => $session->token,
            person_id   => $chair->id,
            role        => 'chair',
        )->redirect_to('host');
    });

    # Join a session
    $r->post('/join' => sub ($c) {

        # Lookup session
        my $session = $c->model->sessions->{$c->param('token')};
        return $c->reply->not_found unless defined $session;

        # Inject data
        my $person = $session->add_person(
            name => $c->param('name') // ('Anonymous' . int(rand 10_000)),
            star => $c->param('sex') ne 'male',
        );

        # Store and work with it
        $c->session(
            token       => $session->token,
            person_id   => $person->id,
            role        => 'user'
        )->redirect_to('attend');
    });

    # A session has been joined, retrieve its data
    my $s = $r->under(sub ($c) {

        # Session found?
        my $session = $c->model->sessions->{$c->session('token')};
        return $c->reply->not_found unless defined $session;

        # Si!
        $c->stash(
            session     => $session,
            person_id   => $c->session('person_id'),
            role        => $c->session('role'),
        );
        return 1;
    });

    # Host a session
    $s->get('/host' => sub ($c) {
        return $c->reply->not_found unless $c->session('role') eq 'chair';
        $c->render(template => 'redeliste', role => 'chair');
    });

    # Attend a session
    $s->get('/attend' => sub ($c) {
        $c->render(template => 'redeliste', role => 'user');
    });
}

1;
__END__

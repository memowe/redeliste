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
    $r->post('/start')->to('entrance#start_session');

    # Join a session
    $r->post('/join')->to('entrance#join_session');

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

    # Read state data dump as JSON/text
    $s->get('/data' => [format => 'json'] => sub ($c) {
        $c->render(json => $c->state_dump);
    });
    $s->get('/data' => [format => 'txt'] => sub ($c) {
        $c->render(text => $c->dumper($c->state_dump));
    });

    # Push synchronization
    $s->websocket('/sync' => sub ($c) {

        # Keep connection alive for at least one day
        $c->inactivity_timeout($self->config('timeout'));

        # Lookup corresponding data
        my $session = $c->stash('session');
        my $person  = $session->persons->[$c->stash('person_id')];
        return $c->reply->not_found unless $person;

        # Store connection
        $person->tx($c->tx)->active(1);

        # React on a message
        $c->on(message => sub ($self, $message) {

            # Close the whole session
            if ($message eq 'CLOSESESSION') {
                delete $c->model->sessions->{$session->{token}};
                $c->broadclose;
                return;
            }

            # Dispatch messages
            for ($message) {
                /^RQSP$/        && $session->add_request($person);
                /^NEXT$/        && $session->call_next_speaker;
                /^CLOSELIST$/   && $session->list_open('');
                /^OPENLIST$/    && $session->list_open(1);
                /^NEXTITEM$/    && $session->next_item;
                $c->broadcast;
            }
        });

        # React on a client leaving
        $c->on(finish => sub {

            # Chair: close everything
            if ($c->stash('role') eq 'chair') {
                delete $c->model->sessions->{$session->{token}};
                $c->broadclose;
            }

            # User: just let them know
            else {
                $person->tx(undef)->active(0);
                $c->broadcast;
            }
        });

        # Send updated session data to all clients
        $c->broadcast;
    });

    # Reset local storage
    $s->get('/reset' => sub ($c) {
        $c->session({})->render(text => 'OK');
    });
}

1;
__END__

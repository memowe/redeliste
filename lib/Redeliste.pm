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
    my $session = $r->under('/')->to('session#test_logged_in');

    # Host a session
    $session->get('/host')->to('session#host');

    # Attend a session
    $session->get('/attend')->to('session#attend');

    # Read state data dump
    $session->get('/data' => [format => 'json'])->to('session#data_json');
    $session->get('/data' => [format => 'txt' ])->to('session#data_text');

    # Push synchronization
    $session->websocket('/sync')->to('push#sync');

    # Reset local storage TODO
    $session->get('/reset' => sub ($c) {
        $c->session({})->render(text => 'OK');
    });
}

1;
__END__

package Redeliste;
use Mojo::Base 'Mojolicious', -signatures;

use Redeliste::Model;
use Mojo::JSON qw(true false);

sub startup ($self) {

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

1;
__END__

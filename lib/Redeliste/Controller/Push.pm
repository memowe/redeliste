package Redeliste::Controller::Push;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub sync ($c) {

    # Keep connection alive for at least one day
    $c->inactivity_timeout($c->config('timeout'));

    # Lookup corresponding data
    my $session = $c->stash('session');
    my $person  = $session->persons->[$c->stash('person_id')];
    return $c->reply->not_found unless $person;

    # Store connection
    $person->tx($c->tx)->active(1);

    # React on a message
    $c->on(message => sub ($c, $message) {

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
            /^NEXT (\d+)$/  && $session->call_next_speaker($1);
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
}

1;
__END__

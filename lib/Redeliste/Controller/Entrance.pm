package Redeliste::Controller::Entrance;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub start_session ($c) {

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
}

sub join_session ($c) {

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
}

1;
__END__

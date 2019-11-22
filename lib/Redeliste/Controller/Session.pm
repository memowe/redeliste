package Redeliste::Controller::Session;
use Mojo::Base 'Mojolicious::Controller', -signatures;

sub test_logged_in ($c) {

    # Session found?
    my $session = $c->model->sessions->{$c->session('token')};
    $c->reply->not_found and return unless defined $session;

    # Si!
    $c->stash(
        session     => $session,
        person_id   => $c->session('person_id'),
        role        => $c->session('role'),
    );
    return 1;
}

sub host ($c) {
    return $c->reply->not_found unless $c->session('role') eq 'chair';
    $c->render(template => 'redeliste', role => 'chair');
}

sub attend ($c) {
    $c->render(template => 'redeliste', role => 'user');
}

sub data_json ($c) {
    $c->render(json => $c->state_dump);
}

sub data_text ($c) {
    $c->render(text => $c->dumper($c->state_dump));
}

1;
__END__

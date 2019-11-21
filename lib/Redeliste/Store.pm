package Redeliste::Store;
use Mojo::Base -base, -signatures;

use Redeliste::Session;

has sessions => sub { {} };

sub add_session ($self, @args) {
    my $token   = $self->_generate_token;
    my $session = Redeliste::Session->new(token => $token, @args);
    $self->sessions->{$token} = $session;
    return $session;
}

sub _generate_token ($self) {

    # Generate token with 5 characters
    my @chars = ('A'..'Z', 1 .. 9);
    my $token = join '' => map $chars[rand @chars] => 1 .. 5;

    # Done, if doesn't exist
    return $token unless exists $self->sessions->{$token};
    return $self->_generate_token;
}

1;
__END__

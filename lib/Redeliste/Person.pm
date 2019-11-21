package Redeliste::Person;
use Mojo::Base -base, -signatures;

has id      => sub { die "ID attribute required!\n" };
has name    => 'Anonymous';
has active  => '';
has spoken  => 0;
has star    => '';

sub to_hash ($self) {
    return { map {$_ => $self->$_} qw(id name active spoken star) };
}

1;
__END__

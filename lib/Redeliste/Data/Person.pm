package Redeliste::Data::Person;
use Mojo::Base -base, -signatures;

has id      => sub { die "ID attribute required!\n" };
has name    => 'Anonymous';
has active  => '';
has spoken  => 0;
has star    => '';
has 'tx';

sub spoke ($self) {
    $self->spoken($self->spoken + 1);
    return $self;
}

sub to_hash ($self) {
    return { map {$_ => $self->$_} qw(id name active spoken star) };
}

1;
__END__

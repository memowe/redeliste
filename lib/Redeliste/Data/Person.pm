package Redeliste::Data::Person;
use Mojo::Base -base, -signatures;

has id          => sub { die "ID attribute required!\n" };
has name        => 'Anonymous';
has active      => '';
has spoken      => 0;
has spoken_item => 0;
has star        => '';
has talking     => '';
has 'tx';

sub spoke ($self) {
    $self->talking(1);
    $self->$_($self->$_ + 1) for qw(spoken spoken_item);
    return $self;
}

sub next_item ($self) {
    $self->spoken_item(0);
    return $self;
}

sub to_hash ($self) {
    return {
        map {$_ => $self->$_}
        qw(id name active spoken spoken_item star talking)
    };
}

1;
__END__

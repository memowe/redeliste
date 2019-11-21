package Redeliste::Session;
use Mojo::Base -base, -signatures;

use Redeliste::Person;
use Mojo::Collection;
use Scalar::Util 'blessed';

has token       => sub { die "Token attribute required!\n" };
has name        => 'Anonymous session';
has persons     => sub { Mojo::Collection->new };
has requests    => sub { Mojo::Collection->new };
has list_open   => 1;

sub add_person ($self, @args) {
    my $id = @{$self->persons};
    push @{$self->persons}, Redeliste::Person->new(id => $id, @args);
    return $self;
}

sub add_request ($self, $person) {
    push @{$self->requests}, $person->id;
    return $self;
}

sub get_request_persons ($self) {
    return $self->requests->map(sub {$self->persons->[shift]});
}

sub to_hash ($self) {
    my %hash = %$self;
    while (my ($k, $v) = each %hash) {
        $hash{$k} = $v->to_hash if blessed $v and $v->can('to_hash');
    }
    return { %$self };
}

1;
__END__

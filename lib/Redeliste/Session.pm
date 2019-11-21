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
    my $person = Redeliste::Person->new(id => $id, @args);
    push @{$self->persons}, $person;
    return $person;
}

sub add_request ($self, $person) {
    push @{$self->requests}, $person->id;
    return $self;
}

sub get_request_persons ($self) {
    return $self->requests->map(sub {$self->persons->[shift]});
}

sub to_hash ($self) {

    # Prepare hash
    my %hash = map {$_ => $self->$_}
        qw(token name persons requests list_open);

    # Handle collections
    for my $attr (keys %hash) {
        next unless ref($hash{$attr}) eq 'Mojo::Collection';
        $hash{$attr} = $hash{$attr}->map(sub {
            blessed($_) and $_->can('to_hash') ? $_->to_hash : $_
        })->to_array;
    }
    return \%hash;
}

1;
__END__

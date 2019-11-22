package Redeliste::Data::Session;
use Mojo::Base -base, -signatures;

use Redeliste::Data::Person;
use Mojo::Collection 'c';
use Scalar::Util 'blessed';

has token       => sub { die "Token attribute required!\n" };
has name        => 'Anonymous session';
has persons     => sub { c };
has requests    => sub { c };
has list_open   => 1;

sub add_person ($self, @args) {
    my $id = @{$self->persons};
    my $person = Redeliste::Data::Person->new(id => $id, @args);
    push @{$self->persons}, $person;
    return $person;
}

sub add_request ($self, $p) {
    my $id = ref($p) eq 'Redeliste::Data::Person' ? $p->id : $p;
    push @{$self->requests}, $id
        unless grep {$_ == $id} @{$self->requests};
    return $self;
}

sub get_request_persons ($self) {
    return $self->requests->map(sub {$self->persons->[shift]});
}

sub get_next_speaker_ids ($self) {
    return $self->requests; # TODO
}

sub call_next_speaker ($self, $=) {
    my $id   =  $_[1] // $self->get_next_speaker_ids->[0];
    my $reqs = $self->requests->grep(sub {$_ != $id});
    my $next = $self->persons->[$id]->spoke;
    $self->requests($reqs);
    return $next;
}

sub next_item ($self) {
    return $self->requests(c)->list_open(1);
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

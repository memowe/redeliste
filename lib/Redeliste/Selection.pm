package Redeliste::Selection;
use Mojo::Base -base, -signatures;

use Mojo::Collection 'c';

has _input      => sub { c }; # Collection of R::D::Persons
has _selection  => sub { c }; # Collection of R::D::Persons

sub add_person ($self, $person) {
    push @{$self->_input}, $person;   # Add to the queue
    $self->_select;                   # Recalculate selection
    return $self;                     # Enable chaining
}

sub _select ($self) {
    $self->_selection($self->_input); # TODO
    return $self;
}

sub get_selection ($self) {
    return $self->_selection;
}

sub get_selection_ids ($self) {
    return $self->get_selection->map('id');
}

1;
__END__

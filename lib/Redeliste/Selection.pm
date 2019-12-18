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
    $self->_select_initial_queue;
    $self->_select_first_timers_first;
    return $self;
}

sub _select_initial_queue ($self) {
    $self->_selection($self->_input);
}

sub _select_first_timers_first ($self) {

    # Split
    my $all     = $self->_selection;
    my $first   = $all->grep(sub ($p) {$p->spoken == 0});
    my $others  = $all->grep(sub ($p) {$p->spoken != 0});

    # Append others to first
    push @$first, @$others;
    $self->_selection($first);
}

sub get_selection ($self) {
    return $self->_selection;
}

sub get_selection_ids ($self) {
    return $self->get_selection->map('id');
}

1;
__END__

package Redeliste::Selection;
use Mojo::Base -base, -signatures;

use Mojo::Collection 'c';

has _input      => sub { c }; # Collection of R::D::Persons
has _selection  => sub { c }; # Collection of R::D::Persons

#----- Public interface -----

sub add_person ($self, $person) {
    push @{$self->_input}, $person;   # Add to the queue
    $self->_select;                   # Recalculate selection
    return $self;                     # Enable chaining
}

sub get_selection ($self) {
    return $self->_selection;
}

sub get_selection_ids ($self) {
    return $self->get_selection->map('id');
}

sub next ($self) {
    my $next = shift @{$self->get_selection};
    $self->_input($self->_input->grep(sub ($p) {$p ne $next}));
    return $next;
}

sub next_id ($self) {
    my $next = $self->next;
    return unless defined $next;
    return $next->id;
}

sub _select ($self) {
    my $queue = $self->_input;

    # Transformations
    $queue = $self->_first_timers_first($queue);

    # Done
    $self->_selection($queue);
}

# TODO nah - das geht nicht hintereinander

sub _first_timers_first ($self, $queue) {

    # Split
    my $first   = $queue->grep(sub ($p) {$p->spoken == 0});
    my $others  = $queue->grep(sub ($p) {$p->spoken != 0});

    # Combine
    return c(@$first, @$others);
}

sub _select_gender_balanced ($self) {
    return unless $self->_selection->size == 0;

    # Split in two lists ($these gender of first person)
    my $star    = $self->_selection->first->star;
    my $these   = $self->_selection->grep(sub ($p) {$p->star == $star});
    my $others  = $self->_selection->grep(sub ($p) {$p->star != $star});
}

1;
__END__

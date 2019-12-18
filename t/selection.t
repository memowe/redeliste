#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Redeliste::Data::Person;
use Mojo::Collection 'c';

# Helper function to create Persons with less keystrokes
sub p { Redeliste::Data::Person->new(@_) }

use_ok 'Redeliste::Selection';

subtest 'List handling' => sub {
    my $sel = Redeliste::Selection->new;

    subtest 'Empty' => sub {
        is_deeply $sel->get_selection => [], 'Empty selection';
        is_deeply $sel->get_selection_ids => [], 'Empty selection ids'
    };

    subtest 'One person' => sub {
        my $p = p(id => 42);
        $sel->add_person($p);

        my $cel = $sel->get_selection;
        is $cel->size => 1, 'Correct selection length';
        is_deeply $cel->first->to_hash => $p, 'Correct person';
        is_deeply $sel->get_selection_ids => [$p->id], 'Correct selection ids';
    };

    subtest 'Simple three person queue' => sub {
        $sel->add_person($_) for p(id => 17), p(id => 666);
        is_deeply $sel->get_selection->map('id') => [42, 17, 666],
            'Correct selection';
        is_deeply $sel->get_selection_ids => [42, 17, 666],
            'Correct selection ids';
    };
};

subtest 'First-timer' => sub {
    my $sel = Redeliste::Selection->new;

    # Add mixed regular and first-time speakers
    $sel->add_person(p(id => 1, spoken => 42));
    $sel->add_person(p(id => 2, spoken => 17));
    $sel->add_person(p(id => 3, spoken => 0));  # First-timer
    $sel->add_person(p(id => 4, spoken => 666));
    $sel->add_person(p(id => 5, spoken => 0));  # First-timer
    $sel->add_person(p(id => 6, spoken => 37));

    # First-timers should be first (their order preserved)
    is_deeply $sel->get_selection_ids => [3, 5, 1, 2, 4, 6], 'Correct selection';
};

done_testing;

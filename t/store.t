#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use_ok 'Redeliste::Store';

subtest 'Add sessions' => sub {
    my $store = Redeliste::Store->new;

    # Add
    is scalar(keys %{$store->sessions}) => 0, 'No sessions yet';
    my $session = $store->add_session(name => 'Foo Session');
    is scalar(keys %{$store->sessions}) => 1, 'One session';

    # Check
    is $session->name => 'Foo Session', 'Correct session name';
    my ($tok, $sess) = %{$store->sessions};
    is $tok => $session->token, 'Same token';
    is $sess => $session, 'Same session';
};

done_testing;

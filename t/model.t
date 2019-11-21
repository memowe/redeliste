#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;

use_ok 'Redeliste::Model';

subtest 'Add sessions' => sub {
    my $model = Redeliste::Model->new;

    # Add
    is scalar(keys %{$model->sessions}) => 0, 'No sessions yet';
    my $session = $model->add_session(name => 'Foo Session');
    is scalar(keys %{$model->sessions}) => 1, 'One session';

    # Check
    is $session->name => 'Foo Session', 'Correct session name';
    my ($tok, $sess) = %{$model->sessions};
    is $tok => $session->token, 'Same token';
    is $sess => $session, 'Same session';
};

done_testing;

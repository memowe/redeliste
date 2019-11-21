#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Redeliste::Person;

use_ok 'Redeliste::Session';

subtest 'Required attributes' => sub {
    throws_ok { Redeliste::Session->new->token }
        qr/^Token attribute required!/, 'Required token exception';
};

subtest 'Constructor' => sub {

    subtest 'Default values' => sub {
        is Redeliste::Session->new(token => 1)->name => 'Anonymous session',
            'name';
        ok Redeliste::Session->new(token => 2)->list_open, 'list_open';
    };

    subtest 'Complete data' => sub {
        my $sess = Redeliste::Session->new(
            token       => 'XNORZT',
            name        => 'Foo session',
            persons     => [42],
            requests    => [0],
            list_open   => '',
        );

        is $sess->token => 'XNORZT', 'Correct token';
        is $sess->name  => 'Foo session', 'Correct name';
        is_deeply $sess->persons  => [42], 'Correct persons';
        is_deeply $sess->requests => [0], 'Correct requests';
        ok ! $sess->list_open, 'Correct list_open';
    };
};

subtest 'Data export' => sub {
    my $data = Redeliste::Session->new(
        token       => 'XNORFZT',
        name        => 'Foo session',
        persons     => [Redeliste::Person->new(id => 42)],
        requests    => [0],
        list_open   => '',
    )->to_hash;

    is ref($data) => 'HASH', 'Correct hash reference';
    is_deeply $data => {
        token       => 'XNORFZT',
        name        => 'Foo session',
        persons     => [{
            id      => 42,
            name    => 'Anonymous',
            active  => '',
            spoken  => 0,
            star    => '',
        }],
        requests    => [0],
        list_open   => '',
    }, 'Correct hash values';
};

done_testing;

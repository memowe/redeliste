#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use Redeliste::Data::Person;
use Mojo::Collection 'c';

use_ok 'Redeliste::Data::Session';

subtest 'Required attributes' => sub {
    throws_ok { Redeliste::Data::Session->new->token }
        qr/^Token attribute required!/, 'Required token exception';
};

subtest 'Constructor' => sub {

    subtest 'Default values' => sub {
        is Redeliste::Data::Session->new(token => 1)->name
            => 'Anonymous session', 'name';
        ok Redeliste::Data::Session->new(token => 2)->list_open, 'list_open';
    };

    subtest 'Complete data' => sub {
        my $sess = Redeliste::Data::Session->new(
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

subtest Add => sub {
    my $session = Redeliste::Data::Session->new(token => 'FOOBAR');

    subtest Person => sub {
        is $session->persons->size => 0, 'No persons yet';
        my $person = $session->add_person;
        is $session->persons->size => 1, 'One person';
        is $session->persons->[0] => $person, 'Correct person';
        is $session->persons->[0]->id => 0, 'Correct person ID';
    };

    subtest Request => sub {
        my $person = $session->add_person;
        is $session->requests->size => 0, 'No requests yet';
        $session->add_request($person);
        is $session->requests->size => 1, 'One request';
        is $session->requests->[0] => $person->id, 'Right request';
    };
};

subtest 'Get request persons' => sub {
    my $session = Redeliste::Data::Session->new(token => 'QUUX');
    my $person1 = $session->add_person;
    my $person2 = $session->add_person;
    is $session->persons->size => 2, 'Got two persons';
    $session->add_request($person2)->add_request($person1);
    is_deeply $session->requests->to_array => [1, 0], 'Correct requests';
    is_deeply $session->get_request_persons->to_array
        => [$person2, $person1], 'Correct person array';
};

subtest 'Next speaker IDs' => sub {
    my $session = Redeliste::Data::Session->new(token => 'QUUX');
    my $person1 = $session->add_person;
    my $person2 = $session->add_person;
    is $session->persons->size => 2, 'Got two persons';
    $session->add_request($person2)->add_request($person1);
    is_deeply $session->get_next_speaker_ids
        => [1, 0], 'Correct next speakers';
};

subtest 'Data export' => sub {
    my $data = Redeliste::Data::Session->new(
        token       => 'XNORFZT',
        name        => 'Foo session',
        persons     => c(Redeliste::Data::Person->new(id => 42)),
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

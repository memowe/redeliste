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

        subtest Duplicate => sub {
            $session->add_request($person->id);
            is $session->requests->size => 1, 'Still one person';
            is $session->requests->[0] => $person->id, 'Old id';
        };

        subtest Revoke => sub {
            my $p = $session->add_person;
            $session->add_request($p);
            $session->revoke($person);
            is $session->requests->size => 1, 'Still one person';
            is $session->requests->[0] => $p->id, 'Right person';
        };
    };
};

subtest 'Get request persons' => sub {
    my $session = Redeliste::Data::Session->new(token => 'QUUX');
    my $person1 = $session->add_person;
    my $person2 = $session->add_person;
    is $session->persons->size => 2, 'Got two persons';
    $session->add_request($person2->id)->add_request($person1);
    is_deeply $session->requests->to_array => [1, 0], 'Correct requests';
    is_deeply $session->get_request_persons->to_array
        => [$person2, $person1], 'Correct person array';
};

subtest 'Next speakers' => sub {
    my $session = Redeliste::Data::Session->new(token => 'QUUX');
    my $p1 = $session->add_person;
    my $p2 = $session->add_person;
    my $p3 = $session->add_person;
    is $session->persons->size => 3, 'Got two persons';
    is $_->spoken => 0, 'Never spoke' for $p1, $p2, $p3;
    is $_->spoken_item => 0, 'Never spoke in this item' for $p1, $p2, $p3;
    ok not($_->talking), 'Not speaking' for $p1, $p2, $p3;

    subtest 'Get next IDs' => sub {
        $session->add_request($p2)->add_request($p3)->add_request($p1);
        is_deeply $session->get_next_speaker_ids => [1, 2, 0],
            'Correct next speakers';
    };

    subtest Call => sub {
        my $next_id = $session->get_next_speaker_ids->[0];
        my $called  = $session->call_next_speaker;
        my $nn_id   = $session->get_next_speaker_ids->[0];
        is $session->requests->size => 2, 'One speaker called';
        ok $called != $session->persons->[$nn_id], 'Correct speaker removed';
        is $called->spoken => 1, 'Spoke';
        is $called->spoken_item => 1, 'Spoke in this item';
        ok $p2->talking, 'Second person talking';
        ok not($p3->talking), 'Third person not talking';
        ok not($p1->talking), 'First person not talking';
    };

    subtest Override => sub {
        my $next_id = $session->requests->[1];
        my $called  = $session->call_next_speaker($next_id);
        my $nn_id   = $session->get_next_speaker_ids->[0];
        is $called->id => $next_id, 'Got the right speaker';
        is $session->requests->size => 1, 'One speaker called';
        ok $called != $session->persons->[$nn_id], 'Correct speaker removed';
        is $called->spoken => 1, 'Spoke';
        is $called->spoken_item => 1, 'Spoke in this item';
        ok $p1->talking, 'First person talking';
        ok not($p2->talking), 'Second person not talking';
        ok not($p3->talking), 'Third person not talking';
    };
};

subtest 'Next agenda item' => sub {
    my $session = Redeliste::Data::Session->new(token => 'PH00RT5');
    my $person  = $session->add_person;
    $session->add_request($person->id)->call_next_speaker;
    $session->list_open('')->next_item;

    is $session->requests->size => 0, 'No requests';
    ok $session->list_open, 'List is open';
    is $person->spoken => 1, 'Spoke once';
    is $person->spoken_item => 0, 'But not in this item';
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
            id          => 42,
            name        => 'Anonymous',
            active      => '',
            spoken      => 0,
            spoken_item => 0,
            star        => '',
            talking     => '',
        }],
        requests    => [0],
        list_open   => '',
    }, 'Correct hash values';
};

done_testing;

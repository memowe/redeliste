#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'Redeliste::Data::Person';

subtest 'Required attributes' => sub {
    throws_ok { Redeliste::Data::Person->new(name => 'Foo')->id }
        qr/^ID attribute required!/, 'Required id exception';
};

subtest 'Constructor' => sub {
    is Redeliste::Data::Person->new(id => 42)->name
        => 'Anonymous', 'Default name';

    subtest 'Complete data' => sub {
        my $trish = Redeliste::Data::Person->new(
            id          => 42,
            name        => 'Trillian',
            active      => 1,
            spoken      => 17,
            spoken_item => 34,
            star        => 1,
            tx          => \'Transaction',
        );

        is $trish->id           => 42, 'Correct ID';
        is $trish->name         => 'Trillian', 'Correct name';
        is $trish->active       => 1, 'Correct activity';
        is $trish->spoken       => 17, 'Correct speak count';
        is $trish->spoken_item  => 34, 'Correct item speak count';
        is $trish->star         => 1, 'Correct star value';
        is ${$trish->tx}        => 'Transaction', 'Correct tx value';
    };
};

subtest 'Spoken count' => sub {
    my $trish = Redeliste::Data::Person->new(id => 17);

    subtest 'First item' => sub {
        is $trish->spoken => 0, 'Never spoken';
        is $trish->spoken_item => 0, 'Never spoken in this agenda item';
        is $trish->spoke => $trish, 'Correct method chaining';
        is $trish->spoken => 1, 'Spoke once';
        is $trish->spoken_item => 1, 'Spoke once in this item';
    };

    subtest 'Second item' => sub {
        is $trish->next_item => $trish, 'Correct method chaining';
        is $trish->spoken => 1, 'Spoke once overall';
        is $trish->spoken_item => 0, 'Never spoke in this item';
        is $trish->spoke => $trish, 'Correct method chaining';
        is $trish->spoken => 2, 'Spoke twice overall';
        is $trish->spoken_item => 1, 'Spoke once in this item';
    };
};

subtest 'Data export' => sub {
    my $data = Redeliste::Data::Person->new(
        id          => 42,
        name        => 'Trillian',
        active      => 1,
        spoken      => 17,
        spoken_item => 666,
        star        => 1,
        tx          => \42,
    )->to_hash;

    is ref($data) => 'HASH', 'Correct hash reference';
    is_deeply $data => {
        id          => 42,
        name        => 'Trillian',
        active      => 1,
        spoken      => 17,
        spoken_item => 666,
        star        => 1,
    }, 'Correct hash values';
};

done_testing;

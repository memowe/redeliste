#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Exception;

use_ok 'Redeliste::Person';

subtest 'Required attributes' => sub {
    throws_ok { Redeliste::Person->new(name => 'Foo')->id }
        qr/^ID attribute required!/, 'Required id exception';
};

subtest 'Constructor' => sub {
    is Redeliste::Person->new(id => 42)->name => 'Anonymous', 'Default name';

    subtest 'Complete data' => sub {
        my $trish = Redeliste::Person->new(
            id      => 42,
            name    => 'Trillian',
            active  => 1,
            spoken  => 17,
            star    => 1,
            tx      => \'Transaction',
        );

        is $trish->id       => 42, 'Correct ID';
        is $trish->name     => 'Trillian', 'Correct name';
        is $trish->active   => 1, 'Correct activity';
        is $trish->spoken   => 17, 'Correct speak count';
        is $trish->star     => 1, 'Correct star value';
        is ${$trish->tx}    => 'Transaction', 'Correct tx value';
    };
};

subtest 'Data export' => sub {
    my $data = Redeliste::Person->new(
        id      => 42,
        name    => 'Trillian',
        active  => 1,
        spoken  => 17,
        star    => 1,
        tx      => \42,
    )->to_hash;

    is ref($data) => 'HASH', 'Correct hash reference';
    is_deeply $data => {
        id      => 42,
        name    => 'Trillian',
        active  => 1,
        spoken  => 17,
        star    => 1,
    }, 'Correct hash values';
};

done_testing;

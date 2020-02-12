#!/usr/bin/env perl

use Test::More;
use Test::Mojo;

# Prepare webservice lite app for testing
use FindBin;
require "$FindBin::Bin/../webservice";
my $t = Test::Mojo->new;
$t->app->log->level('warn');

subtest 'Create session' => sub {

    subtest 'Post and check response' => sub {
        $t->post_ok('/session', form => {
            name    => 'Foo session',
            pname   => 'Bar woman',
            sex     => 'female',
        })
            ->status_is(201)
            ->json_like('/token'      => qr/^.{5}$/, 'Token looks good')
            ->json_like('/adminToken' => qr/^.{20}$/, 'Admin token looks good');
    };

    subtest 'Model state modification' => sub {
        my $token       = $t->tx->res->json('/token');
        my $admin_token = $t->tx->res->json('/adminToken');
        my $session     = $t->app->model->sessions->{$token};

        subtest Session => sub {
            ok $session, 'Session found';
            is $session->admin_token => $admin_token, 'Correct admin token';
            is $session->name => 'Foo session', 'Correct session name';
        };

        subtest Chair => sub {
            my $chair = $session->persons->first;
            ok $chair, 'Chair found';
            is $chair->name => 'Bar woman', 'Correct chair name';
            ok $chair->star, 'Chair is a star';
        };
    };
};

subtest 'Join session' => sub {

    subtest 'Unknown session token' => sub {
        my $token = 'XNORFZT42';
        ok not(exists $t->app->model->sessions->{$token}),
            'Session token is really unknown';
        $t->post_ok("/session/$token/person")->status_is(404);
    };

    subtest 'Session exists' => sub {
        my $session = $t->app->model->add_session(name => 'Bar session');
        my $token   = $session->token;

        subtest Interaction => sub {
            $t->post_ok("/session/$token/person", form => {
                name => 'Baz name',
                sex  => 'male',
            })
                ->status_is(201)
                ->json_like('/personId' => qr/^\d+$/);
        };

        subtest 'Model state modification' => sub {
            my $person_id   = $t->tx->res->json('/personId');
            my $person      = $session->persons->[$person_id];
            is $person->name => 'Baz name', 'Correct person name';
            ok not($person->star), 'Person is not a star';
        };
    };
};

done_testing;

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

done_testing;

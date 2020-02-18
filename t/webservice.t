#!/usr/bin/env perl

use Test::More;
use Test::Mojo;
use Mojo::JSON qw(true false);

# Prepare webservice lite app for testing
use FindBin;
$ENV{REDELISTE_CONFIG} = "$FindBin::Bin/../redeliste.conf.sample";
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
            ->header_is('Access-Control-Allow-Origin' => '*')
            ->json_like('/token'      => qr/^.{5}$/, 'Token looks good')
            ->json_like('/adminToken' => qr/^.{20}$/, 'Admin token looks good');
    };

    subtest 'Model state modification' => sub {
        my $token       = $t->tx->res->json('/token');
        my $admin_token = $t->tx->res->json('/adminToken');
        my $chair_id    = $t->tx->res->json('/personId');
        my $session     = $t->app->model->sessions->{$token};

        subtest Session => sub {
            ok $session, 'Session found';
            is $session->admin_token => $admin_token, 'Correct admin token';
            is $session->name => 'Foo session', 'Correct session name';
        };

        subtest Chair => sub {
            my $chair = $session->persons->[$chair_id];
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
                ->header_is('Access-Control-Allow-Origin' => '*')
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

subtest 'Session data' => sub {

    # Prepare a non-trivial session
    my $session = $t->app->model->add_session(name => 'Baz session');
    my $p1      = $session->add_person(name => 'Quux star', sex => 'star');
    my $p2      = $session->add_person(name => 'Quuux man', sex => 'male');
    $session->add_request($p2);

    # Test data dump
    $t->get_ok('/session/' . $session->token)
        ->status_is(200)
        ->header_is('Access-Control-Allow-Origin' => '*')
        ->json_is('/session'        => $session->to_hash)
        ->json_is('/nextSpeakers'   => $session->get_next_speaker_ids)
        ->json_is('/listOpen'       => true);
};

done_testing;

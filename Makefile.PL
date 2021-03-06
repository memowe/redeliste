use v5.20.0;
use strict;

use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => 'redeliste',
    VERSION         => '0.01',
    AUTHOR          => 'Mirko Westermeier <mirko@westermeier.de>',
    LICENSE         => 'mit',
    PREREQ_PM       => {'Mojolicious' => '8.24'},
    TEST_REQUIRES   => {'Test::Exception' => '0.43'},
    META_MERGE      => {resources => {
        bugtracker => 'https://github.com/memowe/redeliste/issues',
        repository => 'https://github.com/memowe/redeliste',
    }},
    test => {TESTS => 't/*.t'}
);

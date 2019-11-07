use v5.20.0;
use strict;

use warnings;

use ExtUtils::MakeMaker;

WriteMakefile(
    VERSION     => '0.01',
    AUTHOR      => 'Mirko Westermeier <mirko@westermeier.de>',
    LICENSE     => 'mit',
    PREREQ_PM   => {'Mojolicious' => '8.24'},
    META_MERGE  => {resources => {
        bugtracker => 'https://github.com/memowe/redeliste/issues',
        repository => 'https://github.com/memowe/redeliste',
    }},
    test => {TESTS => 't/*.t'}
);

#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use 5.14.2;
use strict;
use warnings;

use ExtUtils::MakeMaker;


WriteMakefile(
    'NAME'         => 'Crane',
    'AUTHOR'       => 'Tema Novikov <novikov.tema@gmail.com>',
    'VERSION_FROM' => 'lib/Crane.pm',
    'LICENSE'      => 'artistic_2',
    
    'MIN_PERL_VERSION' => 5.14.2,
    
    'BUILD_REQUIRES' => {
        'Carp'                  => 0,
        'Cwd'                   => 0,
        'Data::Dumper'          => 0,
        'English'               => 0,
        'Fcntl'                 => 0,
        'File::Basename'        => 0,
        'File::Spec::Functions' => 0,
        'Getopt::Long'          => 0,
        'IO::Handle'            => 0,
        'POSIX'                 => 0,
        'Readonly'              => 0,
    },
    
    'TEST_REQUIRES' => {
        'Test::More::UTF8' => 0,
    },
);

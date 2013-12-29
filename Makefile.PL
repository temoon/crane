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
    'LICENSE'      => 'perl',
    
    'MIN_PERL_VERSION' => 5.14.2,
    
    'BUILD_REQUIRES' => {
        'Carp'                  => 0,
        'Cwd'                   => 0,
        'English'               => 0,
        'File::Basename'        => 0,
        'File::Spec::Functions' => 0,
        'IO::Handle'            => 0,
        'Readonly'              => 0,
        'Test::More::UTF8'      => 0,
    },
);

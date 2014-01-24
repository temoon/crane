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
    
    'MIN_PERL_VERSION' => '5.014_002',
    
    'CONFIGURE_REQUIRES' => {
        'ExtUtils::MakeMaker'   => '6.63_03',
    },
    
    'PREREQ_PM' => {
        'Carp'                  => 0,
        'Cwd'                   => 0,
        'Data::Dumper'          => 0,
        'English'               => 0,
        'Fcntl'                 => 0,
        'File::Basename'        => 0,
        'File::Find'            => 0,
        'File::Spec::Functions' => 0,
        'Getopt::Long'          => 0,
        'IO::Handle'            => 0,
        'POSIX'                 => 0,
        'Readonly'              => 0,
        'YAML'                  => 0,
        'YAML::Dumper'          => 0,
    },
    
    'TEST_REQUIRES' => {
        'Test::More'            => 0,
        'Test::More::UTF8'      => 0,
    },
);

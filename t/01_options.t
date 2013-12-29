#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Options;

use Test::More ( 'tests' => 5 );
use Test::More::UTF8;


isa_ok('Crane::Options', 'Exporter', 'Crane::Options');

can_ok('Crane::Options', qw( options args ));

is_deeply($OPT_SEPARATOR, [],                                                      '$OPT_SEPARATOR');
is_deeply($OPT_VERSION,   [ 'version!', 'Shows version information and exists.' ], '$OPT_VERSION');
is_deeply($OPT_HELP,      [ 'help|?!',  'Shows this help and exits.' ],            '$OPT_HELP');

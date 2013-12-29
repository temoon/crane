#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base qw( Exporter );

use Test::More ( 'tests' => 3 );
use Test::More::UTF8;


isa_ok(__PACKAGE__, 'Exporter');

can_ok(__PACKAGE__, qw( Readonly::Scalar Readonly::Array Readonly::Hash ));
can_ok(__PACKAGE__, qw( carp croak ));

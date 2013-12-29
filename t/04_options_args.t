#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Options;

use Test::More ( 'tests' => 1 );
use Test::More::UTF8;


local @ARGV = qw(
    --item=1
    --item=2
    --item=3
    a
    b
    c
);

options(
    [ 'item=s@', 'Item' ],
);


is_deeply(args(), [ qw( a b c ) ], 'args');

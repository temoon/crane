#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Options;

use Test::More ( 'tests' => 4 );
use Test::More::UTF8;


local @ARGV = qw(
    --one=string
    --three
    --no-four
);

options(
    [ 'one=s',  'One',   { 'default'  => 'number' } ],
    [ 'two=s',  'Two',   { 'default'  => 'number' } ],
    [ 'three!', 'Three', { 'required' => 1 }        ],
    [ 'four!',  'Four',  { 'required' => 1 }        ],
);

is(options->{'one'}, 'string', 'option with defined value');
is(options->{'two'}, 'number', 'option with default value');
ok(options->{'three'}, 'required option exists');
ok(!options->{'four'}, 'required option exists (with "no" prefix)');

#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Options;

use Test::More ( 'tests' => 5 );
use Test::More::UTF8;


local @ARGV = qw(
    --one=string
    --two=a
    --two=b
    --three
    --no-five
);

options(
    [ 'one=s',   'One'   ],
    [ 'two=s@',  'Two'   ],
    [ 'three!',  'Three' ],
    [ 'four|F!', 'Four'  ],
    [ 'five!',   'Five'  ],
);


is(options->{'one'}, 'string', 'string value');
is_deeply(options->{'two'}, [ qw( a b ) ], 'multiple values');
ok(options->{'three'}, 'boolean used');
ok(!options->{'four'}, 'boolean unused');
ok(!options->{'five'}, 'boolean used with no');

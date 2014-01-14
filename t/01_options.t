#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Options qw( :DEFAULT :opts );

use Test::More ( 'tests' => 17 );
use Test::More::UTF8;


isa_ok('Crane::Options', 'Exporter', 'Crane::Options');

can_ok('Crane::Options', qw( options args load_options ));

is_deeply($OPT_SEPARATOR, [],                                                      '$OPT_SEPARATOR');
is_deeply($OPT_VERSION,   [ 'version!', 'Shows version information and exists.' ], '$OPT_VERSION');
is_deeply($OPT_HELP,      [ 'help!',    'Shows this help and exits.' ],            '$OPT_HELP');


local @ARGV = qw(
    --opt1=string
    --opt2=a
    --opt2=b
    --opt3
    --no-opt5
    --opt6=string
    --opt8
    --no-opt9
    a
    b
    c
);

my $options = Crane::Options::load_options(
    [ 'opt1=s',   'One' ],
    [ 'opt2=s@',  'Two' ],
    [ 'opt3!',    'Three' ],
    [ 'opt4|O=i', 'Four' ],
    [ 'opt5!',    'Five' ],
    [ 'opt6=s',   'Six',   { 'default'  => 'number' } ],
    [ 'opt7=s',   'Seven', { 'default'  => 'number' } ],
    [ 'opt8!',    'Eight', { 'required' => 1 } ],
    [ 'opt9!',    'Nine',  { 'required' => 1 } ],
);

is($options->{'opt1'}, 'string', 'string value');
is_deeply($options->{'opt2'}, [ qw( a b ) ], 'multiple string values');
ok($options->{'opt3'}, 'boolean');
ok(!exists $options->{'opt4'}, 'unexistent');
ok(exists $options->{'opt5'}, 'boolean (with no) exists');
ok(!$options->{'opt5'}, 'boolean (with no) false');
is($options->{'opt6'}, 'string', 'option with defined value');
is($options->{'opt7'}, 'number', 'unexistent option with default value');
ok($options->{'opt8'}, 'required option exists');
ok(!$options->{'opt9'}, 'required option exists (with "no" prefix)');

eval {
    load_options(
        [ 'opt10', 'Ten', { 'required' => 1 } ],
    );
} or do {
    # Dummy
};

isnt($EVAL_ERROR, '', 'require option does not exist');

is_deeply(args(), [ qw( a b c ) ], 'args');

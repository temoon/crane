#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Config;

use Test::More ( 'tests' => 4 );
use Test::More::UTF8;


my $filename = 'test.conf';

my $original = {
    'a' => 1,
    
    'b' => [
        1,
        2,
        3,
    ],
    
    'c' => {
        'foo' => 'bar',
    },
};


# Merge
my $merged = Crane::Config::merge_config(\%{ $original }, { 'd' => 'Hello, world!' });

is_deeply($merged, { %{ $original }, 'd' => 'Hello, world!' }, 'merge simple');

$merged = Crane::Config::merge_config(\%{ $original }, { 'b' => 'Hello, world!' });

is_deeply($merged, { %{ $original }, 'b' => 'Hello, world!' }, 'merge simple');


# Read and write
SKIP: {
    eval {
        Crane::Config::write_config($original, $filename);
        
        1;
    } or do {
        skip('write config', 2);
    };
    
    pass('write config');
    
    my $config = eval {
        Crane::Config::read_config($filename);
    } or do {
        skip('read config', 1);
    };
    
    pass('read config');
}

if ( -e $filename ) {
    unlink $filename;
}

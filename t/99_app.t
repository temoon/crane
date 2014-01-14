#!/usr/bin/env perl
# -*- coding: utf-8 -*-


package My;


use Crane::Base;
use Crane::Options qw( :opts );


our $CONFIG = {
    'my' => {
        'autorun' => 1,
        
        'hosts' => [
            '127.0.0.1',
            '127.0.0.2',
        ],
    },
};


use Crane (
    'namespace' => 'My',
    'config'    => $CONFIG,
);


1;


package main;


use My;
use My::Base;
use My::Config;
use My::Logger;
use My::Options;

use Test::More ( 'tests' => 4 );
use Test::More::UTF8;


can_ok(__PACKAGE__, qw( config ));

is_deeply(config->{'my'}, $CONFIG, 'config');

can_ok(__PACKAGE__, qw( options ));
can_ok(__PACKAGE__, qw( log_fatal log_error log_warning log_info log_debug log_verbose ));


1;

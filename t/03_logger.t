#!/usr/bin/env perl
# -*- coding: utf-8 -*-


use Crane::Base;
use Crane::Logger;

use Test::More ( 'tests' => 38 );
use Test::More::UTF8;


isa_ok('Crane::Logger', 'Exporter', 'Crane::Logger');

can_ok('Crane::Logger', qw(
    log_fatal
    log_error
    log_warning
    log_info
    log_debug
    log_verbose
    write_to_fh
));


my $fatal_re   = qr{\[[^\]]+\] Fatal}si;
my $error_re   = qr{\[[^\]]+\] Error}si;
my $warning_re = qr{\[[^\]]+\] Warning}si;
my $info_re    = qr{\[[^\]]+\] Info}si;
my $debug_re   = qr{\[[^\]]+\] Debug}si;
my $verbose_re = qr{\[[^\]]+\] Verbose}si;


sub log_messages {
    
    my ( $level ) = @_;
    
    my $messages_filename = 'messages.log';
    my $errors_filename   = 'errors.log';
    
    open my $messages_fh, '>:encoding(UTF-8)', $messages_filename or croak($OS_ERROR);
    open my $errors_fh,   '>:encoding(UTF-8)', $errors_filename   or croak($OS_ERROR);
    
    local $Crane::Logger::LOG_LEVEL   = $level;
    local $Crane::Logger::MESSAGES_FH = $messages_fh;
    local $Crane::Logger::ERRORS_FH   = $errors_fh;
    
    log_fatal('Fatal');
    log_error('Error');
    log_warning('Warning');
    log_info('Info');
    log_debug('Debug');
    log_verbose('Verbose');
    
    local $INPUT_RECORD_SEPARATOR = undef;
    
    close $messages_fh or croak($OS_ERROR);
    close $errors_fh   or croak($OS_ERROR);
    
    open $messages_fh, '<:encoding(UTF-8)', $messages_filename or croak($OS_ERROR);
    open $errors_fh,   '<:encoding(UTF-8)', $errors_filename   or croak($OS_ERROR);
    
    my $messages = <$messages_fh>;
    my $errors   = <$errors_fh>;
    
    close $messages_fh or croak($OS_ERROR);
    close $errors_fh   or croak($OS_ERROR);
    
    unlink $messages_filename;
    unlink $errors_filename;
    
    return ( $messages, $errors );
    
}


# Fatal
my ( $messages, $errors ) = log_messages($Crane::Logger::LOG_FATAL);

like($errors,     $fatal_re,   'fatal (fatal)');
unlike($errors,   $error_re,   'error (fatal)');
unlike($errors,   $warning_re, 'warning (fatal)');
unlike($messages, $info_re,    'info (fatal)');
unlike($messages, $debug_re,   'debug (fatal)');
unlike($messages, $verbose_re, 'verbose (fatal)');

# Error
( $messages, $errors ) = log_messages($Crane::Logger::LOG_ERROR);

like($errors,     $fatal_re,   'fatal (error)');
like($errors,     $error_re,   'error (error)');
unlike($errors,   $warning_re, 'warning (error)');
unlike($messages, $info_re,    'info (error)');
unlike($messages, $debug_re,   'debug (error)');
unlike($messages, $verbose_re, 'verbose (error)');

# Warning
( $messages, $errors ) = log_messages($Crane::Logger::LOG_WARNING);

like($errors,     $fatal_re,   'fatal (warning)');
like($errors,     $error_re,   'error (warning)');
like($errors,     $warning_re, 'warning (warning)');
unlike($messages, $info_re,    'info (warning)');
unlike($messages, $debug_re,   'debug (warning)');
unlike($messages, $verbose_re, 'verbose (warning)');

# Info
( $messages, $errors ) = log_messages($Crane::Logger::LOG_INFO);

like($errors,     $fatal_re,   'fatal (info)');
like($errors,     $error_re,   'error (info)');
like($errors,     $warning_re, 'warning (info)');
like($messages,   $info_re,    'info (info)');
unlike($messages, $debug_re,   'debug (info)');
unlike($messages, $verbose_re, 'verbose (info)');

# Debug
( $messages, $errors ) = log_messages($Crane::Logger::LOG_DEBUG);

like($errors,     $fatal_re,   'fatal (debug)');
like($errors,     $error_re,   'error (debug)');
like($errors,     $warning_re, 'warning (debug)');
like($messages,   $info_re,    'info (debug)');
like($messages,   $debug_re,   'debug (debug)');
unlike($messages, $verbose_re, 'verbose (debug)');

# Verbose
( $messages, $errors ) = log_messages($Crane::Logger::LOG_VERBOSE);

like($errors,   $fatal_re,   'fatal (verbose)');
like($errors,   $error_re,   'error (verbose)');
like($errors,   $warning_re, 'warning (verbose)');
like($messages, $info_re,    'info (verbose)');
like($messages, $debug_re,   'debug (verbose)');
like($messages, $verbose_re, 'verbose (verbose)');

# -*- coding: utf-8 -*-


=head1 NAME

Crane::Logger - Log manager

=cut

package Crane::Logger;


use Crane::Base qw( Exporter );
use Crane::Options;
use Crane::Config;

use Data::Dumper;
use Fcntl qw( :flock );
use POSIX qw( strftime );


our @EXPORT = qw(
    &log_fatal
    &log_error
    &log_warning
    &log_info
    &log_debug
    &log_verbose
);


Readonly::Scalar(our $LOG_FATAL   => 1);
Readonly::Scalar(our $LOG_ERROR   => 2);
Readonly::Scalar(our $LOG_WARNING => 3);
Readonly::Scalar(our $LOG_INFO    => 4);
Readonly::Scalar(our $LOG_DEBUG   => 5);
Readonly::Scalar(our $LOG_VERBOSE => 6);


# Log level
our $LOG_LEVEL = config->{'log'}->{'level'} // $LOG_INFO;

if ( options->{'debug'} ) {
    $LOG_LEVEL = $LOG_DEBUG;
} elsif ( options->{'verbose'} ) {
    $LOG_LEVEL = $LOG_VERBOSE;
}


# Log file handle
our $MESSAGES_FH = *STDOUT;

if ( my $log_filename = options->{'log'} // config->{'log'}->{'filename'} ) {
    if ( -e $log_filename ) {
        open $MESSAGES_FH, '>>:encoding(UTF-8)', $log_filename or croak("Unable to update log '$log_filename': $OS_ERROR");
    }
}


# Error log file handle
our $ERRORS_FH = *STDERR;

if ( my $log_error_filename = options->{'log-error'} // config->{'log'}->{'error_filename'} ) {
    if ( -e $log_error_filename ) {
        open $ERRORS_FH, '>>:encoding(UTF-8)', $log_error_filename or croak("Unable to update log '$log_error_filename': $OS_ERROR");
    }
}


# Close file handles on exit
END {
    
    close $MESSAGES_FH or croak($OS_ERROR);
    close $ERRORS_FH    or croak($OS_ERROR);
    
}


=head1 SYNOPSIS

  use Crane::Logger;
  
  log_fatal('Fatal message', caller);
  log_error('Error message');
  log_warning('Warning message', $ref);
  log_info("First line\nSecond line\n");
  log_debug($ref);
  log_verbose('First line', 'Second line');


=head1 DESCRIPTION

Simple log manager with six log levels. Supports auto split messages by "end of
line" and dump references using L<Data::Dumper|Data::Dumper>.

=head2 Log entry

Each log entry looks like ...

  [2013-12-30 02:36:22 +0400 1388356582] Hello, world!

... and contains:

=over

=item Date

Date in ISO format: YYYY-MM-DD.

  2013-12-30

=item Time

Time in ISO format: hh:mm:ss.

  02:36:22

=item Time zone

Time zone in ISO format: ±hhmm.

  +0400

=item Unix time

Unix time.

  1388356582

=item Message

Log message.

  Hello, world!

=back

In case of log reference, each line will contain "header" (date and times):

  [2013-12-30 02:36:22 +0400 1388356582] {
  [2013-12-30 02:36:22 +0400 1388356582]   'room' => 'Sitting room',
  [2013-12-30 02:36:22 +0400 1388356582]   'colors' => [
  [2013-12-30 02:36:22 +0400 1388356582]     'orange',
  [2013-12-30 02:36:22 +0400 1388356582]     'purple',
  [2013-12-30 02:36:22 +0400 1388356582]     'black'
  [2013-12-30 02:36:22 +0400 1388356582]   ]
  [2013-12-30 02:36:22 +0400 1388356582] }

=head2 Log levels

=over

=item B<FATAL>

Logs messages at a B<FATAL> level only.

=item B<ERROR>

Logs messages classified as B<ERROR> and B<FATAL>.

=item B<WARNING>

Logs messages classified as B<WARNING>, B<ERROR> and B<FATAL>.

=item B<INFO>

Logs messages classified as B<INFO>, B<WARNING>, B<ERROR> and B<FATAL>.

=item B<DEBUG>

Logs messages classified as B<DEBUG>, B<INFO>, B<WARNING>, B<ERROR> and
B<FATAL>.

=item B<VERBOSE>

Logs messages classified as B<VERBOSE>, B<DEBUG>, B<INFO>, B<WARNING>, B<ERROR>
and B<FATAL>.

=back

Messages on levels: B<FATAL>, B<ERROR> and B<WARNING> go to error log; B<INFO>,
B<DEBUG> and B<VERBOSE> go to messages log.


=head1 OPTIONS

=over

=item B<--log>=I<path/to/messages.log>

If option is available will use as path to messages log file.

=item B<--log-error>=I<path/to/errors.log>

If option is available will use as path to errors log file.

=back


=head1 EXPORTED FUNCTIONS

=over

=item B<log_fatal> (I<@messages>)

Logs I<@messages> with level L<FATAL|/"FATAL">.

=cut

sub log_fatal {
    
    if ( $LOG_LEVEL >= $LOG_FATAL ) {
        write_to_fh($ERRORS_FH, @_);
    }
    
    return;
    
}


=item B<log_error> (I<@messages>)

Logs I<@messages> with level L<ERROR|/"ERROR">.

=cut

sub log_error {
    
    if ( $LOG_LEVEL >= $LOG_ERROR ) {
        write_to_fh($ERRORS_FH, @_);
    }
    
    return;
    
}


=item B<log_warning> (I<@messages>)

Logs I<@messages> with level L<WARNING|/"WARNING">.

=cut

sub log_warning {
    
    if ( $LOG_LEVEL >= $LOG_WARNING ) {
        write_to_fh($ERRORS_FH, @_);
    }
    
    return;
    
}


=item B<log_info> (I<@messages>)

Logs I<@messages> with level L<INFO|/"INFO">.

=cut

sub log_info {
    
    if ( $LOG_LEVEL >= $LOG_INFO ) {
        write_to_fh($MESSAGES_FH, @_);
    }
    
    return;
    
}


=item B<log_debug> (I<@messages>)

Logs I<@messages> with level L<DEBUG|/"DEBUG">.

=cut

sub log_debug {
    
    if ( $LOG_LEVEL >= $LOG_DEBUG ) {
        write_to_fh($MESSAGES_FH, @_);
    }
    
    return;
    
}


=item B<log_verbose> (I<@messages>)

Logs I<@messages> with level L<VERBOSE|/"VERBOSE">.

=cut

sub log_verbose {
    
    if ( $LOG_LEVEL >= $LOG_VERBOSE ) {
        write_to_fh($MESSAGES_FH, @_);
    }
    
    return;
    
}

=back


=head1 FUNCTIONS

=over

=item B<write_to_fh> (I<$fh>, I<@messages>)

Write I<@messages> to file handle I<$fh>.

=cut

sub write_to_fh {
    
    my ( $fh, @messages ) = @_;
    
    if ( not defined $fh ) {
        croak('Invalid file handle');
    }
    
    local $Data::Dumper::Indent = 1;
    local $Data::Dumper::Purity = 0;
    local $Data::Dumper::Terse  = 1;
    
    flock $fh, LOCK_EX;
    
    my $datetime = strftime(q{%Y-%m-%d %H:%M:%S %z %s}, localtime);
    
    foreach my $message ( @messages ) {
        foreach my $line ( split m{$INPUT_RECORD_SEPARATOR}osi, ( not defined $message or ref $message ) ? Dumper($message) : $message ) {
            print { $fh } "[$datetime] $line\n" or croak($OS_ERROR);
        }
    }
    
    flock $fh, LOCK_UN;
    
    return;
    
}

=back


=head1 ERRORS

=over

=item Unable to update log 'I<%s>': I<%s>

Where I<%s> is log filename and I<%s> is reason message.

Fires when unable to open or write to log file.

=item Invalid file handle

Fires when call L<write_to_fh|/"write_to_fh ($fh, @messages)"> with invalid file
handle.

=back


=head1 FILES

=over

=item F<E<lt>BASE_PATHE<gt>/log/messages.log>

Default log file with messages.

=item F<E<lt>BASE_PATHE<gt>/log/errors.log>

Default log file with errors.

=back


=head1 BUGS

Please report any bugs or feature requests to
L<https://rt.cpan.org/Public/Bug/Report.html?Queue=Crane> or to
L<https://github.com/temoon/crane/issues>.


=head1 AUTHOR

Tema Novikov, <novikov.tema@gmail.com>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013-2014 Tema Novikov.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0. For details, see the full text of the
license in the file LICENSE.


=head1 SEE ALSO

=over

=item * B<RT Cpan>

L<https://rt.cpan.org/Public/Dist/Display.html?Name=Crane>

=item * B<Github>

L<https://github.com/temoon/crane>

=back

=cut


1;

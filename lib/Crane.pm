# -*- coding: utf-8 -*-


=head1 NAME

Crane - Micro framework/helpers for scripts.

=cut

package Crane;


use Crane::Base;
use Crane::Options;

use File::Basename qw( basename );
use File::Spec::Functions qw( catdir );


our $VERSION = '1.00.0003';


sub import {
    
    my ( $package, %params ) = @_;
    
    # Predefined options
    my @options = (
        [ 'daemon|M!',     'Run as daemon.', { 'default' => $params{'name'} ? 1 : 0 } ],
        $OPT_SEPARATOR,
        [ 'config|C=s',    'Path to configuration file.' ],
        $OPT_SEPARATOR,
        [ 'log|O=s',       'Path to log file.' ],
        [ 'log-error|E=s', 'Path to error log file.' ],
        $OPT_SEPARATOR,
        [ 'debug|D!',      'Debug output.' ],
        [ 'verbose|V!',    'Verbose output.' ],
        $OPT_SEPARATOR,
        $OPT_VERSION,
        $OPT_HELP,
    );
    
    # Custom options will be added to the head
    if ( ref $params{'options'} eq 'ARRAY' ) {
        unshift @options, @{ $params{'options'} }, $OPT_SEPARATOR;
    }
    
    options(@options);
    
    # Run as daemon
    if ( options->{'daemon'} ) {
        local $OUTPUT_AUTOFLUSH = 1;
        
        $params{'name'} //= basename($PROGRAM_NAME) =~ s{[.]p[lm]$}{}rsi;
        
        # Prepare PID file
        my $pid_filename = catdir($ENV{'BASE_PATH'}, 'run/' . $params{'name'} . '.pid');
        my $pid_prev     = undef;
        
        open my $fh_pid, '+>>:encoding(UTF-8)', $pid_filename or croak($OS_ERROR);
        seek $fh_pid, 0, 0;
        
        $pid_prev = <$fh_pid>;
        
        if ( $pid_prev ) {
            chomp $pid_prev;
        }
        
        # Check if process is already running
        my $is_working = $pid_prev ? kill 0, $pid_prev : 0;
        
        if ( not $is_working ) {
            # Fork
            if ( my $pid = fork ) {
                truncate $fh_pid, 0;
                print { $fh_pid } "$pid\n" or croak($OS_ERROR);
                close $fh_pid              or croak($OS_ERROR);
                
                exit 0;
            }
        } else {
            die "Process is already running: $pid_prev\n";
        }
        
        close $fh_pid or croak($OS_ERROR);
    }
    
    return;
    
}


=head1 SYNOPSIS

  use Crane;
  
  ...
  
  use Crane ( 'name' => 'example' );


=head1 DESCRIPTION

Micro framework/helpers for comfortably develop projects.


=head1 OPTIONS

These options are available by default. You can define your custom options if
specify it in the import options.

=over

=item B<-M>, B<--daemon>, B<--no-daemon>

Runs as daemon.

=item B<-C> I<path/to/config>, B<--config>=I<path/to/config>

Path to configuration file.

=item B<-O> I<path/to/log>, B<--log>=I<path/to/log>

Path to log file.

=item B<-E> I<path/to/error/log>, B<--log-error>=I<path/to/error/log>

Path to error log file.

=item B<-D>, B<--debug>, B<--no-debug>

Debug output.

=item B<-V>, B<--verbose>, B<--no-verbose>

Verbose output.

=item B<-?>, B<--help>

Shows help and exits.

=back


=head1 RETURN VALUE

In case of running I<as daemon> will return 1 if process is already running.


=head1 DIAGNOSTICS

=over

=item Process is already running: %d

Where C<%d> is a PID.

You tried to run application I<as daemon> while another copy is running.

=back


=head1 EXAMPLES

=head2 Singleton usage

  use Crane;


=head2 Daemon usage

  use Crane ( 'name' => 'example' );


=head2 Configure options

  use Crane ( 'options' => [
      [ 'from|F=s', 'Start of the interval.', { 'required' => 1 } ],
      [ 'to|F=s',   'End of the interval.',   { 'required' => 1 } ],
  ] );

As a result we have these two options, a separator and default options.


=head1 ENVIRONMENT

Please, look at L<Crane::Base environment|Crane::Base#> description.


=head1 FILES

=over

=item F<etc/default.conf>

Default configuration file in YAML format. Uses if exists.

=item F<log/*>

Script's log files.

=item F<run/*.pid>

Script's PID files.

=back


=head1 AUTHOR

Tema Novikov, <novikov.tema@gmail.com>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013-2014 Tema Novikov.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0. For details, see the full text of the
license in the file LICENSE.

=cut


1;

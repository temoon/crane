# -*- coding: utf-8 -*-


=head1 NAME

Crane - Micro framework/helpers

=cut

package Crane;


use Crane::Base;
use Crane::Options;

use File::Basename qw( basename );
use File::Spec::Functions qw( catdir );


our $VERSION = '1.01.0004';


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
        my $pid_filename = catdir($ENV{'BASE_PATH'}, 'run', "$params{'name'}.pid");
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

=item B<-O> I<path/to/messages.log>, B<--log>=I<path/to/messages.log>

Path to messages log file.

=item B<-E> I<path/to/errors.log>, B<--log-error>=I<path/to/errors.log>

Path to errors log file.

=item B<-D>, B<--debug>, B<--no-debug>

Debug output.

=item B<-V>, B<--verbose>, B<--no-verbose>

Verbose output.

=item B<--version>

Shows version information and exits.

=item B<--help>

Shows help and exits.

=back


=head1 RETURN VALUE

In case of running as daemon will return 1 if process is already running.


=head1 DIAGNOSTICS

=over

=item Process is already running: I<%d>

Where I<%d> is a PID.

You tried to run application as daemon while another copy is running.

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

See L<Crane::Base>.


=head1 FILES

=over

=item F<E<lt>BASE_PATHE<gt>/etc/*>

Configuration files. See L<Crane::Config|Crane::Config/FILES>.

=item F<E<lt>BASE_PATHE<gt>/log/*>

Log files. See L<Crane::Logger|Crane::Logger/FILES>.

=item F<E<lt>BASE_PATHE<gt>/run/E<lt>nameE<gt>.pid>

Script's PID file.

=back


=head1 BUGS

Please report any bugs or feature requests to
L<https://github.com/temoon/crane/issues>. I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.


=head1 AUTHOR

Tema Novikov, <novikov.tema@gmail.com>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013-2014 Tema Novikov.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0. For details, see the full text of the
license in the file LICENSE.


=head1 SEE ALSO

=over

=item * B<Github>

https://github.com/temoon/crane

=back

=cut


1;

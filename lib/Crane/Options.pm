# -*- coding: utf-8 -*-


=head1 NAME

Crane::Options - Command line options and arguments parser.

=cut

package Crane::Options;


use Crane::Base qw( Exporter );

use File::Basename qw( basename );
use Getopt::Long qw( GetOptionsFromArray :config posix_default  );


our $VERSION = '1.00.0003';

our @EXPORT = qw(
    &options
    &args
    
    $OPT_SEPARATOR
    
    $OPT_VERSION
    $OPT_HELP
);


Readonly::Scalar(our $OPT_SEPARATOR => []);

Readonly::Scalar(our $OPT_VERSION   => [ 'version!', 'Shows version information and exists.' ]);
Readonly::Scalar(our $OPT_HELP      => [ 'help|?!',  'Shows this help and exits.' ]);


=head1 SYNOPSIS

  use Crane::Options;
  
  my $option = options->{'version'};
  my $arg2   = args->[1];


=head1 DESCRIPTION

Parses command line options and arguments. Options are available as hash
reference returned by L</options> function and arguments are available as array
reference returned by L</args> function.

You can configure options by passing list of array references when first call
L</options> function (see description below).

By default two options are available: B<version> and B<help> (B<?> as short
alias).


=head1 CONSTANTS

=over

=item $OPT_SEPARATOR

Not an option exaclty, just a separator in help output.

Equals to:

  []

=item $OPT_VERSION

Version information output.

Equals to:

  [ 'version!', 'Shows version information and exists.' ]

=item $OPT_HELP

Help output.

Equals to:

  [ 'help|?!', Shows this help and exits.' ]

=back


=head1 FUNCTIONS

=over

=item options [ LIST ]

Returns hash reference to command line options.

Can be configured when first call with list of options. For create an option
you should pass a list of array references with one required and two optional
items:

=over

=item Specification (required)

Scalar. Specification from L<Getopt::Long> module.

=item Description (optional)

Scalar. Text description - what is this option does?

=item Parameters (optional)

Hash reference. Additional parameters:

=over

=item default

Default value for option if option does not exist.

=item required

Flag that option should be exists.

=back

=back

=cut

sub options {
    
    return state $options = do {
        my @options = scalar @_ ? @_ : ( $OPT_VERSION, $OPT_HELP );
        my $options = {};
        
        {
            local $WARNING = 0;
            
            # Parse command line
            GetOptionsFromArray(\@ARGV, $options, grep { defined } map { $_->[0] } @options);
        }
        
        # Application file name
        my $app = basename($PROGRAM_NAME);
        
        # Show version information and exit
        if ( $options->{'version'} ) {
            my $version = $main::VERSION // 'not specified';
            
            print { *STDOUT } "$app version is $version\n" or croak($OS_ERROR);
            
            exit 0;
        }
        
        # Create help ...
        my $help = "$app <options> <args>\n";
        
        # ... and check options
        foreach my $opt ( @options ) {
            if ( ref $opt ne 'ARRAY' ) {
                next;
            }
            
            my $spec   = $opt->[0];
            my $desc   = $opt->[1];
            my $params = $opt->[2];
            
            # Separator
            if ( not defined $spec and not defined $desc and not defined $params ) {
                $help .= "\n";
            # Option
            } elsif ( defined $spec and $spec =~ m{^([^!+=:]+)}si ) {
                my @names = split m{[|]}si, $1;
                my $name  = $names[0];
                my $short = ( grep { length == 1 } @names )[0];
                my $long  = ( grep { length >= 2 } @names )[0];
                
                # Check params
                if ( ref $params eq 'HASH' ) {
                    # Default value
                    if ( exists $params->{'default'} and not exists $options->{ $name } ) {
                        $options->{ $name } = $params->{'default'};
                    }
                    
                    # Is required
                    if ( $params->{'required'} and not $options->{'help'} and not exists $options->{ $name } ) {
                        die "Option required: $name\n";
                    }
                }
                
                # Add to help
                $help .= sprintf q{  %-2s %-20s %s},
                    defined $short ? "-$short" : '',
                    defined $long  ? "--$long" : '',
                    
                    $desc // '';
                
                $help .= "\n";
            } else {
                croak("Invalid option specification: $spec");
            }
        }
        
        # Show help and exit
        if ( $options->{'help'} ) {
            print { *STDOUT } $help or croak($OS_ERROR);
            
            exit 0;
        }
        
        $options;
    };
    
}


=item args

Returns array reference to command line arguments.

=cut

sub args {
    
    return state $args = [ @ARGV ];
    
}

=back


=head1 ERRORS

=over

=item Invalid option specification: %s

Where C<%s> is specification string.

Fires when required parameter of specification is not defined or incorrect.

=back


=head1 DIAGNOSTICS

=over

=item Option required: %s

Where C<%s> is an option name.

Option does not exist but required.

=back


=head1 EXAMPLES

=head2 Simple option in compare with defaults

Configuration:

  options(
      [ 'config|C=s', 'Path to configuration file.' ],
      $OPT_SEPARATOR,
      $OPT_VERSION,
      $OPT_HELP,
  );

Help output:

  example.pl <options> <args>
    -C --config             Path to configuration file.
  
       --version            Shows version information and exists.
    -? --help               Shows this help and exits.

=head2 Two required arguments, one with default value and default options

Configuration:

  options(
      [ 'daemon|M!', 'Run as daemon.',         { 'default'  => 1 } ],
      $OPT_SEPARATOR,
      [ 'from=s',    'Start of the interval.', { 'required' => 1 } ],
      [ 'to=s',      'End of the interval.',   { 'required' => 1 } ],
      $OPT_SEPARATOR,
      $OPT_VERSION,
      $OPT_HELP,
  );

Help output:

  example.pl <options> <args>
    -M --daemon             Run as daemon.
  
       --from               Start of the interval.
       --to                 End of the interval.
  
       --version            Shows version information and exists.
    -? --help               Shows this help and exits.


=head1 AUTHOR

Tema Novikov, <novikov.tema@gmail.com>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013-2014 Tema Novikov.

This library is free software; you can redistribute it and/or modify it under
the terms of the Artistic License 2.0. For details, see the full text of the
license in the file LICENSE.

=cut


1;

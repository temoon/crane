# -*- coding: utf-8 -*-


=head1 NAME

Crane::Config - Configuration manager

=cut

package Crane::Config;


use Crane::Base qw( Exporter );
use Crane::Options;

use File::Spec::Functions qw( catdir );
use YAML;
use YAML::Dumper;


our @EXPORT = qw(
    &config
);


my $DEFAULT_FILENAME = catdir($ENV{'BASE_PATH'}, 'etc', 'default.conf');

my $DEFAULT_CONFIG = {
    'log' => {
        'level'          => 4,                                                  # Default log level is 'info'
        
        'filename'       => catdir($ENV{'BASE_PATH'}, 'log', 'messages.log'),   # Path to log file (undef -> stdout)
        'error_filename' => catdir($ENV{'BASE_PATH'}, 'log', 'errors.log'),     # Path to error log file (undef -> stderr)
    },
};


=head1 SYNOPSIS

  use Crane::Config;
  
  my $filename = config->{'log'}->{'filename'};


=head1 DESCRIPTION

Configuration manager which operates with YAML configurations. Settings are
available as a hash reference returned by L</config> function.

You can specify default configuration and filename by passing it to L</config>
function when first call (see description below).


=head1 OPTIONS

=over

=item B<--config>=I<path/to/config>

If option is available will use as path to configuration file.

=back


=head1 EXPORTED FUNCTIONS

=over

=item B<config ($config, @filenames)>

Returns link to current configuration.

When first call you can specify default configuration I<$config> and/or
list of config file names I<@filenames>.

=cut

sub config {
    
    return state $config = do {
        my ( $config, @filenames ) = @_;
        
        load_config(
            merge_config($DEFAULT_CONFIG, ref $config eq 'HASH' ? $config : {}),
            options->{'config'} ? options->{'config'} : scalar @filenames ? @filenames : $DEFAULT_FILENAME,
        );
    };
    
}

=back


=head1 FUNCTIONS

=over

=item B<merge_config ($original, $config)>

Merge two configs (I<$config> to I<$original>).

=cut

sub merge_config {
    
    my ( $original, $config ) = @_;
    
    my $type_original = ref $original;
    my $type_config   = ref $config;
    
    if ( $type_original eq $type_config ) {
        if ( $type_config eq 'HASH' ) {
            foreach my $key ( keys %{ $config } ) {
                if ( exists $original->{ $key } ) {
                    $original->{ $key } = merge_config($original->{ $key }, $config->{ $key });
                } else {
                    $original->{ $key } = $config->{ $key };
                }
            }
        }
    } else {
        $original = $config;
    }
    
    return $original;
    
}


=item B<read_config ($filename)>

Reads confugration from file named I<$filename>.

=cut

sub read_config {
    
    my ( $filename ) = @_;
    
    if ( not defined $filename ) {
        croak('No file name given');
    }
    
    my $config = {};
    
    if ( open my $fh, '<:encoding(UTF-8)', $filename ) {
        $config = eval {
            local $INPUT_RECORD_SEPARATOR = undef;
            return ( YAML::Load(<$fh>) )[0] || {};
        } or do {
            croak("Incorrect syntax in '$filename': $EVAL_ERROR");
        };
        
        close $fh or croak($OS_ERROR);
    } else {
        croak("Unable to read config '$filename': $OS_ERROR");
    }
    
    return $config;
    
}


=item B<write_config ($config, $filename)>

Saves configuration I<$config> to file named I<$filename>.

=cut

sub write_config {
    
    my ( $config, $filename ) = @_;
    
    if ( ref $config ne 'HASH' ) {
        croak('Configuration should be a hash reference');
    }
    
    if ( not defined $filename ) {
        croak('No file name given');
    }
    
    # Init YAML
    state $yaml = YAML::Dumper->new(
        'indent_width' => 4,
        'sort_keys'    => 1,
        'use_header'   => 0,
        'use_version'  => 0,
        'use_block'    => 1,
        'use_fold'     => 1,
        'use_aliases'  => 0,
    );
    
    # Dump configuration
    if ( open my $fh, '>:encoding(UTF-8)', $filename ) {
        if ( not eval { print { $fh } $yaml->dump($config) or croak($OS_ERROR) } or $EVAL_ERROR ) {
            croak("YAML error while writing '$filename': $EVAL_ERROR");
        }
        
        close $fh or croak($OS_ERROR);
    } else {
        croak("Unable to write config '$filename': $OS_ERROR");
    }
    
    return;
    
}


=item B<load_config ($config, @filenames)>

Load configurations from files named I<@filenames> and merges them to
configuration I<$config> and I<default> configuration.

=cut

sub load_config {
    
    my ( $config, @filenames ) = @_;
    
    if ( ref $config ne 'HASH' ) {
        croak('Configuration should be a hash reference');
    }
    
    foreach my $filename ( @filenames ) {
        if ( -e $filename ) {
            $config = merge_config($config, read_config($filename));
        }
    }
    
    return $config;
    
}

=back


=head1 ERRORS

=over

=item Incorrect syntax in 'I<%s>': I<%s>

Where I<%s> is file name and I<%s> is error message.

Invalid YAML configuration file.

=item Unable to read config 'I<%s>': I<%s>

Where I<%s> is file name and I<%s> is error message.

Fires when unable to open configuration for read.

=item Unable to write config 'I<%s>': I<%s>

Where I<%s> is file name and I<%s> is error message.

Fires when unable to open configuration for write.

=item YAML error while writing 'I<%s>': I<%s>

Where I<%s> is file name and I<%s> is error message.

=item Configuration should be a hash reference

Fires when function required hash reference as a configuration.

=item No filename given

Fires when function required name of file but it is undefined.

=back


=head1 EXAMPLES

Configuration file

  domain: "production"
  
  log:
      level: 0
      filename: "/var/log/example/messages.log"
      error_filename: "/var/log/example/errors.log"
  
  servers:
    - "127.0.0.1:3001"
    - "127.0.0.1:3002"

Which results to hash reference:

  {
      'domain' => 'production',
      
      'log' => {
          'level'          => '0',
          
          'filename'       => '/var/log/example/messages.log',
          'error_filename' => '/var/log/example/errors.log',
      },
      
      'servers' => [
          '127.0.0.1:3001',
          '127.0.0.1:3002',
      ],
  }


=head1 ENVIRONMENT

=over

=item BASE_PATH

See L<Crane::Base>.

=back


=head1 FILES

=over

=item F<E<lt>BASE_PATHE<gt>/etc/default.conf>

Default configuration file.

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

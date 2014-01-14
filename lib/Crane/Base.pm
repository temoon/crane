# -*- coding: utf-8 -*-


=head1 NAME

Crane::Base - Minimal base class for Crane projects

=cut

package Crane::Base;


use strict;
use warnings;
use utf8;
use feature ();
use open qw( :std :utf8 );
use base qw( Exporter );

use Carp;
use Cwd qw( getcwd );
use English qw( -no_match_vars );
use IO::Handle ();
use Readonly;


our @EXPORT = (
    @Carp::EXPORT,
    @English::EXPORT,
);


sub import {
    
    my ( $class, @isa ) = @_;
    
    strict->import();
    warnings->import();
    utf8->import();
    feature->import(':5.14');
    
    my $caller = caller;
    
    # ISA
    if ( scalar @isa ) {
        foreach my $isa ( @isa ) {
            eval "require $isa" or do {}; # Ignore loading errors
        }
        
        no strict 'refs';
        
        push @{ "${caller}::ISA" }, @isa;
    }
    
    $class->export_to_level(1, $caller);
    
    # Base path
    if ( not defined $ENV{'BASE_PATH'} ) {
        $ENV{'BASE_PATH'} = getcwd();
    }
    
    return;
    
}


=head1 SYNOPSIS

  use Crane::Base;


=head1 DESCRIPTION

Import this package is equivalent to:

  use strict;
  use warnings;
  use utf8;
  use feature qw( :5.14 );
  use open qw( :std :utf8 );
  
  use Carp;
  use English qw( -no_match_vars );
  use IO::Handle;
  use Readonly;


=head1 EXAMPLES

=head2 Script usage

  use Crane::Base;
  
  say 'Hello!' or confess($OS_ERROR);


=head2 Package usage

  package Example;
  
  use Crane::Base qw( Exporter );
  
  Readonly::Scalar(our $CONST => 'value');
  
  our @EXPORT = qw(
      &example
      $CONST
  );
  
  sub example {
      say 'This is an example!' or confess($OS_ERROR);
  }
  
  1;


=head1 ENVIRONMENT

=over

=item B<BASE_PATH>

Used to determine the base directory for the application environment.

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

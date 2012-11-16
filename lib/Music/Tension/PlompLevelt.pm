# "Plomp-Levelt consonance curve" implementation for musical dissonance
# calculations - http://sethares.engr.wisc.edu/comprog.html
#
# Beta interface! May change without notice!

package Music::Tension::PlompLevelt;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use Music::Tension ();
use Scalar::Util qw/looks_like_number/;

our @ISA     = qw(Music::Tension);
our $VERSION = '0.01';

########################################################################
#
# SUBROUTINES

sub new {
  my ( $class, %param ) = @_;
  my $self = $class->SUPER::new(%param);

  # TODO any extra params here

  bless $self, $class;
  return $self;
}

sub frequencies {
  my ( $self, $f1, $f2, $harmonics );

  # TODO must have default harmonic profile if none specified (param to
  # new?), otherwise must iterate through what the user provided (maybe
  # as a callback to any code they want?) when dealing with the
  # partials.
}

sub vertical {
  my ( $self, $pset ) = @_;
  croak "pitch set must be array ref\n" unless ref $pset eq 'ARRAY';
  croak "pitch set must contain multiple elements\n" if @$pset < 2;

  # TODO convert pitches to freqs, iterate through calls to appropriate
  # whatever
}

sub pitches {
  my ( $self, $p1, $p2, $harmonics ) = @_;
  croak "two pitches required" if !defined $p1 or !defined $p2;
  croak "pitches must be positive integers"
    if $p1 !~ m/^\d+$/
      or $p2 !~ m/^\d+$/;

  $self->frequencies( map( $self->pitch2freq($_), $p1, $p2 ), $harmonics );
}

1;
__END__

=head1 NAME

Music::Tension::PlompLevelt - Plomp-Levelt consonance curve calculations

=head1 SYNOPSIS

Beta interface! Has and will change without notice!

  use Music::Tension::PlompLevelt;
  my $tension = Music::Tension::PlompLevelt->new;

  TODO

=head1 DESCRIPTION

Parsing music into a form suitable for use by this module and practical
uses of the results are left as an exercise to the reader.

Plomp-Levelt consonance curve calculations for frequencies or pitches or TODO

=head1 METHODS

Any method may B<croak> if something is awry with the input. Methods are
inherited from the parent class, L<Music::Tension>.

=over 4

=item B<new> I<optional params>

Constructor. Accepts optional parameters that specify alternate values TODO

=back

=head1 SEE ALSO

=over 4

=item *

http://sethares.engr.wisc.edu/comprog.html - example code by William Sethares.

=item *

http://sethares.engr.wisc.edu/consemi.html - Relating Tuning and Timbre
by William Sethares.

=item *

L<Music::Tension::Cope> - alternative tension algorithm based on
work of David Cope

=back

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jeremy Mates

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16 or,
at your option, any later version of Perl 5 you may have available.

=cut

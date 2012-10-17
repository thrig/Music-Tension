# "Copian" tension analysis for 12-pitch material.
#
# Beta interface! May be subject to change without notice!

package Music::Tension::Cope;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use List::Util qw/max min sum/;

our @ISA     = qw(Music::Tension);    # or Moo/whatev it up
our $VERSION = '0.01';

my $DEG_IN_SCALE = 12;

# Interval tentions taken from "Computer Models of Musical Creativity",
# Cope, p.229-230, from least tension (0.0) to greatest (1.0).
my %tensions = (
  0  => 0.0,
  1  => 1.0,
  2  => 0.8,
  3  => 0.225,
  4  => 0.2,
  5  => 0.55,
  6  => 0.65,
  7  => 0.1,
  8  => 0.275,
  9  => 0.25,
  10 => 0.7,
  11 => 0.9,
);
# Intervals greater than octave more consonant by virtue of spread
my $octave_adjust = -0.02;

########################################################################
#
# SUBROUTINES

# boilerplate until figure out something better
sub new {
  my ( $class, %param ) = @_;
  my $self = {};

  bless $self, $class;
  return $self;
}

# TODO additional routines to consider rhythmic position/phrase
# considerations (e.g. highest or lowest tension for a series of notes,
# assuming a cadence, and "good enough" weighting if on or off The Beat.

# Tension from the root (first) note to others present in passed pitch
# set. Returns average, max, min, array ref of tensions. TODO might need
# a better name.
sub pcs {
  my ( $self, $pset ) = @_;
  croak "pitch set must be array ref\n" unless ref $pset eq 'ARRAY';
  croak "pitch set must contain something\n" if !@$pset;

  my @tensions;
  for my $i ( 1 .. $#$pset ) {
    push @tensions, $self->pitches( $pset->[0], $pset->[$i] );
  }

  return sum(@tensions) / @tensions, max(@tensions), min(@tensions),
    \@tensions;
}

# TODO rename "between" for $mtens->between($x, $y) reading code?
sub pitches {
  my ( $self, $p1, $p2 ) = @_;
  croak "two pitches required" if !defined $p1 or !defined $p2;
  croak "pitches must be integers" if $p1 !~ m/^-?\d+$/ or $p2 !~ m/^-?\d+$/;

  my $interval = abs( $p2 - $p1 );
  my $octave   = int( $interval / $DEG_IN_SCALE );
  my $tension =
    $tensions{ $interval % $DEG_IN_SCALE } +
    ( $octave > 0 ? $octave_adjust : 0 );
  $tension = 0 if $tension < 0;

  return $tension;
}

1;
__END__

=head1 NAME

Music::Tension::Cope - tension analysis for 12 pitch material

=head1 SYNOPSIS

Beta interface! May be subject to change without notice!

  use Music::Tension;
  my $mto = Music::Tension->new;

  my $tension = $mto->pitches(4, 17);

=head1 DESCRIPTION

Music tension analysis, David Cope style.

=head1 SEE ALSO

=over 4

=item *

"Computer Models of Musical Creativity", David Cope, 2005. ISBN
0-262-03338-0.

=back

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jeremy Mates

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14 or,
at your option, any later version of Perl 5 you may have available.

=cut

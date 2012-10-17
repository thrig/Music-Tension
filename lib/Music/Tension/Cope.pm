# "Copian" tension analysis for 12-pitch material.
#
# Beta interface! May be subject to change without notice!

package Music::Tension::Cope;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use List::Util qw/max min sum/;
use Scalar::Util qw/looks_like_number/;

our @ISA     = qw(Music::Tension);    # or Moo/whatev it up
our $VERSION = '0.01';

my $DEG_IN_SCALE = 12;

########################################################################
#
# SUBROUTINES

# boilerplate until figure out something better
sub new {
  my ( $class, %param ) = @_;
  my $self = {};

  if ( exists $param{tensions} ) {
    croak "tensions must be hash reference" if ref $param{tensions} ne 'HASH';
    $self->{_tensions} = $param{tensions};
  } else {
    # Default interval tentions taken from "Computer Models of Musical
    # Creativity", Cope, p.229-230, from least tension (0.0) to greatest
    # (1.0), less if greater than an octave.
    $self->{_tensions} = {
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
    };
  }

  if ( exists $param{octave_adjust} ) {
    croak "octave adjust must be a number"
      if !looks_like_number $param{octave_adjust};
    $self->{_octave_adjust} = $param{octave_adjust};
  } else {
    $self->{_octave_adjust} = -0.02;
  }

  bless $self, $class;
  return $self;
}

# TODO additional routines to consider rhythmic position/phrase
# considerations (e.g. highest or lowest tension for a series of notes,
# assuming a cadence, and "good enough" weighting if on or off The Beat.

# Tension from each lowest note to all others above it in a passed pitch
# set. Returns average, max, min, array ref of tensions. TODO might need
# a better name.
sub pcs {
  my ( $self, $pset ) = @_;
  croak "pitch set must be array ref\n" unless ref $pset eq 'ARRAY';
  croak "pitch set must contain something\n" if !@$pset;
  my @pcs = @$pset;

  # Reposition pitches upwards if subsequent lower than initial notes
  # (makes inversions more dissonant than root position chords, for one,
  # and does the "right thing" with <c e g c> or qw/0 4 7 0/).
  for my $i ( 1 .. $#pcs ) {
    while ( $pcs[$i] < $pcs[ $i - 1 ] ) {
      $pcs[$i] += $DEG_IN_SCALE;
    }
  }

  my @tensions;
  for my $i ( 0 .. $#pcs - 1 ) {
    for my $j ( $i + 1 .. $#pcs ) {
      push @tensions, $self->pitches( $pcs[$i], $pcs[$j] );
    }
  }

  return sum(@tensions) / @tensions, min(@tensions), max(@tensions),
    \@tensions;
}

# TODO rename "between" for $mtens->between($x, $y) reading code?
sub pitches {
  my ( $self, $p1, $p2 ) = @_;
  croak "two pitches required" if !defined $p1 or !defined $p2;
  croak "pitches must be integers"
    if $p1 !~ m/^-?\d+$/
      or $p2 !~ m/^-?\d+$/;

  my $interval = abs( $p2 - $p1 );
  my $octave   = int( $interval / $DEG_IN_SCALE );
  my $tension =
    $self->{_tensions}->{ $interval % $DEG_IN_SCALE } +
    ( $octave > 0 ? $self->{_octave_adjust} : 0 );
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
  my $mtc = Music::Tension->new;

  my $tension = $mtc->pitches(4, 17);
  my ( $t_avg, $t_min, $t_max, $t_ref ) = $mtc->pcs(qw/0 4 7/);

=head1 DESCRIPTION

Music tension analysis, David Cope style. The two methods (besides
B<new> for blessings) are B<pitches> which accepts two integer pitches
and returns the tension for them, and B<pcs>. B<pcs> is more
complicated, accepting an array reference of pitches, and performs
automatic octave adjustment (the pitches are assumed to be from
lowest note to highest; should a pitch later in the list be lower
than the previous pitch, it will be bumped up as many octaves as
necessary) before tallying the tension on each lowest note with all
higher notes in turn. This means chords such as <c dis e g> will have
the minor 2nd in the middle counted, instead of just from c upwards, and
that inversions will be ranked with higher tension than the root
position chord (I <c e g> vs. I6 <e g c> vs. I64 <g c e>).

=head1 SEE ALSO

=over 4

=item *

"Computer Models of Musical Creativity", David Cope, 2005. ISBN
0-262-03338-0. Tension values shamelessly lifted from this book.

=item *

Music::AtonalUtil

=item *

Music::Chord::Positions

=item *

"Theory of Harmony", Arnold Schoenberg, 1978. ISBN 978-0-520-26608-7.
Chord positions, inversions, harmony basics.

=back

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jeremy Mates

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.14 or,
at your option, any later version of Perl 5 you may have available.

=cut

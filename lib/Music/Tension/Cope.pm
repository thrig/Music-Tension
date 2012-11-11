# "Copian" tension analysis for 12-pitch material in equal temperament.
#
# Beta interface! May change without notice!

package Music::Tension::Cope;

use 5.010000;
use strict;
use warnings;

use Carp qw/croak/;
use Scalar::Util qw/looks_like_number/;

our @ISA     = qw(Music::Tension);    # but doesn't do anything right now
our $VERSION = '0.20';

my $DEG_IN_SCALE = 12;

########################################################################
#
# SUBROUTINES

sub new {
  my ( $class, %param ) = @_;
  my $self = {};

  if ( exists $param{duration_weight} ) {
    croak "duration_weight must be a number"
      if !looks_like_number $param{duration_weight};
    $self->{_duration_weight} = $param{duration_weight};
  } else {
    $self->{_duration_weight} = 0.1;
  }

  if ( exists $param{octave_adjust} ) {
    croak "octave_adjust must be a number"
      if !looks_like_number $param{octave_adjust};
    $self->{_octave_adjust} = $param{octave_adjust};
  } else {
    $self->{_octave_adjust} = -0.02;
  }

  if ( exists $param{tensions} ) {
    croak "tensions must be hash reference" if ref $param{tensions} ne 'HASH';
    for my $i ( 0 .. 11 ) {
      croak "tensions must include all intervals from 0 through 11"
        if !exists $param{tensions}->{$i};
    }
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

  bless $self, $class;
  return $self;
}

# Tension over durations
sub duration {
  my ( $self, $input, $duration ) = @_;

  croak "duration must be a positive value"
    if !looks_like_number($duration)
      or $duration <= 0;

  my $tension;
  if ( ref $input eq 'ARRAY' ) {
    $tension = $self->vertical($input);
  } elsif ( looks_like_number($input) ) {
    $tension = $input;
  } else {
    croak "unknown pitch set or prior tension value '$input'";
  }

  # p.232-233 [Cope 2005] - this result "is then added to any grouping's
  #   accumulated tension weighting"
  return $self->{_duration_weight} * $duration +
    $self->{_duration_weight} * $tension;
}

# Tension from first note to all others above it in a passed pitch set.
# Returns sum, min, max, and array ref of tensions, unless just the sum
# is desired by context.
sub vertical {
  my ( $self, $pset ) = @_;
  croak "pitch set must be array ref\n" unless ref $pset eq 'ARRAY';
  croak "pitch set must contain multiple elements\n" if @$pset < 2;
  my @pcs = @$pset;

  # Reposition pitches upwards if subsequent lower than the initial pitch
  for my $i ( 1 .. $#pcs ) {
    if ( $pcs[$i] < $pcs[0] ) {
      $pcs[$i] += $DEG_IN_SCALE +
        ( int( ( $pcs[0] - $pcs[$i] - 1 ) / $DEG_IN_SCALE ) ) * $DEG_IN_SCALE;
    }
  }

  my $min = ~0;
  my $max = 0;
  my ( @tensions, $sum );
  for my $j ( 1 .. $#pcs ) {
    my $t = $self->pitches( $pcs[0], $pcs[$j] );
    $sum += $t;
    $min = $t if $t < $min;
    $max = $t if $t > $max;
    push @tensions, $t;
  }

  return wantarray ? ( $sum, $min, $max, \@tensions ) : $sum;
}

# Tension for two pitches
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

Music::Tension::Cope - tension analysis for equal temperament music

=head1 SYNOPSIS

Beta interface! Has and will change without notice!

  use Music::Tension;
  my $tension = Music::Tension->new;

  my $value = $tension->pitches(4, 17);

  my $sum                     = $tension->vertical([qw/0 4 7/]);
  my ($sum, $min, $max, $ref) = $tension->vertical([qw/0 4 7/]);

  $tension->duration( $sum,        1/4 );
  $tension->duration( [qw/0 4 7/], 1/8 );

=head1 DESCRIPTION

This module offers tension analysis of equal temperament 12-pitch music,
using the method outlined by David Cope in the text "Computer Models of
Musical Creativity". The various methods will calculate the tension of
verticals (simultaneous pitches), over a given duration, and so forth.
Larger numbers indicate greater tension (dissonance) and smaller numbers
consonance. Parsing music into a form suitable for use by this module
and practical uses of the results are left as an exercise to the reader.

Tension results may change between releases due to code changes. Be sure
to update all old tension values before starting any new analysis or
composition. This may require storing the original intervals or pitch
sets along with the tension numbers.

=head1 METHODS

Any method may B<croak> if something is awry with the input.

=over 4

=item B<new> I<optional params>

Constructor. Accepts optional parameters that specify alternate values
instead of using the Cope-derived defaults.

  my $tension = Music::Tension::Cope->new(
    duration_weight => 0.42,
    octave_adjust   => 0.42,
    tensions        => { 0 => 0.42, 1 => 0.42, ... },
  );

=over 4

=item *

I<duration_weight> adjusts the weighting given to B<duration> tension
calculations.

=item *

I<octave_adjust> is a number to adjust intervals greater than an octave
by. Intervals a single or multiple registers above the root will receive
the same adjustment.

=item *

I<tensions> must be a hash reference that must contain all intervals
from (unison) to 11 (major seventh) inclusive.

=back

=item B<duration> I<pitch_set_or_tension>, I<duration>

Calculates and returns the duration tension of a given pitch set
reference or prior tension value for a given duration. The duration
tension increases in proportion to the input tension and magnitude of
the duration.

The exact value of the duration parameter is largely irrelevant as long
as shorter durations use smaller values, and that the durations used are
consistent over an analysis or composition. It could be a value in
seconds, or a fraction 1/16 for a 16th note and then 1 for a whole note,
or whatever. If using notes, be sure to factor in tempo if there are
significant alterations to that over the course of a work.

The duration tension may also need adjustment depending on how well the
instrument involved sustains; consider a xylophone vs. a piano vs. a
piano with the sustain pedal down vs. a church organ.

=item B<vertical> I<pitch_set_reference>

B<vertical> accepts an array reference of pitches (integers), and
tallies tensions between the initial pitch to each subsequent.
B<vertical> will move subsequent pitches up a register if they are below
the first pitch:

  <10 0 4 7> is considered as <10 12 16 19>

Unisons with the initial pitch will not be adjusted upwards. Octaves
below the initial pitch will be adjusted to unison. If the
adjustments are a problem, ensure that the first pitch is the lowest
of the pitch set.

B<vertical> returns the tension, minimum tension, maximum tension, and a
reference to a list of tensions for each interval. Except in scalar
context, where just the tension value is returned.

An alternative approach would be to perform tension checks on each pitch
to any higher pitches, such that C<0 3 4 5> would also count the
intervals present above the root (3 to 4, 3 to 5, and 4 to 5), instead
of just the minor 3rd, major 3rd, and perfect fourth up from the root.
An earlier version of this module did so, but the current code is trying
to follow what Cope does as closely as possible.

=item B<pitches> I<pitch1>, I<pitch2>

Accepts two pitches (integers) and returns the tension of the interval
formed between those two pitches.

=back

=head1 SEE ALSO

=over 4

=item *

L<App::MusicTools>

=item *

"Computer Models of Musical Creativity", David Cope, 2005, p.229-235.

=item *

"The Craft of Musical Composition", Paul Hindemith, 1942. (4th edition)

=item *

L<Music::Chord::Note>

=back

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jeremy Mates

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16 or,
at your option, any later version of Perl 5 you may have available.

=cut

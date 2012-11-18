# "Plomp-Levelt consonance curve" implementation
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

# [Helmholtz 1877 p.79] relative intensity of first six harmonics of
# piano wire, struck at 1/7th its length, for various hammer types. Via
# http://jjensen.org/DissonanceCurve.html
#
# TODO link these to something in new() for default harmonic amps, if
# generating those?
my %AMPLITUDES = (
  'pianowire-plucked' => [ 1, 0.8, 0.6, 0.3, 0.1, 0.03 ],
  'pianowire-soft'    => [ 1, 1.9, 1.1, 0.2, 0,   0.05 ],
  'pianowire-medium'  => [ 1, 2.9, 3.6, 2.6, 1.1, 0.2 ],
  'pianowire-hard'    => [ 1, 3.2, 5,   5,   3.2, 1 ],
);

########################################################################
#
# SUBROUTINES

sub new {
  my ( $class, %param ) = @_;
  my $self = $class->SUPER::new(%param);

  # TODO means to specify harmonics or whatnot here?

  bless $self, $class;
  return $self;
}

# Not sure if I've followed the papers correctly; they all operate on a
# single frequency with overtones above that, while for tension I'm
# interested in "given these two frequencies or pitches (with their own
# sets of overtones), how dissonant are they to one another" so
# hopefully I can just tally up the harmonics between the two different
# sets of harmonics?
sub frequencies {
  my ( $self, $f1, $f2 ) = @_;
  my @harmonics;

  # TODO these should be built from callback or some new() param (new()
  # could also have some means to specify the amplitude sets)
  if ( looks_like_number $f1) {
    $harmonics[0] = [
      { amp => 1,   freq => $f1 },
      { amp => 2.9, freq => $f1 * 2 },
      { amp => 3.6, freq => $f1 * 3 },
      { amp => 2.6, freq => $f1 * 4 },
      { amp => 1.1, freq => $f1 * 5 },
      { amp => 0.2, freq => $f1 * 6 },
    ];
  } elsif ( ref $f1 eq 'ARRAY' ) {
    $harmonics[0] = $f1;
  } else {
    croak "unknown input for frequency1";
  }
  if ( looks_like_number $f2) {
    $harmonics[1] = [
      { amp => 1,   freq => $f2 },
      { amp => 2.9, freq => $f2 * 2 },
      { amp => 3.6, freq => $f2 * 3 },
      { amp => 2.6, freq => $f2 * 4 },
      { amp => 1.1, freq => $f2 * 5 },
      { amp => 0.2, freq => $f2 * 6 },
    ];
  } elsif ( ref $f2 eq 'ARRAY' ) {
    $harmonics[1] = $f2;
  } else {
    croak "unknown input for frequency1";
  }

  # code ported from equation at http://jjensen.org/DissonanceCurve.html
  my $tension;
  for my $i ( 0 .. $#{ $harmonics[0] } ) {
    for my $j ( 0 .. $#{ $harmonics[1] } ) {
      my @freqs = sort { $a <=> $b } $harmonics[0][$i]{freq},
        $harmonics[1][$j]{freq};
      my $q = ( $freqs[1] - $freqs[0] ) / ( 0.0207 * $freqs[0] + 18.96 );
      $tension +=
        $harmonics[0][$i]{amp} *
        $harmonics[1][$j]{amp} *
        ( exp( -0.84 * $q ) - exp( -1.38 * $q ) );
    }
  }

  return $tension;
}

sub pitches {
  my ( $self, $p1, $p2, $freq_harmonics ) = @_;
  croak "two pitches required" if !defined $p1 or !defined $p2;
  croak "pitches must be positive integers"
    if $p1 !~ m/^\d+$/
      or $p2 !~ m/^\d+$/;

  return $self->frequencies( map( $self->pitch2freq($_), $p1, $p2 ),
    $freq_harmonics );
}

sub vertical {
  my ( $self, $pset ) = @_;
  croak "pitch set must be array ref\n" unless ref $pset eq 'ARRAY';
  croak "pitch set must contain multiple elements\n" if @$pset < 2;

  my @freqs = map $self->pitch2freq($_), @$pset;

  my $min = ~0;
  my $max = 0;
  my ( @tensions, $sum );
  for my $i ( 1 .. $#freqs ) {
    my $t = $self->frequencies( $freqs[0], $freqs[$i] );
    $sum += $t;
    $min = $t
      if $t < $min;
    $max = $t
      if $t > $max;
    push @tensions, $t;
  }

  return wantarray ? ( $sum, $min, $max, \@tensions ) : $sum;
}

1;
__END__

=head1 NAME

Music::Tension::PlompLevelt - Plomp-Levelt consonance curve calculations

=head1 SYNOPSIS

Beta interface! Will likely change without notice!

  use Music::Tension::PlompLevelt;
  my $tension = Music::Tension::PlompLevelt->new;

  $tension->frequences(440, 880);

  $tension->pitches(69, 81);

  $tension->vertical([qw/60 64 67/]);

=head1 DESCRIPTION

Plomp-Levelt consonance curve calculations based on work by William
Sethares and others (L<"SEE ALSO"> for links). The calculations use the
harmonics (the fundamental plus some number of overtones above that).
The relative intensity of these harmonics vary by instrument and how the
instrument is played; some instruments have partials that line up with
the even harmonic numbers (strings), others that favor the odd harmonic
numbers (clarinet), and still others show more complicated relationships
(percussion). Finding details on the harmonics may require consulting a
book, or performing spectral analysis (e.g. via Audacity) on recordings
of a particular instrument, or fiddling around with a synthesizer.

The critical band is considered to be about a minor 3rd, or about 6/5 of
the frequency, though this expands to perhaps a major 3rd for lower
frequencies. (Hence composers favoring larger, more consonant intervals
in the bass?)

Parsing music into a form suitable for use by this module and practical
uses of the results are left as an exercise to the reader.

=head1 CAVEATS

Other music writers indicate that the partials should be ignored, for
example Harry Partch: "Long experience... convinces me that it is
preferable to ignore partials as a source of musical materials. The ear
is not impressed by partials as such. The faculty--the prime faculty--of
the ear is the perception of small-numbered intervals, 2/1, 3/2, 4/3,
etc. and the ear cares not a whit whether these intervals are in or out
of the overtone series." (Genesis of a Music, 1947). (However, note that
this rant predates the work by Sethares and others.)

On the plus side, this method does rate an augmented triad as more
dissonant than a diminished triad (though that test was with distortions
from equal temperament), which agrees with a study mentioned over in
L<Music::Tension::Cope> that the Cope method finds the opposite of.

=head1 METHODS

Any method may B<croak> if something is awry with the input. Methods are
inherited from the parent class, L<Music::Tension>. Unlike
L<Music::Tension::Cope>, this module is very sensitive to the register
of the pitches involved, so input pitches should ideally be from the
MIDI note numbers and in the proper register. Or instead use frequencies
via methods that accept those (especially to avoid the distortions of
equal temperament tuning).

The tension number depends heavily on the equation (and constants to
said equation), and should not be considered comparable to any other
tension modules in this distribution, and only to other tension values
from this module if the same harmonics were used in all calculations.

=over 4

=item B<new> I<optional params>

Constructor. Accepts an optional parameter to change the
reference frequency use by the pitch to frequency conversion
calls (440 by default).

  Music::Tension::PlompLevelt->new(reference_frequency => 442);

=item B<frequencies> I<freq_or_ref1>, I<freq_or_ref2>

Method that accepts two frequencies, or two array references containing
the harmonics and amplitudes of such. Returns tension as a number.

  # default harmonics will be filled in for five overtones (currently
  # Helmholtz amplitudes for piano wire, medium hammer, etc)
  $tension->frequencies(440, 880);

  # custom harmonics
  $tension->frequencies(
    [ {amp=>1,    freq=>440}, {amp=>0.5,  freq=>880}  ],
    [ {amp=>0.88, freq=>880}, {amp=>0.44, freq=>1760} ]
  );

=item B<pitches> I<pitch1>, I<pitch2>

Accepts two integers (ideally MIDI note numbers) and converts those to
frequencies via B<pitch2freq> (which does the MIDI number to frequency
conversion equation) and then calls B<frequencies> with those values.
Use B<frequencies> with the proper Hz if a non-equal temperament tuning
is involved. Returns tension as a number.

=item B<vertical> I<pitch_set>

Given a pitch set (an array reference of integer pitch numbers that are
ideally MIDI not numbers), converts those pitches to frequencies via
B<pitch2freq> then calls B<frequencies> for the first pitch compared in
turn with each subsequent in the set. Returns tension as a number.

=back

=head1 SEE ALSO

=over 4

=item *

http://jjensen.org/DissonanceCurve.html - Java applet, discussion.

=item *

http://sethares.engr.wisc.edu/consemi.html - "Relating Tuning and Timbre"
by William Sethares. Also http://sethares.engr.wisc.edu/comprog.html

=item *

"Music: A Mathematical Offering", David Benson, 2008. (Chapter 4)
http://homepages.abdn.ac.uk/mth192/pages/html/maths-music.html

=item *

L<Music::Tension::Cope> - alternative tension algorithm based on
work of David Cope.

=item *

R. Plomp and W. J. M. Levelt, Tonal consonance and critical bandwidth,
J. Acoust. Soc. Amer. 38 (4) (1965), 548-560.

=back

=head1 AUTHOR

Jeremy Mates, E<lt>jmates@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Jeremy Mates

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16 or,
at your option, any later version of Perl 5 you may have available.

=cut

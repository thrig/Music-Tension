use strict;
use warnings;

use Test::More tests => 5;
BEGIN { use_ok('Music::Tension::PlompLevelt') }

my $tension = Music::Tension::PlompLevelt->new;
isa_ok( $tension, 'Music::Tension::PlompLevelt' );

# Just Intonation, Major (minor is 1 9/8 6/5 4/3 3/2 8/5 9/5)
my @just_ratios = ( 1, 9 / 8, 5 / 4, 4 / 3, 3 / 2, 5 / 3, 15 / 8, 2 );

is( sprintf( "%.03f", $tension->frequencies( 440, 440 ) ),
  0.016, 'tension of frequency at unison' );

# equal temperament has higher tension, excepting unison/octaves
is( sprintf( "%.03f", $tension->pitches( 69, 69 ) ),
  0.016, 'tension of pitches at unison' );

is( sprintf( "%.03f", $tension->vertical( [qw/60 64 67/] ) ),
  3.563, 'tension of major triad (equal temperament)' );

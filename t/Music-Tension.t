use strict;
use warnings;

use Test::More tests => 5;
BEGIN { use_ok('Music::Tension') }

my $t = Music::Tension->new;

is( $t->freq2pitch(440), 69,  'frequency to pitch, MIDI ref freq' );
is( $t->pitch2freq(69),  440, 'pitch to frequency, MIDI ref pitch' );

# something about tests being large enough for anyone
my $tprime = Music::Tension->new( reference_frequency => 640 );

is( $tprime->freq2pitch(440), 62,  'frequency 440 to pitch, ref freq 640' );
is( $tprime->pitch2freq(69),  640, 'pitch 69 to frequency, ref pitch 640' );

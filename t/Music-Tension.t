#!perl

use strict;
use warnings;

use Test::Most;    # plan is down at bottom

use Music::Tension;
my $t = Music::Tension->new;

isa_ok( $t, 'Music::Tension' );

is( $t->freq2pitch(440), 69,  'frequency to pitch, MIDI ref freq' );
is( $t->pitch2freq(69),  440, 'pitch to frequency, MIDI ref pitch' );

# something about tests being large enough for anyone
my $tprime = Music::Tension->new( reference_frequency => 640 );

dies_ok { Music::Tension->new( reference_frequency => undef ) };
dies_ok { Music::Tension->new( reference_frequency => "xa" ) };

is( $tprime->freq2pitch(440), 63, 'frequency 440 to pitch, ref freq 640' );

dies_ok { $tprime->freq2pitch() } qr/positive number/;
dies_ok { $tprime->freq2pitch("xa") } qr/positive number/;
dies_ok { $tprime->freq2pitch(0) } qr/positive number/;

is( $tprime->pitch2freq(69), 640, 'pitch 69 to frequency, ref pitch 640' );

dies_ok { $tprime->pitch2freq() } qr/MIDI number/;
dies_ok { $tprime->pitch2freq("xa") } qr/MIDI number/;
dies_ok { $tprime->pitch2freq(-1) } qr/MIDI number/;

plan tests => 13;

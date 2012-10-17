use strict;
use warnings;

use Test::More tests => 3;
BEGIN { use_ok('Music::Tension::Cope') }

my $mt = Music::Tension::Cope->new;

is( $mt->pitches( 0, 0 ),  0, 'unison tension test' );
is( $mt->pitches( 0, 12 ), 0, 'octave tension test' );

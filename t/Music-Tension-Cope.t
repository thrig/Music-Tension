use strict;
use warnings;

use Test::More tests => 8;
BEGIN { use_ok('Music::Tension::Cope') }

my $mt = Music::Tension::Cope->new;

is( $mt->pitches( 0, 0 ),  0, 'unison tension test' );
is( $mt->pitches( 0, 12 ), 0, 'octave tension test' );

is( $mt->pitches( 0, 1 ),  1.0,  'minor 2nd tension test' );
is( $mt->pitches( 0, 13 ), 0.98, 'minor 2nd +8va tension test' );

is_deeply(
  [ $mt->pcs( [qw/0 3 7/] ) ],
  [ 0.175, 0.225, 0.1, [ 0.225, 0.1, 0.2 ] ],
  'pcs test'
);

my $mtc = Music::Tension::Cope->new(
  tensions      => { 0 => 0.33, 1 => 0.5 },
  octave_adjust => 0.2,
);
is( $mtc->pitches( 0, 0 ),  0.33, 'unison tension test (custom)' );
is( $mtc->pitches( 0, 13 ), 0.7,  'minor 2nd +8va tension test (custom)' );

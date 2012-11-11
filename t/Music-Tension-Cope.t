use strict;
use warnings;

use Test::More tests => 11;
BEGIN { use_ok('Music::Tension::Cope') }

my $mt = Music::Tension::Cope->new;

is( $mt->pitches( 0, 0 ),  0, 'unison tension test' );
is( $mt->pitches( 0, 12 ), 0, 'octave tension test' );

is( $mt->pitches( 0, 1 ),  1.0,  'minor 2nd tension test' );
is( $mt->pitches( 0, 13 ), 0.98, 'minor 2nd +8va tension test' );
# multiple ocatves no more consonant
is( $mt->pitches( 0, 25 ), 0.98, 'minor 2nd +8va*2 tension test' );

is_deeply(
  [ $mt->pcs( [qw/0 3 7/] ) ],
  [ 0.325, 0.1, 0.225, [ 0.225, 0.1 ] ],
  'pcs test'
);

# repositioning edge cases
is_deeply(
  [ $mt->pcs( [qw/14 1 2 3 12 13/] ) ],
  [ 3.5, 0, 1, [ 0.9, 0, 1, 0.7, 0.9 ] ],
  'pcs reposition test single register'
);
is_deeply(
  [ $mt->pcs( [qw/60 11 12 13/] ) ],
  [ 1.9, 0, 1, [ 0.9, 0, 1 ] ],
  'pcs reposition test multiple registers'
);

my $mtc = Music::Tension::Cope->new(
  tensions => {
    0  => 0.33,
    1  => 0.5,
    2  => 0,
    3  => 0,
    4  => 0,
    5  => 0,
    6  => 0,
    7  => 0,
    8  => 0,
    9  => 0,
    10 => 0,
    11 => 0
  },
  octave_adjust => 0.2,
);
is( $mtc->pitches( 0, 0 ),  0.33, 'unison tension test (custom)' );
is( $mtc->pitches( 0, 13 ), 0.7,  'minor 2nd +8va tension test (custom)' );

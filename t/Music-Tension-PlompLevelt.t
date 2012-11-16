use strict;
use warnings;

use Test::More tests => 1;
BEGIN { use_ok('Music::Tension::PlompLevelt') }

my $tension = Music::Tension::PlompLevelt->new;

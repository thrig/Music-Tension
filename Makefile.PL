use 5.010000;
use ExtUtils::MakeMaker;

WriteMakefile(
  NAME         => 'Music::Tension',
  VERSION_FROM => 'lib/Music/Tension.pm',
  LICENSE      => 'perl',
  PREREQ_PM    => {
    Carp         => 0,
    List::Util   => 0,
    Scalar::Util => 0,
    Test::More   => 0,
  },
  ( $] >= 5.005
    ?    ## Add these new keywords supported since 5.005
      (
      ABSTRACT_FROM => 'lib/Music/Tension.pm', # retrieve abstract from module
      AUTHOR => 'Jeremy Mates <jmates@cpan.org>'
      )
    : ()
  ),
);

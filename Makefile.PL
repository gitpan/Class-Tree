use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (ron@savage.net.au)',
		'ABSTRACT' => 'C++ class hierarchies & disk directories',
    ) : (),
	clean			=>
	{
		FILES		=> 'blib/* Makefile MANIFEST Class-Tree-*'
	},
	dist			=>
	{
		COMPRESS	=> 'gzip',
		SUFFIX		=> 'gz'
	},
	DISTNAME		=> 'Class-Tree',
	NAME			=> 'Class::Tree',
	PL_FILES		=> {},
	PREREQ_PM		=>
	{
		Carp		=> 0,
		Config		=> 0,
		Cwd			=> 0,
		File::Find	=> 0,
		Test::More	=> 0,
		Test::Pod	=> 0,
	},
	VERSION_FROM	=> 'lib/Class/Tree.pm'
);

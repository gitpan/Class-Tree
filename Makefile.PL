use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
	($] ge '5.005') ?
	(
		'AUTHOR' => 'Ron Savage (rpsavage@ozemail.com.au)',
		'ABSTRACT' => 'C++ class hierarchies & disk directories',
    ) : (),
'clean'				=>
	{
	'FILES'			=> 'blib/* Makefile MANIFEST Class-Tree-*'
	},
'dist'				=>
	{
	'COMPRESS'		=> 'gzip',
	'SUFFIX'		=> 'gz'
	},
'DISTNAME'			=> 'Class-Tree',
'NAME'				=> 'Class::Tree',
'PM'				=>
	{
	'Tree.pm'	 	=> '$(INST_LIBDIR)/Tree.pm',
	},
'PREREQ_PM'			=> {},
'VERSION_FROM'		=> 'Tree.pm'
);

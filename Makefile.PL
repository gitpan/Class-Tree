use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.

WriteMakefile
(
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

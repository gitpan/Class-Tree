#!/usr/gnu/bin/perl -w

use ExtUtils::MakeMaker;

WriteMakefile
(
'clean'				=>
	{
	'FILES'			=> 'blib/* Makefile MANIFEST Class-Tree*'
	},
'dist'				=>
	{
	'COMPRESS'		=> 'gzip',
	'SUFFIX'		=> 'gz',
	},
'DISTNAME'			=> 'Class-Tree',
'NAME'				=> 'Class::Tree',
'PM'				=>
	{
	'Tree.pm'	 		=> '$(INST_LIBDIR)/Tree.pm',
	'testCppTree.pl'	=> '$(INST_LIBDIR)/testCppTree.pl',
	'testDirTree.pl'	=> '$(INST_LIBDIR)/testDirTree.pl',
	},
'VERSION_FROM'		=> 'Tree.pm',
);

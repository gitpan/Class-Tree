#!/usr/bin/perl
#
# Name:
#	test.pl.
#
# Purpose:
#	Print a directory tree and a class tree.

use strict;
no strict 'refs';
use warnings;

use Class::Tree qw($root);
use Cwd;

# ----------------------------------------------------------------------

sub printTree
{
	my($root, $level) = @_;

	$level++;

	my($key);

	for $key (sort(keys(%$root) ) )
	{
		print "\t" x $level, "$key\n";
		&printTree($$root{$key}, $level);
	}

}	# End of printTree.

# ----------------------------------------------------------------------

# 1. dirTree.pl.

print "Testing a directory tree. \n";

my($dir1)	= cwd();
$dir1		= cwd() if ($dir1 eq '.');

die("Failure: $dir1 does not exist\n") if (! -e $dir1);

my($tree1) = new Class::Tree;

$tree1 -> buildDirTree($dir1, ['CVS', 'bin']);

$tree1 -> writeTree();

# Access the tree via the root.
# Ignored directories are not in $root.
print "\n";

&printTree($root, -1);

print '=' x 70, "\n";

# 2. cppTree.pl.

exit(0) if (! $ENV{'PERCEPS'});

print "Testing a C++ tree. \n";

my($font) = 'Vacuum';

my($dir2)		= 't';
$dir2			= cwd() if ($dir2 eq '.');
my($currentDir)	= cwd();

die("Failure: $dir2 does not exist\n") if (! -e $dir2);

my($tree2) = new Class::Tree;

$tree2 -> buildClassTree($dir2, $font, $currentDir);

print "Class tree\n----------\n";
$tree2 -> writeTree();
print "\n";

print "Class list\n----------\n";
$tree2 -> writeClassList();

print '=' x 70, "\n";

# Success.
exit(0);

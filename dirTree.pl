#!/usr/gnu/bin/perl -w
#
# Name:
#	test.pl.
#
# Purpose:
#	Print a directory tree.
#
# Parameter:
#	The directory to operate in.

use integer;
use strict;
no strict 'refs';

use Class::Tree qw($root);
use Cwd;
use Getopt::Simple qw($switch);

# ----------------------------------------------------------------------

sub init
{
	my($default) =
	{
	'help' =>
		{
		'type'		=> '',
		'env'		=> '-',
		'default'	=> '',
		'order'		=> 1,
		},
	'ignore' =>
		{
		'type'		=> '=s@',
		'env',		=> '-',
		'default'	=> '',
		'order'		=> 2,
		},
	};

	my($option) = new Getopt::Simple;

	if (! $option -> getOptions($default, "Usage: testDirTree.pl [options]") )
	{
		# Failure.
		exit(-1);
	}

}	# End of init.

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

&init();

my($dir)	= shift || die("Usage: $0 <someDir>");
$dir		= cwd() if ($dir eq '.');

die("Failure: $dir does not exist\n") if (! -e $dir);

my($tree) = new Class::Tree;

$tree -> buildDirTree($dir, $switch -> {'ignore'});

$tree -> writeTree();

# Access the tree via the root.
# Ignored directories are not in $root.
print "\n";

&printTree($root, -1);

# Success.
exit(0);

__END__

=head1 NAME

C<test.pl> - Print a directory hierarchy.

=head1 SYNOPSIS

	...>perl test.pl -i obj -i CVS dirName

=head1 DESCRIPTION

C<test.pl> runs under both Unix and DOS (aka Windows).

C<test.pl> outputs the directory tree starting at the given directory.
The complete path to the given directory is output, but sibling directories
are ignored.

=head1 COMMAND LINE SWITCHES

C<test.pl> provides these switches:

=over 4

=item *

-help. Display help and terminate with exit(0)

=item *

-ignore. Specify a series of directories to ignore. Repeat for each directory

=back

=head1 REQUIRED MODULES

=over 4

=item *

Class::Tree - one of mine

=item *

Getopt::Simple - one of mine

=back

=head1 AUTHOR

C<test.pl> was written by Ron Savage I<E<lt>rpsavage@ozemail.com.auE<gt>> in 1997.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

#!/usr/gnu/bin/perl -w
#
# Name:
#	testCppTree.pl.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Purpose:
#	1. Run Perceps.
#	2. Scan output from Perceps.
#	3. Print reports.
#
# Switches:		Default
#	-help		''
#	-home		$ENV{'HOME'}
#
# Parameters:
#	The name of the directory containing the *.h files. Default: '.'.
#
# Usage:
#	C:\>perl testCppTree.pl Include
#		Include becomes $HOME/Include.
#
# Tabs:
#	4 spaces || die.
#
# Author:
#	Ron Savage. 1.00.	9-Sep-97.
# ----------------------------------------------------------------------

use integer;
use strict 'vars';

use Class::Tree;
use Cwd;

require 'projectLib.pl';

# ----------------------------------------------------------------------

my($font) = 'Vacuum';

my($dir, $exists) = &prepareDir($ARGV[0]);

die("Failure: $dir does not exist\n") if (! -e $dir);

my($tree) = new Class::Tree;

$tree -> buildClassTree($dir, $font);

print "Class tree\n----------\n";
$tree -> writeTree();
print "\n";

print "Class list\n----------\n";
$tree -> writeClassList();

exit(0);

__END__

=head1 NAME

C<testCppTree.pl> - Print a C++ class hierarchy.

=head1 SYNOPSIS

	...>perl testCppTree.pl project/include

=head1 DESCRIPTION

C<testCppTree.pl> runs under both Unix and DOS (aka Windows).

C<testCppTree.pl> runs Perceps on a directory of *.h files and
processes the output to produce a report on the classes found.

It's limitations are the same of those of Perceps.

Perceps is a Perl program which parses *.h files and outputs a report
formatted according to a template you define. C<testCppTree.pl> contains a
template so that it knows the format of the Perceps output.

You can find Perceps at http://friga.mer.utexas.edu/mark/perl/perceps/.

The DOS and Unix paths to Perceps are in sub perceps, and will need to be
changed by you.

=head1 REQUIRED MODULES

=over 4

=item *

Class::Tree - one of mine

=item *

projectLib.pl - one of mine

=back

=head1 AUTHOR

C<testCppTree.pl> was written by Ron Savage I<E<lt>rpsavage@ozemail.com.auE<gt>> in 1997.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

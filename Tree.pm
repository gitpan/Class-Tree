package Class::Tree;

# Name:
#	Class::Tree.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Note:
#	tab = 4 spaces || die.
#
# Author:
#	Ron Savage <ron@savage.net.au>
#	Home page: http://savage.net.au/index.html
#
# Licence:
#	Australian Copyright (c) 1999-2002 Ron Savage.
#
#	All Programs of mine are 'OSI Certified Open Source Software';
#	you can redistribute them and/or modify them under the terms of
#	The Artistic License, a copy of which is available at:
#	http://www.opensource.org/licenses/index.html

use strict;
no strict 'refs';
use vars qw($root $VERSION @ISA @EXPORT @EXPORT_OK);

use Carp;
use Config;
use Cwd;
use File::Find;

require Exporter;

@ISA = qw(Exporter);

# Items to export into callers namespace by default. Note: do not export
# names by default without a very good reason. Use EXPORT_OK instead.
# Do not simply export all your public functions/methods/constants.

@EXPORT		= qw();

@EXPORT_OK	= qw($root);	# An alias for $self -> {'root'}.

$VERSION	= '1.21';

# Preloaded methods go here.

#-------------------------------------------------------------------

sub buildClassTree
{
	my($self, $dir, $fontName, $baseDir) = @_;

	# Normalize $dir.
	my($currentDir) = cwd();
	chdir($dir) || croak("Can't chdir($dir): $!");
	$dir = cwd();

	$self -> {'fontName'} = $fontName if (defined($fontName) );

	$self -> perceps($dir, $baseDir);

	$self -> processDirectory($self -> readDirectory($dir, $baseDir) );

	$self -> processParents(0, $self -> {'fontName'}, $self -> {'fontName'});

	$self -> removeDuplicates();

	$self -> evalClassTree();

	($self -> {'last'} -> {$self -> {'rootName'} }, $self -> {'kids'} -> {$self -> {'rootName'} }) =
		$self -> processTree(0, $root, $self -> {'rootName'} );

	chdir($currentDir) || croak("Can't chdir($currentDir): $!");

}	# End of buildClassTree.

#-------------------------------------------------------------------

sub buildDirTree
{
	my($self, $dir, $dir2Ignore) = @_;

	find(\&foundDir, $dir);

	for $dir (@$dir2Ignore)
	{
		$self -> {'ignore'}{$dir} = 1;
	}

	$self -> evalDirTree();

	($self -> {'last'} -> {$self -> {'rootName'} }, $self -> {'kids'} -> {$self -> {'rootName'} }) =
		$self -> processTree(0, $root, $self -> {'rootName'} );

}	# End of buildDirTree.

# ----------------------------------------------------------------------

sub evalClassTree
{
	my($self) = @_;

	my($dir, @dir, $code);

	for $dir (sort(@{$self -> {'found'} }) )
	{
		@dir	= split(/\//, $dir);
		$code	= "\$self -> {'root'} -> ";

		my($part);

		for $part (@dir)
		{
			$code .= "{'$part'}";
		}

		$code .= ' = {}';
		eval $code;
		croak($@) if $@;
	}

}	# End of evalClassTree.

# ----------------------------------------------------------------------

sub evalDirTree
{
	my($self) = @_;

	my($dir, @dir, $code);

	for $dir (sort(keys(%{$Class::Tree -> {'dir'} }) ) )
	{
		# Use substr x 2 to cope with DOS (C:...) and Unix (/...).
		@dir	= split(/\//, substr($dir, 1) );
		$dir[0]	= substr($dir, 0, 1) . $dir[0];
		$code	= "\$self -> {'root'} -> ";

		my($ignoreDir) = 0;
		my($part);

		for $part (@dir)
		{
			$code	.= "{'$part'}";
			$ignoreDir	= 1 if ($self -> {'ignore'}{$part});
		}

		eval "$code = {}" if (! $ignoreDir);
		croak($@) if $@;
	}

}	# End of evalDirTree.

#-------------------------------------------------------------------

sub foundDir
{
	my($dir) = $File::Find::dir;

	$dir =~ tr|\\|/|;

	$Class::Tree -> {'dir'}{$dir} = 1;

}	# End of foundDir.

#-------------------------------------------------------------------

sub new
{
	my($class)				= @_;
	my($self)				= {};
	$self -> {'class'}		= {};
	$self -> {'dir'}		= {};
	$self -> {'fontName'}	= {};
	$self -> {'found'}		= [];
	$self -> {'ignore'}		= {};
	$self -> {'kids'}		= {};
	$self -> {'last'}		= {};
	$self -> {'parent'}		= {};
	$self -> {'prefix'}		= [];
	$self -> {'root'}		= {};
	$root					= $self -> {'root'};		# An alias for $self -> {'root'}.
	$self -> {'rootName'}	= '';

	return bless $self, $class;

}	# End of new.

# ----------------------------------------------------------------------

sub perceps
{
	my($self, $dirName, $baseDir) = @_;

	chdir($dirName) || croak("Can't chdir($dirName): $!");

	# Create Perceps template file. Perceps creates *.report.
	my($fileName) = 'CLASS.report.tmpl';

	if (! open(OUT, "> $fileName") )
	{
		carp("Can't open($fileName) for writing: $! \nTrying current directory \n");
		$fileName	= $baseDir . $fileName;
		$dirName	= $baseDir;
		open(OUT, "> $fileName") || croak("Can't even open($fileName) for writing: $!");
	}

	print OUT "{class} {parents}\n";
	close(OUT);

	# Run Perceps.
	croak('Environment variable PERCEPS=<Dir of perceps[.pl]> not set') if (! defined($ENV{'PERCEPS'}) );
	my($perceps)	= "$ENV{'PERCEPS'}/perceps";
	$perceps		.= '.pl' if (! -e $perceps);
	croak('$perceps not found') if (! -e $perceps);
	system('perl', "$perceps -q -f -d $dirName") if ($Config{'osname'} eq 'MSWin32');
	system("$perceps -q -f -d $dirName") if ($Config{'osname'} ne 'MSWin32');

	# Delete the template file & the .perceps file, leaving *.report.
	unlink $fileName;
	unlink "$dirName/.perceps";

}	# End of perceps.

# ----------------------------------------------------------------------

sub processDirectory
{
	my($self, $line) = @_;

	for (@$line)
	{
		my(@field);

		# Format: "<Class> [public <Name>[,private <Name>]]\n".
		tr|,| |;
		@field	= split;
		@field	= reverse grep(! /(public|private|protected|virtual)/, @field);

		my($i, $name);

		for ($i = 0; $i <= $#field; $i++)
		{
			$name = $field[$i];

			if ($self -> {'parent'}{$name})
			{
				$self -> {'parent'}{$name} = $field[$i - 1]
					if ( ($i > 0) && ($self -> {'parent'}{$name} eq $self -> {'fontName'}) );
			}
			else
			{
				$self -> {'parent'}{$name} = $self -> {'fontName'} if ($i == 0);
				$self -> {'parent'}{$name} = $field[$i - 1] if ($i > 0);
			}
		}
	}

}	# End of processDirectory.

# ----------------------------------------------------------------------

sub processParents
{
	my($self, $indent, $font, $path) = @_;

	$indent++;

	push(@{$self -> {'found'} }, $path);

	my($key);

	for $key (sort(keys(%{$self -> {'parent'} }) ) )
	{
		$self -> {'class'}{$key} = 1;
		$self -> processParents($indent, $key, "$path/$key")
			if ($self -> {'parent'}{$key} eq $font);
	}

	$indent--;

}	# End of processParents.

# ----------------------------------------------------------------------

sub processTree
{
	my($self, $indent, $root, $path) = @_;

	$indent++;

	my($name, $childCount, $fullName);

	$childCount	= 0;
	$fullName	= '';

	for $name (sort(keys(%$root) ) )
	{
		$childCount++;
		$fullName = "$path$name/";

		if (ref($root -> {$name}) )
		{
			($self -> {'last'} -> {$fullName}, $self -> {'kids'} -> {$fullName}) =
				$self -> processTree($indent, $root -> {$name}, $fullName);
		}
	}

	$indent--;

	# Return the last child's name & the number of children.
	($fullName, $childCount);

}	# End of processTree.

# ----------------------------------------------------------------------

sub readDirectory
{
	my($self, $dirName, $baseDir) = @_;

	# Read all report file names.
	my(@reportFile)	= glob("$dirName/*.report");
	@reportFile		= glob("$baseDir/*.report") if ($#reportFile < 0);

	croak("Can't find perceps output in either $dirName or $baseDir") if ($#reportFile < 0);

	# Process each member-type file.
	my($fileName, $line);

	$line = ();

	for $fileName (@reportFile)
	{
		# Read the 1st line in this file.
		open(INX, $fileName) || croak("Can't open $fileName: $!");
		$_ = <INX>;
		close(INX);
		chomp($_);

		unlink $fileName;

		push(@$line, $_);
	}

	$line;

}	# End of readDirectory.

# ----------------------------------------------------------------------

sub removeDuplicates
{
	my($self) = @_;

	my($i, $length);

	for ($i = 0; $i < $#{$self -> {'found'} }; $i++)
	{
		$length = length($self -> {'found'}[$i]);

		if ($self -> {'found'}[$i] eq substr($self -> {'found'}[$i + 1], 0, length) )
		{
			my($j);

			for ($j = $i; $j < $#{$self -> {'found'} }; $j++)
			{
				$self -> {'found'}[$j] = $self -> {'found'}[$j + 1];
			}

			splice(@{$self -> {'found'} }, $#{$self -> {'found'} }, 1);
			$i--;
		}
	}

}	# End of removeDuplicates.

# ----------------------------------------------------------------------

sub writeClassList
{
	my($self) = @_;

	my($count) = 0;

	for (sort(keys(%{$self -> {'class'} }) ) )
	{
		$count++;
		printf("%3d ", $count);
		print $_, ' ' x (24 - length);
		print "\n" if ( ($count % 3) == 0);
	}

	print "\n" if ( ($count %3) != 0);

}	# End of writeClassList.

# ----------------------------------------------------------------------

sub writeTree
{
	push(@_, 0, $root, undef) if ($#_ == 0); # Can't init $path until $self is known.

	my($self, $indent, $root, $path) = @_;

	$path = $self -> {'rootName'} if (! defined($path) );

	$indent++;

	$self -> {'prefix'}[$indent] = '+---';

	my($name, $childCount, $fullName, $line);

	$childCount = 0;

	for $name (sort(keys(%$root) ) )
	{
		$childCount++;
		$fullName		= "$path$name/";
		my($leading)	= join('', @{$self -> {'prefix'} }[1 .. ($indent - 1)]);

		$line = $leading;
		$line =~ tr/-+/ |/;
		print "$line\n" if ($line);

		$line = "$leading$name";
		print "$line\n";

		$self -> {'prefix'}[$indent - 1]	= '    ' if ($fullName eq $self -> {'last'} -> {$path});
		$self -> {'prefix'}[$indent - 1]	= '|   ' if ($fullName ne $self -> {'last'} -> {$path});

		if (ref($root -> {$name}) )
		{
			$self -> writeTree($indent, $root -> {$name}, $fullName);
			$self -> {'prefix'}[$indent - 1] = '+---';
		}
	}

	$indent--;

}	# End of writeTree.

# --------------------------------------------------------------------------

# Autoload methods go after =cut, and are processed by the autosplit program.

1;

__END__

=head1 NAME

C<Class::Tree> - Build and print hierarchical information such as directory trees
and C++ classes.

=head1 SYNOPSIS

	use Class::Tree;

	# Or ...
	# use Class::Tree qw($root);

	# 1. A directory tree.
	my($dir1)  = 'someDir/someSubdir';
	my($tree1) = new Class::Tree;
	$tree1 -> buildDirTree($dir1, ['CVS']);
	$tree1 -> writeTree();

	# 2. A C++ class tree.
	use Cwd;
	my($currentDir) = cwd();
	my($dir2)       = 'someDir/someSubdir'; # Contains *.h. See t/family.h.
	my($origin)     = 'Root';
	my($tree2)      = new Class::Tree;
	$tree2 -> buildClassTree($dir2, $origin, $currentDir);
	print "Class tree\n----------\n";
	$tree2 -> writeTree();
	print "\n";
	print "Class list\n----------\n";
	$tree2 -> writeClassList();

=head1 DESCRIPTION

The C<Class::Tree> module provides a simple way of building:

=over 4

=item *

Directory trees

=item *

C++ class trees

=back

=head1 ENVIRONMENT VARIABLE PERCEPS

I assume $ENV{'PERCEPS'} is the directory containing the C++ parser perceps,
or perceps.pl. So, you must define this variable before calling buildClassTree().

=head1 THE HASH REFERENCE $classRef -> {'root'}

This is an alias for $root. See below.

=head1 THE HASH REFERENCE $root

This points to the root of the tree.

=head1 METHOD: buildClassTree($dir, $fontName, $baseDir)

Call this to initiate processing by the C++ parser 'perceps'.

The directories $dir and $baseDir are passed to 'perceps'.

$fontName is a string used to label the root of the tree.

Then call writeTree() and/or writeClassList().

=head1 METHOD: buildDirTree($dir, [qw/dirs to ignore/])

Call this to build a memory image of a directory tree. Use the 2nd parameter
to specify a list of directories to ignore.

Then call writeTree().

=head1 METHOD: writeClassList()

Call this after calling buildClassTree(), to print the C++ class structure.

=head1 METHOD: writeTree()

Call this after calling buildClassTree() or buildDirTree(),
to print the directory structure.

=head1 INSTALLATION

You install C<Class::Tree>, as you would install any perl module library,
by running these commands:

	perl Makefile.PL
	make
	make test
	make install

If you want to install a private copy of C<Class::Tree> in your home
directory, then you should try to produce the initial Makefile with
something like this command:

	perl Makefile.PL LIB=~/perl
		or
	perl Makefile.PL LIB=C:/Perl/Site/Lib

If, like me, you don't have permission to write man pages into unix system
directories, use:

	make pure_install

instead of make install. This option is secreted in the middle of p 414 of the
second edition of the dromedary book.

=head1 WARNING re Perl bug

As always, be aware that these 2 lines mean the same thing, sometimes:

=over 4

=item *

$self -> {'thing'}

=item *

$self->{'thing'}

=back

The problem is the spaces around the ->. Inside double quotes, "...", the
first space stops the dereference taking place. Outside double quotes the
scanner correctly associates the $self token with the {'thing'} token.

I regard this as a bug.

=head1 AUTHOR

C<Class::Tree> was written by Ron Savage I<E<lt>ron@savage.net.auE<gt>> in 1997.

=head1 LICENCE

Australian copyright (c) 1999-2002 Ron Savage.

	All Programs of mine are 'OSI Certified Open Source Software';
	you can redistribute them and/or modify them under the terms of
	The Artistic License, a copy of which is available at:
	http://www.opensource.org/licenses/index.html

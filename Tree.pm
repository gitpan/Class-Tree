package Class::Tree;

# Name:
#	Class::Tree.
#
# Documentation:
#	POD-style documentation is at the end. Extract it with pod2html.*.
#
# Tabs:
#	4 spaces || die.
#
# Author:
#	Ron Savage	rpsavage@ozemail.com.au.
# --------------------------------------------------------------------------

use strict;
no strict 'refs';

use vars qw(@EXPORT @EXPORT_OK @ISA);
use vars qw($root $VERSION);

use Carp;
use Config;
use Exporter;
use File::Find;

@ISA		= qw(Exporter);
@EXPORT		= qw();
@EXPORT_OK	= qw($root);	# An alias for $self -> {'root'}.

# --------------------------------------------------------------------------

$VERSION    = '1.10';

#-------------------------------------------------------------------

sub buildClassTree
{
	my($self, $dir, $fontName, $baseDir) = @_;

	$self -> {'fontName'} = $fontName if (defined($fontName) );

	$self -> perceps($dir, $baseDir);

	$self -> processDirectory($self -> readDirectory($dir, $baseDir) );

	$self -> processParents(0, $self -> {'fontName'}, $self -> {'fontName'});

	$self -> removeDuplicates();

	$self -> evalClassTree();

	($self -> {'last'} -> {$self -> {'rootName'} }, $self -> {'kids'} -> {$self -> {'rootName'} }) =
		$self -> processTree(0, $root, $self -> {'rootName'} );

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
		die $@ if $@;
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
		die $@ if $@;
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

	chdir($dirName) || die("Can't chdir($dirName): $!");

	# Create Perceps template file. Perceps creates *.report.
	my($fileName) = 'CLASS.report.tmpl';

	if (! open(OUT, "> $fileName") )
	{
		carp("Can't open($fileName) for writing: $! \nTrying current directory \n");
		$fileName	= $baseDir . $fileName;
		$dirName	= $baseDir;
		open(OUT, "> $fileName") || croak("Can't even open($fileName) for writing: $!\n");  
	}

	print OUT "{class} {parents}\n";
	close(OUT);

	# Run Perceps.
	system('perl', "$ENV{'PERCEPS'}/perceps.pl -q -f -d $dirName") if ($Config{'osname'} eq 'MSWin32');
	system("$ENV{'PERCEPS'}/perceps.pl -q -f -d $dirName") if ($Config{'osname'} ne 'MSWin32');

	# Delete the template file & the .perceps file, leaving *.report.
	unlink $fileName;
	unlink "$dirName.perceps";

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
	my(@reportFile)	= glob("$dirName*.report");
	@reportFile		= glob("$baseDir*.report") if ($#reportFile < 0);

	croak("Can't find perceps output in either $dirName or $baseDir\n") if ($#reportFile < 0);

	# Process each member-type file.
	my($fileName, $line);

	$line = ();

	for $fileName (@reportFile)
	{
		# Read the 1st line in this file.
		open(INX, $fileName) || die "Can't open $fileName: $!. \n";
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

1;

__END__

=head1 NAME

C<Class::Tree> - Build and print hierarchical information such as directory trees
and C++ classes.

=head1 SYNOPSIS

	use Class::Tree;

	# Or ...
	# use Class::Tree qw($root);

	my($tree) = new Class::Tree;


=head1 DESCRIPTION

The C<Class::Tree> module provides a simple way of building:

=over 4

=item *

Directory trees

=item *

C++ class trees

=back

=head1 The $classRef -> {'root'} hash reference

This is an alias for $root. See below.

=head1 The $root hash reference

This points to the root of the tree.

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

=head1 CHANGES

V 1.10 attempts to write to the current directory if it cannot write to the directory
containing the *.h files. This makes it possible to run testCppTree.pl (say) and input
a directory on CDROM. This patch requires

=head1 AUTHOR

C<Class::Tree> was written by Ron Savage I<E<lt>rpsavage@ozemail.com.auE<gt>> in 1997.

=head1 LICENCE

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

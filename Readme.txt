NAME
    "Class::Tree" - Build and print hierarchical information such as
    directory trees and C++ classes.

SYNOPSIS
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

DESCRIPTION
    The "Class::Tree" module provides a simple way of building:

    *   Directory trees

    *   C++ class trees

ENVIRONMENT VARIABLE PERCEPS
    I assume $ENV{'PERCEPS'} is the directory containing the C++ parser
    perceps, or perceps.pl. So, you must define this variable before calling
    buildClassTree().

THE HASH REFERENCE $classRef -> {'root'}
    This is an alias for $root. See below.

THE HASH REFERENCE $root
    This points to the root of the tree.

METHOD: buildClassTree($dir, $fontName, $baseDir)
    Call this to initiate processing by the C++ parser 'perceps'.

    The directories $dir and $baseDir are passed to 'perceps'.

    $fontName is a string used to label the root of the tree.

    Then call writeTree() and/or writeClassList().

METHOD: buildDirTree($dir, [qw/dirs to ignore/])
    Call this to build a memory image of a directory tree. Use the 2nd
    parameter to specify a list of directories to ignore.

    Then call writeTree().

METHOD: writeClassList()
    Call this after calling buildClassTree(), to print the C++ class
    structure.

METHOD: writeTree()
    Call this after calling buildClassTree() or buildDirTree(), to print the
    directory structure.

INSTALLATION
    You install "Class::Tree", as you would install any perl module library,
    by running these commands:

            perl Makefile.PL
            make
            make test
            make install

    If you want to install a private copy of "Class::Tree" in your home
    directory, then you should try to produce the initial Makefile with
    something like this command:

            perl Makefile.PL LIB=~/perl
                    or
            perl Makefile.PL LIB=C:/Perl/Site/Lib

    If, like me, you don't have permission to write man pages into unix
    system directories, use:

            make pure_install

    instead of make install. This option is secreted in the middle of p 414
    of the second edition of the dromedary book.

WARNING re Perl bug
    As always, be aware that these 2 lines mean the same thing, sometimes:

    *   $self -> {'thing'}

    *   $self->{'thing'}

    The problem is the spaces around the ->. Inside double quotes, "...",
    the first space stops the dereference taking place. Outside double
    quotes the scanner correctly associates the $self token with the
    {'thing'} token.

    I regard this as a bug.

AUTHOR
    "Class::Tree" was written by Ron Savage *<ron@savage.net.au>* in 1997.

LICENCE
    Australian copyright (c) 1999-2002 Ron Savage.

            All Programs of mine are 'OSI Certified Open Source Software';
            you can redistribute them and/or modify them under the terms of
            The Artistic License, a copy of which is available at:
            http://www.opensource.org/licenses/index.html

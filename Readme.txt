NAME
    `Class::Tree' - Build and print hierarchical information such as
    directory trees and C++ classes.

SYNOPSIS
            use Class::Tree;

            # Or ...
            # use Class::Tree qw($root);

            my($tree) = new Class::Tree;

DESCRIPTION
    The `Class::Tree' module provides a simple way of building:

    *   Directory trees

    *   C++ class trees

The $classRef -> {'root'} hash reference
    This is an alias for $root. See below.

The $root hash reference
    This points to the root of the tree.

INSTALLATION
    You install `Class::Tree', as you would install any perl module
    library, by running these commands:

            perl Makefile.PL
            make
            make test
            make install

    If you want to install a private copy of `Class::Tree' in your
    home directory, then you should try to produce the initial
    Makefile with something like this command:

            perl Makefile.PL LIB=~/perl
                    or
            perl Makefile.PL LIB=C:/Perl/Site/Lib

    If, like me, you don't have permission to write man pages into
    unix system directories, use:

            make pure_install

    instead of make install. This option is secreted in the middle
    of p 414 of the second edition of the dromedary book.

WARNING re Perl bug
    As always, be aware that these 2 lines mean the same thing,
    sometimes:

    *   $self -> {'thing'}

    *   $self->{'thing'}

    The problem is the spaces around the ->. Inside double quotes,
    "...", the first space stops the dereference taking place.
    Outside double quotes the scanner correctly associates the $self
    token with the {'thing'} token.

    I regard this as a bug.

CHANGES
    V 1.10 attempts to write to the current directory if it cannot
    write to the directory containing the *.h files. This makes it
    possible to run testCppTree.pl (say) and input a directory on
    CDROM.

AUTHOR
    `Class::Tree' was written by Ron Savage
    *<rpsavage@ozemail.com.au>* in 1997.

LICENCE
    This program is free software; you can redistribute it and/or
    modify it under the same terms as Perl itself.


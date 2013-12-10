# NAME

App::EditorTools - Command line tool for Perl code refactoring

# VERSION

version 0.18

# DESCRIPTION

`App::EditorTools` provides the `editortools` command line program that
enables programming editors (Vim, Emacs, etc.) to take advantage of some
sophisticated Perl refactoring tools. The tools utilize [PPI](https://metacpan.org/pod/PPI) to analyze
Perl code and make intelligent changes. As of this release, `editortools` 
is able to:

- Lexically Rename a Variable
- Introduce a Temporary Variable 
- Rename the Package Based on the Path of the File

More refactoring tools are expected to be added in the future.

# NAME

App::EditorTools - Command line tool for Perl code refactoring

# BACKGROUND

The [Padre](https://metacpan.org/pod/Padre) Perl editor team developed some very interesting [PPI](https://metacpan.org/pod/PPI) based
refactoring tools for their editor. Working with the [Padre](https://metacpan.org/pod/Padre) team, those
routines were abstracted into [PPIx::EditorTools](https://metacpan.org/pod/PPIx::EditorTools) in order to make them 
available to alternative editors.

The initial implementation was developed for Vim. Pat Regan contributed
the emacs bindings. Other editor bindings are encouraged/welcome.

# REFACTORINGS

The following lists the refactoring routines that are currently supported.
Please see [App::EditorTools::Vim](https://metacpan.org/pod/App::EditorTools::Vim) or [App::EditorTools::Emacs](https://metacpan.org/pod/App::EditorTools::Emacs) to
learn how to install the bindings and the short cuts to use within your
editor. The command line interface should only be needed to develop the
editor bindings.

Each command expects the Perl program being edited to be piped in via
STDIN. The refactored code is output on STDOUT.

- RenameVariable

        editortools renamevariable -c col -l line -r newvar 

    Renames the variable at column `col` and line `line` to `newvar`. Unlike
    editors typical find and replace, this is aware of lexical scope and only
    renames those variables within same scope. For example, given:

        my $x = 'text';
        for my $x (1..3){
            print $x;
        }
        print $x;

    The command `editortools renamevariable -c 3 -l 12 -r counter` will result in:

        my $x = 'text';
        for my $counter (1..3){
            print $counter;
        }
        print $x;

- IntroduceTemporaryVariable

        editortools introducetemporaryvariable -s line1,col1 -e line2,col2 -v varname

    Removes the expression between line1,col1 and line2,col2 and replaces it
    with the temporary variable `varname`. For example, given:

        my $x = 1 + (10 / 12) + 15;
        my $y = 3 + (10 / 12) + 17;

    The command `editortools introducetemporaryvariable -s 1,13 -e 1,21 -v foo` 
    will yield:

        my $foo = (10 / 12);
        my $x = 1 + $foo + 15;
        my $y = 3 + $foo + 17;

- RenamePackageFromPath

        editortools renamepackagefrompath -f filename

    Change the `package` declaration in the current file to reflect `filename`.
    Typically this is used when you want to rename a module. Move the module to a
    new location and pass the new filename to the `editortools` command.  For
    example, if you are editing `lib/App/EditorTools.pm` the package declaration
    will be changed to `package App::EditorTools;`. At the moment there must be a
    valid package declaration in the file for this to work.

    If the `filename` is a file that exists in the system, then
    `renamepackagefrompath` will attempt to resolve any symlinks. This allows us
    work on files under a symlink (ie, M@ -> lib/App/Model), but rename them
    correctly.

- RenamePackage

        editortools renamepackage -n Package::Name

    Change the `package` declaration in the current file to Package::Name.  At the
    moment there must be a valid package declaration in the file for this to work.

# SEE ALSO

[http://code-and-hacks.blogspot.com/2009/07/stealing-from-padre-for-vim-part-3.html](http://code-and-hacks.blogspot.com/2009/07/stealing-from-padre-for-vim-part-3.html),
[PPIx::EditorTools](https://metacpan.org/pod/PPIx::EditorTools), [Padre](https://metacpan.org/pod/Padre)

# BUGS

Please report any bugs or suggestions at 
[http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-EditorTools](http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-EditorTools)

# AUTHOR

Mark Grimes, <mgrimes@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2013 by Mark Grimes, <mgrimes@cpan.org>.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

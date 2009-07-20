=pod

=head1 NAME

App::EditorTools::Vim - Vim script to integrate with App::EditorTools

=head1 SYNOPSIS
    
    perl -MApp::EditorTools::Vim -e run > $HOME/.vim/ftplugin/editortools.vim

=head1 DESCRIPTION

Place the vim script in C<DATA> in
C<$HOME/.vim/ftplugin/perl/editortools.vim>
(or similar on non-unix systems). Running

    perl -MApp::EditorTools::Vim -e run > $HOME/.vim/ftplugin/editortools.vim

should dump the script to the correct file.

=head1 MAPPINGS

=over 4

=item ,pp

EditorToolsMenu

=item ,pL

RenameVariable

=item ,pP

RenamePackageFromPath

=item ,pI

IntroduceTemporaryVariable

=back

=head1 SEE ALSO

Also see L<PPIx::EditorTools>, L<Padre>, and L<PPI>.

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Mark Grimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

our $VERSION = '0.04';

sub run {
    print <<END_INTRO;
" App::EditorTools::Vim generated script
" Version: $VERSION
END_INTRO
    print while (<DATA>);
}

1;

__DATA__

map ,pp :call EditorToolsMenu()<cr>
map ,pL :call RenameVariable()<cr>
map ,pP :call RenamePackageFromPath()<cr>
map ,pI :call IntroduceTemporaryVariable()<cr>

function! EditorToolsMenu()
    let list = [ "RenameVariable", "RenamePackageFromPath", "IntroduceTemporaryVariable" ]
    let command = PickFromList( "EditorTools Command", list )
    if command == ""
        echo "cancelling"
        return
    endif

    let Fn = function(command)
    call Fn()
endfunction


function! RenameVariable()
    let newvar = input("New variable name? ")
    if newvar == ""
        echo "cancelling"
        return
    endif

    let line = line('.')
    " should backtrack to $ or % or the like
    let col  = col('.')
    let filename = expand('%')

    let command = "editortools-vim renamevariable -c " . col . " -l " . line  . " -r " . newvar 

    call Exec_command_and_replace_buffer( command )
endfunction

function! RenamePackageFromPath()
    let line = line('.')
    let col  = col('.')
    let filename = expand('%')

    let command = "editortools-vim renamepackagefrompath -f " . filename 

    call Exec_command_and_replace_buffer( command )
endfunction

function! IntroduceTemporaryVariable() range
    let start_pos = getpos("'<")
    let end_pos = getpos("'>")

    let start_str = start_pos[1] . "," . start_pos[2]
    let end_str = end_pos[1] . "," . end_pos[2]

    let varname = input("Name for temporary variable? ")
    let cmd = "editortools-vim introducetemporaryvariable -s " . start_str . " -e " . end_str
    if varname != ""
        let cmd .= " -v " . varname
    endif

    call Exec_command_and_replace_buffer( cmd )
endfunction

" Utility functions -------------

" Execute a command using the shell and replace the entire buffer
" with the retuned contents. TODO: Needs error handling
function! Exec_command_and_replace_buffer(command)
    " echo a:command

    let buffer_contents = join( getline(1,"$"), "\n" )
    let result_str = system(a:command, buffer_contents )
    let result = split( result_str, "\n" )
    call setline( 1, result )
endfunction

" Ovid's function to implement a simple menu
function! PickFromList( name, list, ... )
    let forcelist = a:0 && a:1 ? 1 : 0

    if 1 == len(a:list) && !forcelist
        let choice = 0
    else
        let lines = [ 'Choose a '. a:name . ':' ]
            \ + map(range(1, len(a:list)), 'v:val .": ". a:list[v:val - 1]')
        let choice  = inputlist(lines)
        if choice > 0 && choice <= len(a:list)
            let choice = choice - 1
        else
            let choice = choice - 1
        endif
    end

    return a:list[choice]
endfunction

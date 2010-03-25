package App::EditorTools::Command::InstallVim;

use strict;
use warnings;

use App::EditorTools -command;
use File::Basename;
use File::Path qw(mkpath);
use File::Slurp;
use File::HomeDir;
use IPC::Cmd qw(run);

our $VERSION = '0.07';

sub command_names { 'install-vim' }

sub opt_spec {
    return (
        [ "local|l",  "Install the vim script local for the user (~/.vim/)" ],
        [ "dest|d=s", "Full path to install the vim script" ],
        [ "print|p",  "Print the vim script to STDOUT" ],
        [ "dryrun|n", "Print where the vim script would be installed" ],
        ## [ "global|g", "Install the vim script globally (/usr/share/vim)" ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    $self->_confirm_one_opt($opt)
      or $self->usage_error(
        "Options --local, --global, --dest and --print cannot be combined");

    if ( !$opt->{dest} ) {
        if ( $opt->{global} ) {
            $opt->{dest} = File::Spec->catfile( $self->_get_vimruntime,
                qw(ftplugin perl editortools.vim) );

        } elsif ( !$opt->{print} ) {
            $opt->{dest} = File::Spec->catfile(
                File::HomeDir->my_home,
                ( $^O eq 'MSWin32' ? 'vimfiles' : '.vim' ),
                qw(ftplugin perl editortools.vim)
            );
        }
    }

    return 1;
}

sub execute {
    my ( $self, $opt, $arg ) = @_;

    print STDERR "Installing vim script to:\n";
    print STDERR $opt->{dest} || 'STDOUT';
    print STDERR "\n";

    return if $opt->{dryrun};

    if ( $opt->{dest} ) {
        $self->_mkdir( $opt->{dest} );

        # TODO: overwriting?
        open my $fh, ">", $opt->{dest}
          or die "Unable to write to $opt->{dest}: $!";
        $opt->{dest} = $fh;
    }

    $self->_print( $opt->{dest} || *STDOUT );
    return;
}

sub _print {
    my ( $self, $fh ) = @_;

    my $script_as_str = $self->_intro;
    $script_as_str .= eval { local $/ = undef; <DATA> };

    return print $fh $script_as_str;
}

sub _intro {
    return <<"END_INTRO";
" App::EditorTools::Command::InstallVim generated script
" Version: $VERSION
END_INTRO
}

sub _get_vimruntime {
    my $self = shift;

    my $file = 'appeditvim.tmp';
    my $cmd  = qq{vim -c 'redir > $file' -c 'echomsg \$VIMRUNTIME' -c q};

    run( command => $cmd, verbose => 0, )
      or $self->usage_error("Error running vim to find global path");
    my $dest = read_file $file
      or $self->usage_error("Unable to find global vim path");
    unlink $file;

    $dest =~ s{[\n\r]}{}mg;
    return $dest;
}

sub _confirm_one_opt {
    my ( $self, $opt ) = @_;

    my %hash = %$opt;
    return grep( { defined $_ } @hash{qw{dest local global print}} ) <= 1;
}

sub _mkdir {
    my ( $self, $path ) = @_;

    my $dir = dirname $path;

    unless ( -d $dir ) {
        mkpath($dir)
          || die "Unable to create directory $dir: $!\n";
    }

    return 1;
}

sub _count {
    my (@a) = @_;

    my $total = 0;
    for my $a (@a) {
        $total += 1 if defined $a;
    }

    return $total;
}

# Pod if we add the global option
# =item --global
# Install the vim script globally. This will put the script in
# C</usr/share/vim/vim72/ftplugin/perl/editortools.vim> or a similar location
# for your operating system.

=pod

=head1 NAME

App::EditorTools::Command::InstallVim - Install vim script to create bindings to App::EditorTools

=head1 SYNOPSIS
    
    # Install the vim script to create binding to App::EditorTools with:
    editortools install-vim

=head1 DESCRIPTION

This will place the vim script contained in the C<DATA> portion of
App::EditorTools::Command::InstallVim where vim expects it (
C<$HOME/.vim/ftplugin/perl/editortools.vim> for a local install on a
unix-like system)>). 

=head1 OPTIONS

=over 4

=item --local

Install the vim script for the local user only. This will put the script in
C<$HOME/.vim/ftplugin/perl/editortools.vim> or a similar location for your
operating system. This is the default action.

=item --dest

Specify a full path (directory and filename) for the vim script.

=item --print

Print the vim script to STDOUT. 

=item --dryrun

Don't do anything, just print what we would do.

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

1;

__DATA__

" Only do this when not done yet for this buffer
if exists("b:did_ftplugin")
    finish
endif
let b:did_ftplugin = 1

map <buffer> ,pp :call EditorToolsMenu()<cr>
map <buffer> ,pL :call RenameVariable()<cr>
map <buffer> ,pP :call RenamePackageFromPath()<cr>
map <buffer> ,pI :call IntroduceTemporaryVariable()<cr>

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

    let command = "editortools renamevariable -c " . col . " -l " . line  . " -r " . newvar 

    call Exec_command_and_replace_buffer( command )
endfunction

function! RenamePackageFromPath()
    let line = line('.')
    let col  = col('.')
    let filename = expand('%')

    let command = "editortools renamepackagefrompath -f " . filename 
    call Exec_command_and_replace_buffer( command )
endfunction

function! IntroduceTemporaryVariable() range
    let start_pos = getpos("'<")
    let end_pos = getpos("'>")

    let start_str = start_pos[1] . "," . start_pos[2]
    let end_str = end_pos[1] . "," . end_pos[2]

    let varname = input("Name for temporary variable? ")
    let cmd = "editortools introducetemporaryvariable -s " . start_str . " -e " . end_str
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


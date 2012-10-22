package App::EditorTools::Command::InstallEmacs;

use strict;
use warnings;
use parent 'App::EditorTools::CommandBase::Install';

#use App::EditorTools -command;
use File::HomeDir;

our $VERSION = '0.17';

sub command_names { 'install-emacs' }

sub opt_spec {
    return (
        [ "local|l",  "Install the emacs script for the user (~/.emacs.d/)" ],
        [ "dest|d=s", "Full path to install the script" ],
        [ "print|p",  "Print the script to STDOUT" ],
        [ "dryrun|n", "Print where the script would be installed" ],
        ## [ "global|g", "Install the script globally (/usr/share/)" ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;

    $self->_confirm_one_opt($opt)
      or $self->usage_error(
        "Options --local, --global, --dest and --print cannot be combined");

    if ( !$opt->{dest} ) {
        if ( $opt->{global} ) {
            $self->usage_error("--global flag is not implemented");
        } elsif ( !$opt->{print} ) {
            $opt->{dest} =
              File::Spec->catfile( File::HomeDir->my_home,
                ( $^O eq 'MSWin32' ? '_emacs.d' : '.emacs.d' ),
                qw(editortools.el) );
        }
    }

    return 1;
}

sub _script { File::Spec->catfile(qw(emacs editortools.el)) }

sub _intro {
    return <<"END_INTRO";
;;; editortools.el --- make use of App::EditorTools Perl module
;; App::EditorTools::Command::InstallEmacs generated script
;; Version: $VERSION
END_INTRO
}


# Pod if we add the global option
# =item --global
# Install the script globally. This will put the script in
# C</usr/share/...> or a similar location for your operating system.

=pod

=head1 NAME

App::EditorTools::Command::InstallEmacs - Install emacs bindings for App::EditorTools

=head1 SYNOPSIS

    # Install the emacs script to create binding to App::EditorTools with:
    editortools install-emacs

=head1 DESCRIPTION

This will place the emacs script contained in the share dir of this
distribution where emacs expects it ( C<$HOME/.emacs.d/editortools.el> for a
local install on a unix-like system)>).

=head1 OPTIONS

=over 4

=item --local

Install the emacs script for the local user only. This will put the script in
C<$HOME/.emacs.d/editortools.el> or a similar location for your
operating system. This is the default action.

=item --dest

Specify a full path (directory and filename) for the emacs script.

=item --print

Print the emacs script to STDOUT.

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

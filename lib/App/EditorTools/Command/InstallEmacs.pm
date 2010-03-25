package App::EditorTools::Command::InstallEmacs;

use strict;
use warnings;

use App::EditorTools -command;
use File::Basename;
use File::Path qw(mkpath);
use File::Slurp;
use File::HomeDir;
use IPC::Cmd qw(run);

our $VERSION = '0.02';

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
            $opt->{dest} = File::Spec->catfile(
                File::HomeDir->my_home,
                ( $^O eq 'MSWin32' ? '_emacs.d' : '.emacs.d' ),
                qw(editortools.el)
            );
        }
    }

    return 1;
}

sub execute {
    my ( $self, $opt, $arg ) = @_;

    print STDERR "Installing emacs script to:\n";
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
;;; editortools.el --- make use of App::EditorTools Perl module
;; App::EditorTools::Command::InstallEmacs generated script
;; Version: $VERSION
END_INTRO
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
# Install the script globally. This will put the script in
# C</usr/share/...> or a similar location for your operating system.

=pod

=head1 NAME

App::EditorTools::Command::InstallEmacs - Install emacs script to create bindings to App::EditorTools

=head1 SYNOPSIS
    
    # Install the emacs script to create binding to App::EditorTools with:
    editortools install-emacs

=head1 DESCRIPTION

This will place the emacs script contained in the C<DATA> portion of
App::EditorTools::Command::InstallEmacs where emacs expects it (
C<$HOME/.emacs.d/editortools.el> for a local install on a
unix-like system)>). 

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

__DATA__

;; Copyright (C) 2010 Pat Regan <thehead@patshead.com>

;; Keywords: faces
;; Author: Pat Regan <thehead@patshead.com>
;; URL: http://rcs,patshead.com/dists/editortools-vim-el

;; This file is not part of GNU Emacs.

;; This is free software; you can redistribute it and/or modify it under
;; the terms of the GNU General Public License as published by the Free
;; Software Foundation; either version 2, or (at your option) any later
;; version.
;;
;; This is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
;; FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 59 Temple Place - Suite 330, Boston,
;; MA 02111-1307, USA.

;;; Commentary:

;; Requires App::EditorTools Perl module

(defun editortools-renamevariable (varname)
  "Call rename variable on buffer"
  (interactive "sNew Variable Name: ")
  (let* (
         (p (point))
         (col (+ 1 (current-column))) ; vim numbers columns differently
         (line (line-number-at-pos))
         )
    (shell-command-on-region (point-min) (point-max)
                             (format "editortools renamevariable -l %d -c %d -r %s" line col varname) t nil nil)
    (goto-char p)
    )
  )

(defun editortools-introducetemporaryvariable (varname)
  "Call introducetempoararyvariable on region"
  (interactive "sNew Variable Name: ")
  (let* (
         (p (point))
         (startline (line-number-at-pos (region-beginning)))
         (startcol (editortools-get-column (region-beginning)))
         (endline (line-number-at-pos (region-end)))
         (endcol (editortools-get-column (region-beginning)))
         )
    (shell-command-on-region (point-min) (point-max)
                             (format "editortools introducetemporaryvariable -s %d,%d -e %d,%d -v %s" startline startcol endline endcol varname) t nil nil)
    (goto-char p)
    )
  )

(defun editortools-renamepackagefrompath ()
  "Call renamepackagefrompath"
  (interactive)
  (let* (
         (p (point))
         )
    (shell-command-on-region (point-min) (point-max)
                             (format "editortools renamepackagefrompath -f %s" (buffer-file-name)) t nil nil)
    (goto-char p)
    )
  )

(defun editortools-renamepackage ()
  "Call renamepackage"
  (interactive)
  (let* (
         (p (point))
         )
    (shell-command-on-region (point-min) (point-max)
                             (format "editortools renamepackage -f %s" (buffer-file-name)) t nil nil)
    (goto-char p)
    )
  )

(defun editortools-get-column (p)
  "Get the column of a point"
  (save-excursion
    (goto-char p)
    (+ 1 (current-column)) ; vim counts columns differently
    )
  )

(define-key cperl-mode-map (kbd "C-c e r") 'editortools-renamevariable)
(define-key cperl-mode-map (kbd "C-c e t") 'editortools-introducetemporaryvariable)

(provide 'editortools')

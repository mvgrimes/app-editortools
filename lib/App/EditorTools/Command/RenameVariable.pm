package App::EditorTools::Command::RenameVariable;

use strict;
use warnings;

use App::EditorTools -command;

our $VERSION = '0.17';

sub opt_spec {
    return (
        [ "line|l=s",   "Line number of the start of variable to replace", ],
        [ "column|c=s", "Column number of the start of variable to replace", ],
        [ "replacement|r=s", "The new variable name (without sigil)", ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    for (qw(line column replacement)) {
        $self->usage_error("Arg $_ is required") unless $opt->{$_};
    }
    return 1;
}

sub execute {
    my ( $self, $opt, $arg ) = @_;

    my $doc_as_str = eval { local $/ = undef; <STDIN> };

    require PPIx::EditorTools::RenameVariable;
    print PPIx::EditorTools::RenameVariable->new->rename(
        code        => $doc_as_str,
        column      => $opt->{column},
        line        => $opt->{line},
        replacement => $opt->{replacement},
    )->code;
    return;
}

1;

=head1 NAME

App::EditorTools::Command::RenameVariable - Lexically Rename a Variable

=head1 DESCRIPTION

See L<App::EditorTools> for documentation.

=head1 AUTHOR

Mark Grimes, E<lt>mgrimes@cpan.orgE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by Mark Grimes

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.



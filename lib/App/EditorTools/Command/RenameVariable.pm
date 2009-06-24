package App::EditorTools::Command::RenameVariable;

use strict;
use warnings;

use App::EditorTools -command;

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
}

sub run {
    my ( $self, $opt, $arg ) = @_;

    my $doc_as_str = join( "", <STDIN> );

    require PPIx::EditorTools::RenameVariable;
    print PPIx::EditorTools::RenameVariable->new->rename(
        code        => $doc_as_str,
        column      => $opt->{column},
        line        => $opt->{line},
        replacement => $opt->{replacement},
    )->code;
}

1;

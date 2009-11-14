package App::EditorTools::Command::RenamePackage;

use strict;
use warnings;

use App::EditorTools -command;

sub opt_spec {
    return ( [ "filename|f=s", "The filename and path of the package", ] );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    $self->usage_error("Filename is required") unless $opt->{filename};
    return 1;
}

sub execute {
    my ( $self, $opt, $arg ) = @_;

    my $doc_as_str = eval { local $/ = undef; <STDIN> };

    print "DOC: " . $doc_as_str;

    require PPIx::EditorTools::RenamePackageFromPath;
    print PPIx::EditorTools::RenamePackageFromPath->new->rename(
        code     => $doc_as_str,
        filename => $opt->{filename} )->code;
    return;
}

1;

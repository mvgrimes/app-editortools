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
}

sub run {
    my ( $self, $opt, $arg ) = @_;

    my $doc_as_str = join( "", <STDIN> );

    require PPIx::EditorTools::RenamePackageFromPath;
    print PPIx::EditorTools::RenamePackageFromPath->new( code => $doc_as_str, )
      ->rename( filename => $opt->{filename} )->serialize;
}

1;

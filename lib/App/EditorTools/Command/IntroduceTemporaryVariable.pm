package App::EditorTools::Command::IntroduceTemporaryVariable;

use strict;
use warnings;

use App::EditorTools -command;

sub opt_spec {
    return (
        [ "start_location|s=s", "The line,column of the start" ],
        [ "end_location|e=s",   "The line,column of the end" ],
        [ "varname|v=s",        "The new variable name" ],
    );
}

sub validate_args {
    my ( $self, $opt, $args ) = @_;
    $self->usage_error("start_location is required")
      unless $opt->{start_location};
    $self->usage_error("end_location is required") unless $opt->{end_location};

    $opt->{start} = [ grep {/\d+/} split /,/, $opt->{start_location} ];
    $opt->{end}   = [ grep {/\d+/} split /,/, $opt->{end_location} ];

    $self->usage_error("start_location must be <Int>,<Int>")
      unless scalar @{ $opt->{start} } == 2;
    $self->usage_error("end_location must be <Int>,<Int>")
      unless scalar @{ $opt->{end} } == 2;

}

sub run {
    my ( $self, $opt, $arg ) = @_;

    my $doc_as_str = join( "", <STDIN> );

    require PPIx::EditorTools::IntroduceTemporaryVariable;
    my $munged = PPIx::EditorTools::IntroduceTemporaryVariable->new->introduce(
        code           => $doc_as_str,
        start_location => $opt->{start},
        end_location   => $opt->{end},
        varname        => $opt->{varname},
    );

    print $munged->code;

}

1;

package App::EditorTools::Command::View::Dump;
use strictures 1;

# ABSTRACT: Dump ppi to stdout

use App::EditorTools -command;
use PPI;
use PPI::Dumper;

sub opt_spec {
	return ( [ 'whitespace|w' , 'turn on whitespace processing', { default => 0 } ],
			 [ 'comments|c'   , 'turn on comments processing'  , { default => 0 } ],
			 [ 'pod'          , 'turn on pod'                  , { default => 0 } ],
		   );
}


sub validate_args {
	my ($self, $opt, $args) = @_;
	$opt->{$_} = $opt->{$_} ? 1 : 0 for  qw/whitespace comments pod/;
	return 1;
}

sub execute {
	my ($self, $opt, $args) = @_;
	my $doc_as_str = eval { local $/ = undef, <STDIN> };
	my $doc = PPI::Document->new(\$doc_as_str);
	my $dumper = PPI::Dumper->new($doc, %$opt);
	$dumper->print;
}

1;

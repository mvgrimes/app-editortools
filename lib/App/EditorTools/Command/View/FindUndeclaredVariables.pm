package App::EditorTools::Command::View::FindUndeclaredVariables;
use warnings;
use strict;

# ABSTRACT: Find undeclared variables in selected code.

use App::EditorTools -command;
use PPI;
use Perl::Critic::Utils qw/is_assignment_operator is_perl_global/;
use List::Compare;

sub opt_spec {
	return ();
}

sub validate_args {
	return 1;
}

sub execute {
	my ($self, $opt, $args) = @_;
	my $doc_as_str = eval { local $/ = undef, <STDIN> };
	my $doc = PPI::Document->new(\$doc_as_str);
	my $symbols = $doc->find(sub {
		$_[1]->isa('PPI::Token::Symbol') && ! is_perl_global($_[1]);
    });
	my @symbols = map { "$_"} @$symbols;
	my $vars   = $doc->find(sub {
		$_[1]->isa('PPI::Statement::Variable') ;
	});
	$vars ||= [];
	my @declared = _get_declared_variables($vars);

	my $lc = List::Compare->new(\@symbols, \@declared);
	my @undeclared = $lc->get_Lonly();
	print join "\n", "Undeclared variables in region:", "=" x 20  , sort @undeclared;
}

sub _get_declared_variables {
	my ($vars) = @_;
	my @declared;
	foreach my $v (@$vars) {
		my $token = $v->first_token;
		my $lhs = 1;
		# keep going till we get to an assignment operator
		while ($lhs) {
			push @declared, "$token" if $token->isa('PPI::Token::Symbol');
			$token = $token->next_token;
			$lhs = 0 if ! $token || is_assignment_operator($token);
		}
	}
	return @declared;
}

1;

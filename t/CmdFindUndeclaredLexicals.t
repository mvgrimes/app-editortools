#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

use lib 't/lib';
use AETest;

sub _get_result {
	my @values = @_;
	return join "\n", "Undeclared variables in region:", "=" x 20  , sort @values;
}

my %samples = (
	'my $foo = $bar;'                => _get_result('$bar'),
	'my ($foo, $bar, $baz) = @argle' => _get_result('@argle'),
	'$abcd = $goldfish->swim;'       => _get_result('$abcd', '$goldfish'),
	'my $cmp = List::Compare->new(\@symbols, \@declared);' . "\n" 
		. 'my @outer_scope = $cmp->get_Lonly;' => _get_result('@symbols', '@declared'),
		'my ($foo, $bar) = @_;' => _get_result(),


);

{

	foreach my $line (keys %samples) {
		my $return = AETest->test( [qw{findundeclaredvariables}], $line );
		is( $return->stdout, $samples{$line});
		is( $return->error, undef, '... no error' );
	}
}

done_testing;

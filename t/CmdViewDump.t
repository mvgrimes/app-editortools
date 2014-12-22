#!/usr/bin/env perl

use strict;
use warnings;

use Test::More;
use Test::Differences;

use lib 't/lib';
use AETest;

{
    my $return = AETest->test( [qw{dump}], <<'CODE' );
use warnings;
CODE
    is( $return->stdout, 
		"PPI::Document\cJ  PPI::Statement::Include\cJ    PPI::Token::Word  \cI'use'\cJ    PPI::Token::Word  \cI'warnings'\cJ    PPI::Token::Structure  \cI';'\cJ"
		, 'RenameVariable' );
    is( $return->error, undef, '... no error' );
}

done_testing;

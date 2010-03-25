#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences;

use lib 't/lib';
use AETest;

{
    my $return = AETest->test( [qw(renamepackage -f lib/New/Path.pm)], <<'CODE' );
package Old::Package;
use strict; use warnings;
CODE
    like( $return->stdout, qr/package New::Path;/, 'RenamePackage' );
    is( $return->error, undef, '... no error' );
}

{
    my $return = AETest->test( [qw{renamevariable -l 5 -c 9 -r shiny}], <<'CODE' );
use MooseX::Declare;
class Test {
    method some_method {
        my $x_var = 1;
        $x_var += 1;
        my %hash;
        for my $i (1..5) {
            $hash{$i} = $x_var;
        }
    }
}
CODE
    like( $return->stdout, qr/shiny/, 'RenameVariable' );
    is( $return->error, undef, '... no error' );
}


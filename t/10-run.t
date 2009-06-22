#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 4;
use Test::Differences;
use IPC::Run3;

my $script = './script/editortools-vim';
my $out;

{
    my $in = <<'CODE';
package Old::Package;
use strict; use warnings;
CODE
    my $cmd = qq{$script renamepackage -f lib/New/Path.pm};
    ok( run3( $cmd, \$in, \$out ), $cmd );
    like( $out, qr/package New::Path;/, 'RenamePackage' );
}

{
    my $in = <<'CODE';
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
    my $cmd = qq{$script renamevariable -l 5 -c 9 -r shiny};
    ok( run3( $cmd, \$in, \$out ), $cmd );
    like( $out, qr/shiny/, 'RenameVariable' );
}


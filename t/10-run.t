#!/usr/bin/perl

use strict;
use warnings;

use Test::More tests => 7;
use Test::Differences;
use App::Cmd::Tester;
use App::EditorTools;

{
    my $app = App::EditorTools->new;
    isa_ok( $app, 'App::EditorTools' );
}

{
    my $return = do_test( [qw(renamepackage -f lib/New/Path.pm)], <<'CODE' );
package Old::Package;
use strict; use warnings;
CODE
    like( $return->stdout, qr/package New::Path;/, 'RenamePackage' );
    is( $return->error, undef, '... no error' );
}

{
    my $return = do_test( [qw{renamevariable -l 5 -c 9 -r shiny}], <<'CODE' );
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

{
    my $return =
      do_test( [qw{introducetemporaryvariable -s 1,13 -e 1,21 -v foo}],
        <<'CODE' );
my $x = 1 + (10 / 12) + 15;
my $x = 3 + (10 / 12) + 17;
CODE
    like( $return->stdout, qr/my \$foo = \(10 \/ 12\)/, 'IntroduceTempVar' );
    is( $return->error, undef, '... no error' );
}

sub do_test {
    my ( $args, $input ) = @_;
    close STDIN;
    open( STDIN, '<', \$input ) or die "Couldn't redirect STDIN";
    my $return = test_app( 'App::EditorTools', @_ );
    return $return;
}

#!/usr/bin/perl -w

use strict;
use warnings;

use Test::More tests => 4;

BEGIN {
    use_ok('App::EditorTools');
    use_ok('App::EditorTools::Command::RenameVariable');
    use_ok('App::EditorTools::Command::RenamePackage');
    use_ok('App::EditorTools::Command::RenamePackageFromPath');
}


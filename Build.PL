use Module::Build;

my $build = Module::Build->new(
    module_name   => 'App::EditorTools',
    license       => 'perl',
    create_readme => 1,
    script_files  => [qw(script/editortools)],
    requires      => {
        'perl'              => '5.008',
        'PPIx::EditorTools' => 0,
        'App::Cmd'          => '0.301',
        'File::Path'        => 0,
        'File::Basename'    => 0,
        'File::ShareDir'    => 0,
        'IPC::Cmd'          => 0,
        'File::HomeDir'     => '0.80',
        'File::Slurp'       => 0,
        'parent'            => 0,
    },
    build_requires => {
        'Test::Differences' => 0,
        'Text::Diff'        => 0,
        'Test::More'        => 0.87,
        'File::Find'        => 0,
    },
    configure_requires => { 'Module::Build' => '0.36', },
    share_dir          => 'share',

    meta_merge => {
        resources => {
            bugtracker =>
              'http://rt.cpan.org/NoAuth/Bugs.html?Dist=App-EditorTools',
            repository => 'http://github.com/mvgrimes/app-editortools'
        }
    },
);

$build->create_build_script;


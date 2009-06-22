use Module::Build;

my $build = Module::Build->new(
    module_name        => 'App::EditorTools',
    license            => 'perl',
    create_readme      => 1,
    create_makefile_pl => 'passthrough',
    script_files       => [qw(script/editortools-vim)],
    requires           => {
        'perl'              => '5.008',
        'PPIx::EditorTools' => 0,
    },
    build_requires => {
        'Test::Differences' => 0,
        'IPC::Run3'         => 0,
    },
);

$build->create_build_script;


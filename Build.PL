use Module::Build;	
Module::Build->new(
	module_name	=> 'Text::CSV::Unicode',
	requires	=> { perl => 5.008 },
	build_requires	=> { Test::More => 0 },
	license		=> 'perl',	
	create_makefile_pl => 'traditional',
) -> create_build_script;

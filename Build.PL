use Module::Build;	
Module::Build->new(
	module_name	=> 'Text::CSV::Unicode',
	requires	=> { perl => 5.008 },
	license		=> 'perl',	
	autosplit	=> 'lib/Text/CSV/Base.pm',
	create_makefile_pl => 'traditional',
) -> create_build_script;

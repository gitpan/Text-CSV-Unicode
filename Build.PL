use Module::Build;	
Module::Build->new(
	module_name	=> 'Text::CSV::Unicode',
	requires	=> { perl => 5.008, Text::CSV => 0.01 },
	license		=> 'perl',	
	create_makefile_pl => 'traditional',
) -> create_build_script;

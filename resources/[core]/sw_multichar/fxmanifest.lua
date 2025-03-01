fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name "sw_multichar"
description "Multicharacter For Sw Framework"
author "Swellington Soares"
version "1"

use_experimental_fxv2_oal "yes"

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {	
	'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

dependencies {
	'sw',
	'ox_lib',
	'oxmysql',
	-- 'sw_appel',
	'/onesync'
}


ox_lib {
	'locale'
}
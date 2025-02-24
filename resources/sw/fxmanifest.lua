fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name "sw"
description "Swellington Framework"
author "Swellington Soares"
version "1"

use_experimental_fxv2_oal "yes"

loadscreen_cursor 'yes'

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua'
}

client_scripts {
	'client/modules/player.lua',
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/*.lua'
}

dependencies {
	'/onesync',
	'/server:12911',
	'/gameBuild:3258',
	'ox_lib',
	'oxmysql'
}

ox_lib {
	'locale'
}

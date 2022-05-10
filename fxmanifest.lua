-- XD_Locksystem | Creator: LielXD --

fx_version 'cerulean'

game 'gta5'

author 'LielXD'
description 'XD_Locksystem for ESX'
version 'Legacy'

client_scripts {
	'@es_extended/imports.lua',
    'client/*.lua',
    'config.lua'
}

server_scripts {
	'@async/async.lua',
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/imports.lua',
    'server/*.lua',
    'config.lua'
}

dependencies {
	'es_extended'
}

exports {
	'givePlayerKeys',
	'takePlayerKeys'
}

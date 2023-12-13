name "slrn-powercruise"
author "solareon."
description "Autopilot for Qbox"
fx_version "cerulean"
game "gta5"

client_scripts {
	'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

files {
    'config/shared.lua'
}

lua54 'yes'

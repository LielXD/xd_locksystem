fx_version 'cerulean'
game 'gta5'

author 'LielXD'
description 'Vehicle lock system Script for Fivem'

version '2.0.0'
shared_scripts {
    '@xd_core/import.lua',
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

dependencies {
    'xd_core'
}

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/sound/*.wav',

    'sound/locksystem.awc',
    'sound/locksystem_sounds.dat54.rel'
}

ui_page 'html/index.html'

data_file 'AUDIO_WAVEPACK' 'sound/locksystem'
data_file 'AUDIO_SOUNDDATA' 'sound/locksystem_sounds.dat'
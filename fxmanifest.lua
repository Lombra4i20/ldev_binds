game 'rdr3'
fx_version 'adamant'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

author "LombraDev"
description 'Binds'

client_scripts {
    'config/config.lua',
    'client/main.lua',
}

server_scripts {
    'config/config.lua',
    'server/main.lua'
}
files {
    "ui/index.html",
    "ui/js/*.*"
}

escrow_ignore {
    'config/config.lua',
	"server/main.lua",
}
version '1.0.0'

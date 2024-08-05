fx_version 'cerulean'
game 'gta5'
author 'DiosDevelopment'
description 'The Greatest Computer Aided Dispatch ever'
version '1.0.0'

dependency 'qb-core'
server_script '@oxmysql/lib/MySQL.lua'

files {
    'html/*.css',
    'users.json',
    'html/*.ttf',
    'html/*.js',
    'html/*.jpg',
    'html/*.html',
}

ui_page 'html/frames.html'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua'
}

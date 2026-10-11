--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-ui
    Responsibility: Shared design system, theme tokens, and NUI adapters.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-ui'
author 'Meridian Roleplay Development Team'
description 'Shared UI/UX design system and theme styles for Meridian Roleplay.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

client_scripts {
    'client/main.lua',
    'client/mdt.lua',
    'client/admin.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/admin.lua'
}

dependencies {
    'meridian-core',
    'qb-core',
    'oxmysql',
    'ox_lib'
}

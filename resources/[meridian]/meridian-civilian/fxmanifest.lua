--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-civilian
    Responsibility: Civilian careers, legal employment loops, logistics,
                    delivery services, anti-exploit work validations.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-civilian'
author 'Meridian Roleplay Development Team'
description 'Civilian legal career loops, freight logistics, and anti-abuse delivery mechanisms.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/logistics.lua'
}

server_scripts {
    'server/logistics.lua'
}

dependencies {
    'meridian-core',
    'ox_lib'
}

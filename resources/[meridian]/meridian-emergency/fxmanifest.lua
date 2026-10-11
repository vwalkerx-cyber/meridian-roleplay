--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-emergency
    Responsibility: Agency duty tracking, unit coordination, and emergency
                    CAD/dispatch calls for LSPD, BCSO, MSP, and EMS.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-emergency'
author 'Meridian Roleplay Development Team'
description 'Public safety agencies, officer duty tracking, and dispatch coordination.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/dispatch.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/dispatch.lua'
}

dependencies {
    'meridian-core',
    'oxmysql',
    'ox_lib'
}

exports {
    'CreateDispatchCall',
    'GetActiveCalls',
    'ClearDispatchCall',
    'GetDutyOfficers'
}

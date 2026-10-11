--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-businesses
    Responsibility: Player-owned enterprise management, employee roles,
                    payroll execution, invoicing, and corporate ledgers.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-businesses'
author 'Meridian Roleplay Development Team'
description 'Player-owned businesses, permissions, payroll, and enterprise management.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/businesses.lua'
}

dependencies {
    'meridian-core',
    'meridian-banking',
    'oxmysql',
    'ox_lib'
}

exports {
    'GetBusiness',
    'GetEmployeeRole',
    'ProcessPayroll',
    'RegisterBusiness'
}

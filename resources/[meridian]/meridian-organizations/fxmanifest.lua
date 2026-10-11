--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-organizations
    Responsibility: Criminal syndicates, membership ranks, influence scores,
                    and server-authoritative illegal activities (robberies).
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-organizations'
author 'Meridian Roleplay Development Team'
description 'Criminal syndicates, influence mechanics, and server-validated illegal activities.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

client_scripts {
    'client/robberies.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/organizations.lua',
    'server/robberies.lua',
    'server/territories.lua'
}

dependencies {
    'meridian-core',
    'meridian-emergency',
    'meridian-justice',
    'oxmysql',
    'ox_lib'
}

exports {
    'GetOrganization',
    'GetMemberRank',
    'CreateOrganization',
    'AdjustInfluence',
    'GetAllTerritories',
    'ContestInfluence'
}

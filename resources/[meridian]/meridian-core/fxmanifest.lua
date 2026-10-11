--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-core
    Responsibility: Shared foundations, logging, permissions, db wrappers,
                    and localization utilities.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-core'
author 'Meridian Roleplay Development Team'
description 'Shared foundations, security utilities, database abstraction, and audit logging for Meridian Roleplay.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua',
    'shared/locales.lua',
    'shared/types.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/logger.lua',
    'server/database.lua',
    'server/permissions.lua',
    'server/main.lua'
}

exports {
    -- Shared
    'GetCoreConfig',
    'GetLocale',
    'FormatCurrency',
    
    -- Server Logger & Audit
    'LogAudit',
    'LogSecurity',
    'LogError',
    
    -- Server Permissions
    'HasPermission',
    'IsDuty',
    'GetPlayerJob',
    'GetPlayerCitizenId',
    
    -- Server Database Transaction
    'ExecuteTransaction'
}

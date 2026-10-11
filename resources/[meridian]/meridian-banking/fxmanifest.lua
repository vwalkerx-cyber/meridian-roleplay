--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-banking
    Responsibility: Bank accounts, atomic balance transfers, double-entry
                    ledger tracking, state tax sinks, and invoicing.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-banking'
author 'Meridian Roleplay Development Team'
description 'Interconnected personal, business, and state banking systems with auditable ledgers.'
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
    'server/banking.lua'
}

dependencies {
    'meridian-core',
    'oxmysql',
    'ox_lib'
}

exports {
    'GetAccountBalance',
    'CreateAccount',
    'TransferFunds',
    'CreateInvoice',
    'PayInvoice'
}

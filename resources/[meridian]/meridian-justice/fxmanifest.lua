--[[
    ==================================================================
    MERIDIAN ROLEPLAY — fxmanifest.lua
    Resource: meridian-justice
    Responsibility: Physical forensic evidence tracking, chain of custody,
                    ballistic markings, fingerprint hashes, and casefiles.
    ==================================================================
--]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'meridian-justice'
author 'Meridian Roleplay Development Team'
description 'Forensic evidence persistence, chain of custody, and legal case records.'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/evidence.lua',
    'server/cases.lua'
}

dependencies {
    'meridian-core',
    'oxmysql',
    'ox_lib'
}

exports {
    'CreateEvidence',
    'GetEvidenceById',
    'TransferEvidenceCustody',
    'GetCaseEvidence',
    'CreateCase',
    'AddSuspect',
    'RequestWarrant',
    'ReviewWarrant'
}

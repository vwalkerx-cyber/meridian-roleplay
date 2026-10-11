--[[
    MERIDIAN ROLEPLAY — meridian-ui/client/admin.lua
    Interactive /admin staff dashboard using ox_lib context menus and dialogs.
--]]

local isNoclip = false

local function ToggleNoclip()
    isNoclip = not isNoclip
    local ped = PlayerPedId()
    SetEntityInvincible(ped, isNoclip)
    SetEntityVisible(ped, not isNoclip, false)
    SetEntityCollision(ped, not isNoclip, not isNoclip)
    lib.notify({
        title = 'Staff Admin',
        description = 'Noclip ' .. (isNoclip and 'Enabled' or 'Disabled'),
        type = isNoclip and 'success' or 'info'
    })
end

local function OpenPlayerManagement(player)
    lib.registerContext({
        id = 'meridian_admin_player_detail',
        title = player.name .. ' [ID: ' .. player.source .. ']',
        menu = 'meridian_admin_players',
        options = {
            {
                title = 'Citizen ID: ' .. player.citizenid,
                description = 'Job: ' .. player.job .. ' | Cash: $' .. player.cash .. ' | Bank: $' .. player.bank,
                icon = 'id-card',
                disabled = true
            },
            {
                title = 'Teleport to Player (GoTo)',
                icon = 'location-arrow',
                onSelect = function()
                    TriggerServerEvent('meridian-ui:server:adminAction', 'teleportTo', player.source)
                end
            },
            {
                title = 'Bring Player',
                icon = 'person-walking-arrow-right',
                onSelect = function()
                    TriggerServerEvent('meridian-ui:server:adminAction', 'bring', player.source)
                end
            },
            {
                title = 'Heal Player',
                icon = 'heart-pulse',
                onSelect = function()
                    TriggerServerEvent('meridian-ui:server:adminAction', 'heal', player.source)
                end
            },
            {
                title = 'Revive Player',
                icon = 'syringe',
                onSelect = function()
                    TriggerServerEvent('meridian-ui:server:adminAction', 'revive', player.source)
                end
            },
            {
                title = 'Freeze / Unfreeze Player',
                icon = 'snowflake',
                onSelect = function()
                    local input = lib.inputDialog('Freeze State', {
                        { type = 'select', label = 'State', options = { { value = true, label = 'Freeze' }, { value = false, label = 'Unfreeze' } } }
                    })
                    if input then
                        TriggerServerEvent('meridian-ui:server:adminAction', 'freeze', player.source, { freeze = input[1] })
                    end
                end
            },
            {
                title = 'Grant Money',
                icon = 'money-bill-wave',
                onSelect = function()
                    local input = lib.inputDialog('Grant Funds to ' .. player.name, {
                        { type = 'select', label = 'Account', options = { { value = 'cash', label = 'Cash' }, { value = 'bank', label = 'Bank' } } },
                        { type = 'number', label = 'Amount', required = true, min = 1 }
                    })
                    if input and input[2] then
                        TriggerServerEvent('meridian-ui:server:adminAction', 'giveMoney', player.source, { account = input[1], amount = input[2] })
                    end
                end
            }
        }
    })
    lib.showContext('meridian_admin_player_detail')
end

local function OpenAdminMenu()
    lib.registerContext({
        id = 'meridian_admin_main',
        title = 'Meridian Roleplay Staff Dashboard',
        options = {
            {
                title = 'Self Options',
                description = 'Noclip, Heal Self, Godmode, Teleport to Waypoint',
                icon = 'user-shield',
                onSelect = function()
                    lib.registerContext({
                        id = 'meridian_admin_self',
                        title = 'Admin Self Options',
                        menu = 'meridian_admin_main',
                        options = {
                            {
                                title = 'Toggle Noclip',
                                icon = 'ghost',
                                onSelect = ToggleNoclip
                            },
                            {
                                title = 'Heal & Armor Self',
                                icon = 'heart',
                                onSelect = function()
                                    local ped = PlayerPedId()
                                    SetEntityHealth(ped, 200)
                                    SetPedArmour(ped, 100)
                                    lib.notify({ title = 'Admin', description = 'Health & armor replenished.', type = 'success' })
                                end
                            },
                            {
                                title = 'Teleport to Waypoint (TPM)',
                                icon = 'map-pin',
                                onSelect = function()
                                    ExecuteCommand('tpm')
                                end
                            },
                            {
                                title = 'Spawn Vehicle',
                                icon = 'car',
                                onSelect = function()
                                    local input = lib.inputDialog('Spawn Vehicle', {
                                        { type = 'input', label = 'Model Name (e.g. sultan, police3)', required = true }
                                    })
                                    if input and input[1] then
                                        local model = joaat(input[1])
                                        if IsModelInCdimage(model) then
                                            RequestModel(model)
                                            while not HasModelLoaded(model) do Wait(0) end
                                            local coords = GetEntityCoords(PlayerPedId())
                                            local veh = CreateVehicle(model, coords.x, coords.y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
                                            TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
                                            lib.notify({ title = 'Admin', description = 'Vehicle spawned: ' .. input[1], type = 'success' })
                                        else
                                            lib.notify({ title = 'Admin', description = 'Invalid vehicle model.', type = 'error' })
                                        end
                                    end
                                end
                            }
                        }
                    })
                    lib.showContext('meridian_admin_self')
                end
            },
            {
                title = 'Player Management',
                description = 'List all connected citizens and manage their state',
                icon = 'users-gear',
                onSelect = function()
                    lib.callback('meridian-ui:server:getOnlinePlayers', false, function(players)
                        if not players or #players == 0 then
                            lib.notify({ title = 'Admin', description = 'No players online.', type = 'info' })
                            return
                        end
                        local playerOptions = {}
                        for _, p in ipairs(players) do
                            table.insert(playerOptions, {
                                title = string.format("[%d] %s", p.source, p.name),
                                description = string.format("CID: %s | %s", p.citizenid, p.job),
                                icon = 'user',
                                onSelect = function()
                                    OpenPlayerManagement(p)
                                end
                            })
                        end
                        lib.registerContext({
                            id = 'meridian_admin_players',
                            title = 'Connected Players (' .. #players .. ')',
                            menu = 'meridian_admin_main',
                            options = playerOptions
                        })
                        lib.showContext('meridian_admin_players')
                    end)
                end
            },
            {
                title = 'Audit & Security Logs',
                description = 'View recent server-authoritative audit events and security alerts',
                icon = 'shield-halved',
                onSelect = function()
                    lib.callback('meridian-ui:server:getRecentAuditLogs', false, function(logs)
                        local logOptions = {}
                        for _, l in ipairs(logs or {}) do
                            table.insert(logOptions, {
                                title = string.format("[%s] %s", l.category, l.message),
                                description = string.format("Logged at: %s", l.created_at),
                                icon = l.category == 'SECURITY' and 'triangle-exclamation' or 'file-lines'
                            })
                        end
                        if #logOptions == 0 then
                            table.insert(logOptions, { title = 'No logs found', disabled = true })
                        end
                        lib.registerContext({
                            id = 'meridian_admin_logs',
                            title = 'Recent Audit & Security Logs',
                            menu = 'meridian_admin_main',
                            options = logOptions
                        })
                        lib.showContext('meridian_admin_logs')
                    end)
                end
            }
        }
    })
    lib.showContext('meridian_admin_main')
end

RegisterCommand('admin', function()
    OpenAdminMenu()
end, false)

RegisterKeyMapping('admin', 'Open Meridian Admin Menu', 'keyboard', 'F10')

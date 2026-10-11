--[[
    MERIDIAN ROLEPLAY — meridian-ui/server/admin.lua
    Server-authoritative validation for admin menu actions.
    Guarantees:
      - Only users with 'admin' or 'god' permissions can trigger actions.
      - Every admin action is recorded in meridian_audit_logs.
--]]

local QBCore = exports['qb-core']:GetCoreObject()

local function IsAdmin(source)
    if source == 0 then return true end
    return QBCore.Functions.HasPermission(source, 'admin') or QBCore.Functions.HasPermission(source, 'god') or IsPlayerAceAllowed(source, 'command')
end

-- Callback: Fetch online players list for admin management
lib.callback.register('meridian-ui:server:getOnlinePlayers', function(source)
    if not IsAdmin(source) then return false end

    local playerList = {}
    local players = QBCore.Functions.GetQBPlayers()

    for src, pData in pairs(players) do
        table.insert(playerList, {
            source = src,
            name = pData.PlayerData.charinfo.firstname .. ' ' .. pData.PlayerData.charinfo.lastname,
            citizenid = pData.PlayerData.citizenid,
            job = pData.PlayerData.job.label .. ' (' .. pData.PlayerData.job.grade.name .. ')',
            cash = pData.PlayerData.money.cash,
            bank = pData.PlayerData.money.bank
        })
    end

    return playerList
end)

-- Callback: Fetch recent audit logs
lib.callback.register('meridian-ui:server:getRecentAuditLogs', function(source)
    if not IsAdmin(source) then return false end

    return MySQL.query.await([[
        SELECT * FROM meridian_audit_logs ORDER BY id DESC LIMIT 25
    ]])
end)

-- Admin Action Events
RegisterNetEvent('meridian-ui:server:adminAction', function(action, targetSource, payload)
    local src = source
    if not IsAdmin(src) then
        exports['meridian-core']:LogSecurity(src, "UNAUTHORIZED_ADMIN_ACTION_ATTEMPT", {
            action = action,
            target = targetSource
        })
        return
    end

    local adminCitizenId = exports['meridian-core']:GetPlayerCitizenId(src) or "CONSOLE"

    if action == 'revive' then
        TriggerClientEvent('hospital:client:Revive', targetSource)
        exports['meridian-core']:LogAudit(adminCitizenId, "ADMIN_REVIVE_PLAYER", { target = targetSource })
    elseif action == 'heal' then
        local ped = GetPlayerPed(targetSource)
        SetEntityHealth(ped, 200)
        TriggerClientEvent('meridian-ui:client:notify', targetSource, "You were healed by staff.", "success")
        exports['meridian-core']:LogAudit(adminCitizenId, "ADMIN_HEAL_PLAYER", { target = targetSource })
    elseif action == 'freeze' then
        local ped = GetPlayerPed(targetSource)
        FreezeEntityPosition(ped, payload and payload.freeze == true)
        exports['meridian-core']:LogAudit(adminCitizenId, "ADMIN_FREEZE_PLAYER", { target = targetSource, freeze = payload.freeze })
    elseif action == 'teleportTo' then
        local targetPed = GetPlayerPed(targetSource)
        local coords = GetEntityCoords(targetPed)
        SetEntityCoords(GetPlayerPed(src), coords.x, coords.y, coords.z, false, false, false, false)
        exports['meridian-core']:LogAudit(adminCitizenId, "ADMIN_GOTO_PLAYER", { target = targetSource })
    elseif action == 'bring' then
        local adminPed = GetPlayerPed(src)
        local coords = GetEntityCoords(adminPed)
        SetEntityCoords(GetPlayerPed(targetSource), coords.x, coords.y, coords.z, false, false, false, false)
        exports['meridian-core']:LogAudit(adminCitizenId, "ADMIN_BRING_PLAYER", { target = targetSource })
    elseif action == 'giveMoney' then
        local targetPlayer = QBCore.Functions.GetPlayer(targetSource)
        if targetPlayer and payload.amount and payload.amount > 0 then
            targetPlayer.Functions.AddMoney(payload.account or 'cash', payload.amount, 'admin-granted')
            exports['meridian-core']:LogAudit(adminCitizenId, "ADMIN_GRANT_MONEY", {
                target = targetSource,
                amount = payload.amount,
                account = payload.account
            })
        end
    end
end)

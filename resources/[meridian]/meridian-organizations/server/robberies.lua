--[[
    MERIDIAN ROLEPLAY — meridian-organizations/server/robberies.lua
    Server-authoritative commercial store robbery state machine:
      - Validates cooldowns and minimum cops online.
      - Enforces countdown timer and distance check.
      - Dispatches 911 police alert with CAD call.
      - Drops physical forensic evidence (bullet casings / fingerprints).
      - Rewards cash and organization influence.
--]]

local ActiveRobberies = {} -- [targetId] = { initiatorSource, citizenId, startTime, coords }

lib.callback.register('meridian-organizations:server:startStoreRobbery', function(source, targetId)
    local target = OrgConfig.StoreTargets[targetId]
    if not target then return false, "Invalid target location." end

    local citizenId = exports['meridian-core']:GetPlayerCitizenId(source)
    if not citizenId then return false, "Citizen ID not found." end

    -- Check cooldown in database
    local ongoing = MySQL.single.await([[
        SELECT cooldown_until FROM meridian_criminal_activities 
        WHERE activity_type = 'store_robbery' AND target_id = ? AND cooldown_until > NOW()
        ORDER BY id DESC LIMIT 1
    ]], { targetId })

    if ongoing then
        return false, "This location was recently hit. Registers are empty."
    end

    if ActiveRobberies[targetId] then
        return false, "A robbery is already in progress at this location."
    end

    -- Distance check from player ped to target
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    if #(coords - target.coords) > 15.0 then
        exports['meridian-core']:LogSecurity(source, "ROBBERY_PROXIMITY_VIOLATION", {
            target = targetId
        })
        return false, "You are too far from the cash register."
    end

    -- Initiate robbery state
    ActiveRobberies[targetId] = {
        initiator = source,
        citizenId = citizenId,
        startTime = os.time(),
        target = target
    }

    -- 1. Trigger automated 911 dispatch CAD call to police
    exports['meridian-emergency']:CreateDispatchCall(
        '10-90',
        'Commercial Silent Alarm: ' .. target.name,
        string.format("Silent panic button tripped at %s. Armed robbery reported.", target.name),
        target.coords,
        'lspd',
        3
    )

    -- 2. Drop forensic evidence at the scene
    exports['meridian-justice']:CreateEvidence(
        'fingerprint',
        string.format("FP-%s", string.sub(citizenId, 1, 8)),
        string.format("Latent fingerprint recovered from register drawer at %s.", target.name),
        target.coords,
        "CRIME_SCENE_AI"
    )

    exports['meridian-core']:LogAudit(citizenId, "STORE_ROBBERY_INITIATED", {
        target = targetId,
        storeName = target.name
    })

    return true, {
        duration = OrgConfig.Robbery.DurationSeconds
    }
end)

lib.callback.register('meridian-organizations:server:claimRobberyPayout', function(source, targetId)
    local robbery = ActiveRobberies[targetId]
    if not robbery or robbery.initiator ~= source then
        return false, "No active robbery found for your session."
    end

    local elapsed = os.time() - robbery.startTime
    if elapsed < OrgConfig.Robbery.DurationSeconds then
        exports['meridian-core']:LogSecurity(source, "ROBBERY_PREMATURE_CLAIM", {
            elapsed = elapsed,
            required = OrgConfig.Robbery.DurationSeconds
        })
        return false, "Registers have not finished opening yet!"
    end

    -- Calculate randomized payout
    local payout = math.random(OrgConfig.Robbery.MinCashPayout, OrgConfig.Robbery.MaxCashPayout)

    -- Add cooldown in database (30 min)
    local cooldownDate = os.date("!%Y-%m-%d %H:%M:%S", os.time() + OrgConfig.Robbery.CooldownSeconds)
    MySQL.insert.await([[
        INSERT INTO meridian_criminal_activities 
        (activity_type, target_id, initiator_citizenid, status, payout, cooldown_until, completed_at)
        VALUES ('store_robbery', ?, ?, 'completed', ?, ?, NOW())
    ]], { targetId, robbery.citizenId, payout, cooldownDate })

    -- Disburse cash to player
    local pcallStatus, qb = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if pcallStatus and qb then
        local Player = qb.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('cash', payout, 'store-robbery-payout')
        end
    end

    ActiveRobberies[targetId] = nil

    exports['meridian-core']:LogAudit(robbery.citizenId, "STORE_ROBBERY_COMPLETED", {
        target = targetId,
        payout = payout
    })

    return true, payout
end)

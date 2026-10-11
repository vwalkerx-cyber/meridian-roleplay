--[[
    MERIDIAN ROLEPLAY — meridian-civilian/server/logistics.lua
    Server-authoritative state machine for logistics delivery shifts.
    Protections:
      - Validates route sequence and assigned drop nodes.
      - Enforces minimum plausible transit time to prevent teleport farming.
      - Enforces physical proximity check to target coordinates.
      - One shift per player session at any time.
      - Disconnect cleanup and server-side balance disbursement.
--]]

local ActiveShifts = {} -- [citizenid] = { vehicleNetId, currentNodeIndex, nodes, startTime, lastDropTime, dropoffsDone }

local function GetCitizenId(source)
    return exports['meridian-core']:GetPlayerCitizenId(source)
end

--[[
    Start a logistics shift
--]]
lib.callback.register('meridian-civilian:server:startLogisticsShift', function(source)
    local citizenId = GetCitizenId(source)
    if not citizenId then
        return false, exports['meridian-core']:GetLocale('common_error')
    end

    if ActiveShifts[citizenId] then
        return false, "You already have an active freight route in progress."
    end

    -- Generate a randomized sequential route
    local allNodes = CivilianConfig.Logistics.DropoffNodes
    local selectedNodes = {}
    local copy = { table.unpack(allNodes) }
    
    -- Shuffle & pick up to MaxDropoffsPerRoute
    for i = 1, math.min(CivilianConfig.Logistics.MaxDropoffsPerRoute, #copy) do
        local randIndex = math.random(1, #copy)
        table.insert(selectedNodes, copy[randIndex])
        table.remove(copy, randIndex)
    end

    ActiveShifts[citizenId] = {
        source = source,
        nodes = selectedNodes,
        currentIndex = 1,
        startTime = os.time(),
        lastDropTime = os.time(),
        completedDrops = 0
    }

    exports['meridian-core']:LogAudit(citizenId, "CIVILIAN_LOGISTICS_START", {
        routeLength = #selectedNodes,
        firstNode = selectedNodes[1].name
    })

    return true, {
        totalStops = #selectedNodes,
        firstStop = selectedNodes[1]
    }
end)

--[[
    Complete a dropoff node
--]]
lib.callback.register('meridian-civilian:server:completeDropoff', function(source, nodeIndex)
    local citizenId = GetCitizenId(source)
    if not citizenId or not ActiveShifts[citizenId] then
        exports['meridian-core']:LogSecurity(source, "CIVILIAN_LOGISTICS_UNAUTHORIZED_DROP", {
            reason = "No active shift record exists"
        })
        return false, exports['meridian-core']:GetLocale('common_no_permission')
    end

    local shift = ActiveShifts[citizenId]
    if shift.currentIndex ~= nodeIndex then
        exports['meridian-core']:LogSecurity(source, "CIVILIAN_LOGISTICS_OUT_OF_SEQUENCE", {
            expected = shift.currentIndex,
            received = nodeIndex
        })
        return false, "Invalid route sequence."
    end

    local targetNode = shift.nodes[nodeIndex]
    if not targetNode then
        return false, "Invalid route node."
    end

    -- 1. Anti-speed/teleport check: transit duration
    local currentTime = os.time()
    local elapsed = currentTime - shift.lastDropTime
    if elapsed < CivilianConfig.Logistics.MinDeliveryDurationSeconds then
        exports['meridian-core']:LogSecurity(source, "CIVILIAN_LOGISTICS_SPEED_ANOMALY", {
            elapsed = elapsed,
            threshold = CivilianConfig.Logistics.MinDeliveryDurationSeconds
        })
        return false, exports['meridian-core']:GetLocale('common_action_too_fast')
    end

    -- 2. Physical distance check from server ped coordinates
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(pedCoords - targetNode.coords)
    if dist > CivilianConfig.Logistics.SecurityDistanceDropoff then
        exports['meridian-core']:LogSecurity(source, "CIVILIAN_LOGISTICS_PROXIMITY_VIOLATION", {
            distance = dist,
            maxAllowed = CivilianConfig.Logistics.SecurityDistanceDropoff
        })
        return false, "You are too far from the delivery location."
    end

    -- Payout calculation (Server-authoritative)
    local dropPayout = CivilianConfig.Logistics.BasePayPerDropoff
    shift.completedDrops = shift.completedDrops + 1
    shift.lastDropTime = currentTime
    shift.currentIndex = shift.currentIndex + 1

    -- Disburse funds via QBCore or player balance
    local pcallStatus, qb = pcall(function() return exports['qb-core']:GetCoreObject() end)
    if pcallStatus and qb then
        local Player = qb.Functions.GetPlayer(source)
        if Player then
            Player.Functions.AddMoney('bank', dropPayout, 'logistics-delivery-drop')
        end
    end

    exports['meridian-core']:LogAudit(citizenId, "CIVILIAN_LOGISTICS_DROPOFF_COMPLETE", {
        node = targetNode.name,
        payout = dropPayout,
        dropCount = shift.completedDrops
    })

    local isFinished = (shift.completedDrops >= #shift.nodes)
    local nextStop = nil
    if not isFinished then
        nextStop = shift.nodes[shift.currentIndex]
    else
        -- Disburse route completion bonus
        local bonus = CivilianConfig.Logistics.CompletionBonus
        if pcallStatus and qb then
            local Player = qb.Functions.GetPlayer(source)
            if Player then
                Player.Functions.AddMoney('bank', bonus, 'logistics-route-bonus')
            end
        end

        ActiveShifts[citizenId] = nil
        exports['meridian-core']:LogAudit(citizenId, "CIVILIAN_LOGISTICS_ROUTE_COMPLETED", {
            bonus = bonus,
            totalDrops = shift.completedDrops
        })
    end

    return true, {
        payout = dropPayout,
        isFinished = isFinished,
        nextStop = nextStop
    }
end)

--[[
    Cancel/End Shift early
--]]
lib.callback.register('meridian-civilian:server:cancelShift', function(source)
    local citizenId = GetCitizenId(source)
    if citizenId and ActiveShifts[citizenId] then
        ActiveShifts[citizenId] = nil
        exports['meridian-core']:LogAudit(citizenId, "CIVILIAN_LOGISTICS_CANCELLED", {})
        return true
    end
    return false
end)

-- Clean up on player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    for cid, shift in pairs(ActiveShifts) do
        if shift.source == src then
            ActiveShifts[cid] = nil
            break
        end
    end
end)

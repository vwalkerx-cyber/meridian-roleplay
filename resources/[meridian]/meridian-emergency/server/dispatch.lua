--[[
    MERIDIAN ROLEPLAY — meridian-emergency/server/dispatch.lua
    Server-authoritative dispatch distribution and duty unit management.
--]]

local MeridianDispatch = {}

--[[
    Broadcast a dispatch call to all duty officers and persist in database
--]]
function MeridianDispatch.CreateDispatchCall(callCode, title, message, coords, agency, priority)
    agency = agency or 'all'
    priority = priority or 2
    local codeInfo = EmergencyConfig.CallCodes[callCode]
    if codeInfo then
        title = title or codeInfo.title
        priority = priority or codeInfo.priority
    end

    local x = (coords and coords.x) or 0.0
    local y = (coords and coords.y) or 0.0
    local z = (coords and coords.z) or 0.0

    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_dispatch_calls 
        (call_code, title, message, agency, priority, coords_x, coords_y, coords_z)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], { callCode, title, message, agency, priority, x, y, z })

    local callData = {
        id = insertId,
        callCode = callCode,
        title = title,
        message = message,
        coords = vec3(x, y, z),
        priority = priority,
        agency = agency,
        timestamp = os.time()
    }

    -- Broadcast to clients belonging to law enforcement or medical
    TriggerClientEvent('meridian-emergency:client:receiveDispatchCall', -1, callData)

    exports['meridian-core']:LogAudit("SYSTEM", "DISPATCH_CALL_CREATED", {
        callId = insertId,
        code = callCode,
        agency = agency,
        priority = priority
    })

    return insertId
end

--[[
    Get all active emergency calls
--]]
function MeridianDispatch.GetActiveCalls()
    return MySQL.query.await([[
        SELECT * FROM meridian_dispatch_calls WHERE is_active = 1 ORDER BY id DESC LIMIT 50
    ]])
end

--[[
    Mark a dispatch call cleared
--]]
function MeridianDispatch.ClearDispatchCall(callId, officerCitizenId)
    MySQL.update.await([[
        UPDATE meridian_dispatch_calls SET is_active = 0, cleared_at = NOW() WHERE id = ?
    ]], { callId })

    TriggerClientEvent('meridian-emergency:client:clearCallBlip', -1, callId)

    exports['meridian-core']:LogAudit(officerCitizenId or "SYSTEM", "DISPATCH_CALL_CLEARED", {
        callId = callId
    })

    return true
end

-- Exports
exports('CreateDispatchCall', MeridianDispatch.CreateDispatchCall)
exports('GetActiveCalls', MeridianDispatch.GetActiveCalls)
exports('ClearDispatchCall', MeridianDispatch.ClearDispatchCall)

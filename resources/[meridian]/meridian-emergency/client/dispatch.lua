--[[
    MERIDIAN ROLEPLAY — meridian-emergency/client/dispatch.lua
    Client-side audio cues, CAD notifications, and map blip rendering.
--]]

local activeCallBlips = {}

RegisterNetEvent('meridian-emergency:client:receiveDispatchCall', function(callData)
    -- Display alert using ox_lib notify
    lib.notify({
        title = string.format("[%s] %s", callData.callCode, callData.title),
        description = callData.message,
        type = callData.priority == 3 and 'error' or 'info',
        duration = 8000
    })

    -- Play audible notification
    PlaySoundFrontend(-1, "Event_Start_Text", "GTAO_FM_Events_Soundset", false)

    -- Create temporary tactical map blip
    if callData.coords and callData.coords.x ~= 0.0 then
        local blip = AddBlipForCoord(callData.coords.x, callData.coords.y, callData.coords.z)
        SetBlipSprite(blip, 161) -- Destination / alert marker
        SetBlipScale(blip, 1.1)
        SetBlipColour(blip, callData.priority == 3 and 1 or 5)
        SetBlipFlashes(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(string.format("CAD #%d: %s", callData.id, callData.callCode))
        EndTextCommandSetBlipName(blip)

        activeCallBlips[callData.id] = blip

        -- Remove blip after 2 minutes if not manually cleared
        SetTimeout(120000, function()
            if activeCallBlips[callData.id] and DoesBlipExist(activeCallBlips[callData.id]) then
                RemoveBlip(activeCallBlips[callData.id])
                activeCallBlips[callData.id] = nil
            end
        end)
    end
end)

RegisterNetEvent('meridian-emergency:client:clearCallBlip', function(callId)
    if activeCallBlips[callId] and DoesBlipExist(activeCallBlips[callId]) then
        RemoveBlip(activeCallBlips[callId])
        activeCallBlips[callId] = nil
    end
end)

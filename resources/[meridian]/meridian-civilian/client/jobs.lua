--[[
    MERIDIAN ROLEPLAY — meridian-civilian/client/jobs.lua
    Interactive checkpoints and ox_lib context menus for public job applications and duty clocking.
--]]

local QBCore = exports['qb-core']:GetCoreObject()
local blips = {}

--[[
    Setup Map Blips
--]]
CreateThread(function()
    -- Job Center Blip
    local jc = CivilianConfig.JobCenter
    local jcBlip = AddBlipForCoord(jc.Coords.x, jc.Coords.y, jc.Coords.z)
    SetBlipSprite(jcBlip, jc.Blip.Sprite)
    SetBlipDisplay(jcBlip, 4)
    SetBlipScale(jcBlip, jc.Blip.Scale)
    SetBlipColour(jcBlip, jc.Blip.Color)
    SetBlipAsShortRange(jcBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(jc.Blip.Label)
    EndTextCommandSetBlipName(jcBlip)
    table.insert(blips, jcBlip)

    -- Duty Checkpoint Blips
    for _, cp in ipairs(CivilianConfig.DutyCheckpoints) do
        if cp.blip then
            local blip = AddBlipForCoord(cp.coords.x, cp.coords.y, cp.coords.z)
            SetBlipSprite(blip, cp.blip.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.7)
            SetBlipColour(blip, cp.blip.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(cp.blip.label)
            EndTextCommandSetBlipName(blip)
            table.insert(blips, blip)
        end
    end
end)

--[[
    Job Center Selection Menu
--]]
local function OpenJobCenterMenu()
    local options = {}

    for _, v in ipairs(CivilianConfig.JobCenter.AvailableJobs) do
        table.insert(options, {
            title = v.label,
            description = v.description,
            icon = v.icon,
            onSelect = function()
                lib.callback('meridian-civilian:server:selectJob', false, function(success, result)
                    if success then
                        lib.notify({
                            title = 'Employment Updated',
                            description = string.format("You are now registered as %s.", result.label),
                            type = 'success'
                        })
                    else
                        lib.notify({
                            title = 'Employment Notice',
                            description = result or 'Unable to switch employment.',
                            type = 'error'
                        })
                    end
                end, v.job)
            end
        })
    end

    lib.registerContext({
        id = 'meridian_job_center_menu',
        title = 'City Employment Office',
        options = options
    })

    lib.showContext('meridian_job_center_menu')
end

--[[
    Toggle Duty at Checkpoint
--]]
local function ToggleDutyCheckpoint(stationName)
    lib.callback('meridian-civilian:server:toggleDuty', false, function(success, onDuty)
        if success then
            local pData = QBCore.Functions.GetPlayerData()
            lib.notify({
                title = stationName,
                description = onDuty and string.format("You clocked IN as %s.", pData.job.label) or string.format("You clocked OUT from %s.", pData.job.label),
                type = onDuty and 'success' or 'info'
            })
        else
            lib.notify({
                title = 'Duty Station',
                description = onDuty or 'Unable to change duty status.',
                type = 'error'
            })
        end
    end)
end

--[[
    Marker Render & Key Interaction Thread
--]]
CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)

        -- 1. Job Center Marker
        local distJc = #(pos - CivilianConfig.JobCenter.Coords)
        if distJc < 15.0 then
            wait = 0
            DrawMarker(20, CivilianConfig.JobCenter.Coords.x, CivilianConfig.JobCenter.Coords.y, CivilianConfig.JobCenter.Coords.z, 0, 0, 0, 0, 0, 0, 0.6, 0.6, 0.6, 0, 150, 255, 200, false, true, 2, false, nil, nil, false)
            if distJc < 2.0 then
                QBCore.Functions.DrawText3D(CivilianConfig.JobCenter.Coords.x, CivilianConfig.JobCenter.Coords.y, CivilianConfig.JobCenter.Coords.z + 0.35, "[~g~E~w~] Browse City Careers")
                if IsControlJustReleased(0, 38) then -- E
                    OpenJobCenterMenu()
                end
            end
        end

        -- 2. Duty Checkpoints
        local pData = QBCore.Functions.GetPlayerData()
        local currentJob = pData and pData.job and pData.job.name

        for _, cp in ipairs(CivilianConfig.DutyCheckpoints) do
            local distCp = #(pos - cp.coords)
            if distCp < 12.0 then
                wait = 0
                local isAllowed = false
                for _, allowed in ipairs(cp.allowedJobs) do
                    if allowed == currentJob then
                        isAllowed = true
                        break
                    end
                end

                if isAllowed then
                    local color = (pData.job and pData.job.onduty) and { r = 0, g = 200, b = 100 } or { r = 255, g = 140, b = 0 }
                    DrawMarker(2, cp.coords.x, cp.coords.y, cp.coords.z, 0, 0, 0, 0, 0, 0, 0.35, 0.35, 0.35, color.r, color.g, color.b, 200, false, true, 2, false, nil, nil, false)
                    if distCp < 1.8 then
                        local dutyStatusText = (pData.job and pData.job.onduty) and "~r~Clock OUT~w~" or "~g~Clock IN~w~"
                        QBCore.Functions.DrawText3D(cp.coords.x, cp.coords.y, cp.coords.z + 0.35, string.format("[~y~E~w~] %s (%s)", dutyStatusText, cp.name))
                        if IsControlJustReleased(0, 38) then -- E
                            ToggleDutyCheckpoint(cp.name)
                        end
                    end
                end
            end
        end

        Wait(wait)
    end
end)

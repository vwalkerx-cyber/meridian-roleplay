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

local function OpenTaxiGarageMenu()
    local pData = QBCore.Functions.GetPlayerData()
    if not (pData and pData.job and pData.job.name == 'taxi' and pData.job.onduty) then
        lib.notify({
            title = 'Taxi Depot',
            description = 'You must be on duty as a Downtown Cab driver to access the taxi garage.',
            type = 'error'
        })
        return
    end

    local options = {
        {
            title = 'Request Taxi Cab',
            description = 'Spawn a company taxi vehicle for your work shift.',
            icon = 'taxi',
            onSelect = function()
                local ped = PlayerPedId()
                local spawnCfg = CivilianConfig.TaxiGarage.SpawnCoords
                local model = CivilianConfig.TaxiGarage.VehicleModel or 'taxi'

                QBCore.Functions.SpawnVehicle(model, function(veh)
                    SetEntityHeading(veh, spawnCfg.w)
                    TaskWarpPedIntoVehicle(ped, veh, -1)
                    TriggerEvent("vehiclekeys:client:SetOwner", QBCore.Functions.GetPlate(veh))
                    SetVehicleEngineOn(veh, true, true, false)
                    lib.notify({
                        title = 'Downtown Cab Co.',
                        description = 'Company taxi dispatched. Drive safely!',
                        type = 'success'
                    })
                end, spawnCfg, true)
            end
        },
        {
            title = 'Store Taxi Cab',
            description = 'Return and store your taxi back into the garage.',
            icon = 'warehouse',
            onSelect = function()
                local ped = PlayerPedId()
                local veh = GetVehiclePedIsIn(ped, false)
                if veh == 0 then
                    local markerPos = CivilianConfig.TaxiGarage.MarkerCoords
                    veh = GetClosestVehicle(markerPos.x, markerPos.y, markerPos.z, 5.0, 0, 71)
                end

                if veh and veh ~= 0 then
                    QBCore.Functions.DeleteVehicle(veh)
                    lib.notify({
                        title = 'Downtown Cab Co.',
                        description = 'Taxi cab stored back into depot.',
                        type = 'info'
                    })
                else
                    lib.notify({
                        title = 'Taxi Depot',
                        description = 'No taxi vehicle nearby to store.',
                        type = 'error'
                    })
                end
            end
        }
    }

    lib.registerContext({
        id = 'meridian_taxi_garage_menu',
        title = 'Downtown Cab Co. Fleet Depot',
        options = options
    })

    lib.showContext('meridian_taxi_garage_menu')
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

        -- 3. Taxi Garage Marker (Downtown Cab Co.)
        if CivilianConfig.TaxiGarage and currentJob == 'taxi' and pData.job.onduty then
            local taxiMarker = CivilianConfig.TaxiGarage.MarkerCoords
            local distTaxi = #(pos - taxiMarker)
            if distTaxi < 15.0 then
                wait = 0
                DrawMarker(36, taxiMarker.x, taxiMarker.y, taxiMarker.z, 0, 0, 0, 0, 0, 0, 0.7, 0.7, 0.7, 255, 204, 0, 200, false, true, 2, false, nil, nil, false)
                if distTaxi < 2.5 then
                    QBCore.Functions.DrawText3D(taxiMarker.x, taxiMarker.y, taxiMarker.z + 0.4, "[~y~E~w~] Taxi Fleet Garage")
                    if IsControlJustReleased(0, 38) then -- E
                        OpenTaxiGarageMenu()
                    end
                end
            end
        end

        Wait(wait)
    end
end)

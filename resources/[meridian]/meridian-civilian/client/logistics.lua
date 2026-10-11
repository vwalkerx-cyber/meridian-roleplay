--[[
    MERIDIAN ROLEPLAY — meridian-civilian/client/logistics.lua
    Client workflow: GPS routing, blips, vehicle spawning, and interaction points.
--]]

local currentShift = nil
local activeBlip = nil
local currentDropBlip = nil
local depotBlip = nil

-- Create depot map blip
CreateThread(function()
    depotBlip = AddBlipForCoord(CivilianConfig.Logistics.DepotCoords.x, CivilianConfig.Logistics.DepotCoords.y, CivilianConfig.Logistics.DepotCoords.z)
    SetBlipSprite(depotBlip, 477) -- Logistics/truck sprite
    SetBlipDisplay(depotBlip, 4)
    SetBlipScale(depotBlip, 0.8)
    SetBlipColour(depotBlip, 5) -- Yellow
    SetBlipAsShortRange(depotBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Meridian State Logistics Depot")
    EndTextCommandSetBlipName(depotBlip)
end)

local function ClearRouteBlip()
    if currentDropBlip and DoesBlipExist(currentDropBlip) then
        RemoveBlip(currentDropBlip)
        currentDropBlip = nil
    end
end

local function SetNextDeliveryBlip(stop)
    ClearRouteBlip()
    if not stop then return end

    currentDropBlip = AddBlipForCoord(stop.coords.x, stop.coords.y, stop.coords.z)
    SetBlipSprite(currentDropBlip, 1)
    SetBlipColour(currentDropBlip, 2) -- Green
    SetBlipRoute(currentDropBlip, true)
    SetBlipRouteColour(currentDropBlip, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Delivery Stop: " .. stop.name)
    EndTextCommandSetBlipName(currentDropBlip)
end

--[[
    Interaction at Depot: Start Shift
--]]
local function StartFreightShift()
    lib.callback('meridian-civilian:server:startLogisticsShift', false, function(success, data)
        if not success then
            lib.notify({
                title = 'Meridian Logistics',
                description = data or 'Unable to start shift.',
                type = 'error'
            })
            return
        end

        currentShift = {
            totalStops = data.totalStops,
            currentIndex = 1,
            currentStop = data.firstStop
        }

        SetNextDeliveryBlip(data.firstStop)

        lib.notify({
            title = 'Meridian Logistics',
            description = string.format("Shift initiated. Route contains %d stops. Proceed to %s.", data.totalStops, data.firstStop.name),
            type = 'success'
        })
    end)
end

--[[
    Interaction at Delivery Location: Complete Dropoff
--]]
local function DeliverCargo()
    if not currentShift then return end

    -- Visual progress bar using ox_lib
    if lib.progressBar({
        duration = 5000,
        label = 'Unloading and delivering cargo package...',
        useWhileDead = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true
        },
        anim = {
            dict = 'anim@heists@box_carry@',
            clip = 'idle'
        }
    }) then
        lib.callback('meridian-civilian:server:completeDropoff', false, function(success, result)
            if not success then
                lib.notify({
                    title = 'Meridian Logistics',
                    description = result or 'Delivery validation failed.',
                    type = 'error'
                })
                return
            end

            lib.notify({
                title = 'Meridian Logistics',
                description = string.format("Delivery signed. Received %s.", exports['meridian-core']:FormatCurrency(result.payout)),
                type = 'success'
            })

            if result.isFinished then
                ClearRouteBlip()
                currentShift = nil
                lib.notify({
                    title = 'Meridian Logistics',
                    description = "All stops completed! Route bonus disbursed.",
                    type = 'success'
                })
            else
                currentShift.currentIndex = currentShift.currentIndex + 1
                currentShift.currentStop = result.nextStop
                SetNextDeliveryBlip(result.nextStop)
                lib.notify({
                    title = 'Next Stop',
                    description = "Proceed to next stop: " .. result.nextStop.name,
                    type = 'info'
                })
            end
        end, currentShift.currentIndex)
    end
end

-- Exported client triggers for radial menu, ox_target, or keybinds
exports('StartFreightShift', StartFreightShift)
exports('DeliverCargo', DeliverCargo)

RegisterNetEvent('meridian-civilian:client:startFreight', StartFreightShift)
RegisterNetEvent('meridian-civilian:client:deliverCargo', DeliverCargo)

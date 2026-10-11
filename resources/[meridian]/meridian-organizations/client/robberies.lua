--[[
    MERIDIAN ROLEPLAY — meridian-organizations/client/robberies.lua
    Client interaction for store registers, progress bar timers, and police alert feedback.
--]]

local function StartStoreRobbery(targetId)
    lib.callback('meridian-organizations:server:startStoreRobbery', false, function(success, data)
        if not success then
            lib.notify({
                title = 'Meridian Syndicate',
                description = data or 'Unable to start robbery.',
                type = 'error'
            })
            return
        end

        lib.notify({
            title = 'Robbery In Progress',
            description = string.format("Alarm tripped! Hold the position for %d seconds while cracking the safe/registers.", data.duration),
            type = 'warning'
        })

        if lib.progressBar({
            duration = data.duration * 1000,
            label = 'Cracking store register...',
            useWhileDead = false,
            canCancel = true,
            disable = { car = true, move = false, combat = false },
            anim = { dict = 'anim@amb@clubhouse@tutorial@bkr_tut_ig3@', clip = 'machinic_loop_mechandplayer' }
        }) then
            lib.callback('meridian-organizations:server:claimRobberyPayout', false, function(claimSuccess, payout)
                if claimSuccess then
                    lib.notify({
                        title = 'Register Emptied',
                        description = string.format("Secured %s in unmarked cash! Evade law enforcement response.", exports['meridian-core']:FormatCurrency(payout)),
                        type = 'success'
                    })
                else
                    lib.notify({
                        title = 'Robbery Failed',
                        description = payout or 'Failed to retrieve cash.',
                        type = 'error'
                    })
                end
            end, targetId)
        else
            lib.notify({
                title = 'Robbery Aborted',
                description = 'You abandoned the register!',
                type = 'error'
            })
        end
    end, targetId)
end

exports('StartStoreRobbery', StartStoreRobbery)
RegisterNetEvent('meridian-organizations:client:startStoreRobbery', StartStoreRobbery)

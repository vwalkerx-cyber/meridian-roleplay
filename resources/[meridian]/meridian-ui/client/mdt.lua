--[[
    MERIDIAN ROLEPLAY — meridian-ui/client/mdt.lua
    In-game interaction commands and NUI/dialog adapters for Police & DOJ records.
--]]

RegisterCommand('mdt', function()
    local hasAccess = exports['meridian-core']:HasPermission(source, {'lspd', 'bcso', 'msp', 'doj'}, 1)
    if not hasAccess then
        lib.notify({
            title = 'Mobile Data Terminal',
            description = 'Access Restricted: Law Enforcement or DOJ credentials required.',
            type = 'error'
        })
        return
    end

    -- Interactive context menu powered by ox_lib
    lib.registerContext({
        id = 'meridian_mdt_menu',
        title = 'Meridian Law Enforcement MDT',
        options = {
            {
                title = 'Active Dispatch Calls',
                description = 'View and respond to active 911/CAD emergencies',
                icon = 'tower-broadcast',
                onSelect = function()
                    lib.callback('meridian-emergency:server:getActiveCalls', false, function(calls)
                        local callOptions = {}
                        for _, call in ipairs(calls or {}) do
                            table.insert(callOptions, {
                                title = string.format("[%s] #%d - %s", call.call_code, call.id, call.title),
                                description = string.format("Priority %d | %s", call.priority, call.message),
                                icon = 'bell'
                            })
                        end
                        if #callOptions == 0 then
                            table.insert(callOptions, { title = 'No active calls', disabled = true })
                        end
                        lib.registerContext({
                            id = 'meridian_mdt_calls',
                            title = 'Active Dispatch Calls',
                            menu = 'meridian_mdt_menu',
                            options = callOptions
                        })
                        lib.showContext('meridian_mdt_calls')
                    end)
                end
            },
            {
                title = 'Search / Create Casefile',
                description = 'Open and review criminal investigations',
                icon = 'folder-open',
                onSelect = function()
                    local input = lib.inputDialog('Create Criminal Casefile', {
                        { type = 'input', label = 'Case Title', placeholder = 'e.g., Innocence Blvd Robbery', required = true },
                        { type = 'textarea', label = 'Investigative Summary', required = true }
                    })
                    if input then
                        TriggerServerEvent('meridian-justice:server:createCase', input[1], input[2])
                    end
                end
            },
            {
                title = 'Request Legal Warrant',
                description = 'File an arrest or search warrant for judicial review',
                icon = 'file-shield',
                onSelect = function()
                    local input = lib.inputDialog('Request Warrant', {
                        { type = 'input', label = 'Case ID', placeholder = 'CASE-2026-XXXX', required = true },
                        { type = 'input', label = 'Target Citizen ID', required = true },
                        { type = 'input', label = 'Target Full Name', required = true },
                        { type = 'select', label = 'Warrant Type', options = { { value = 'arrest', label = 'Arrest Warrant' }, { value = 'search', label = 'Search Warrant' } } },
                        { type = 'textarea', label = 'Probable Cause Rationale', required = true }
                    })
                    if input then
                        TriggerServerEvent('meridian-justice:server:requestWarrant', input[1], input[2], input[3], input[4], input[5])
                    end
                end
            }
        }
    })

    lib.showContext('meridian_mdt_menu')
end, false)

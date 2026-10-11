--[[
    MERIDIAN ROLEPLAY — server/main.lua
    Lifecycle initialization for meridian-core.
--]]

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    Meridian.Logger.Audit("SYSTEM", "RESOURCE_START", {
        resource = resourceName,
        version = GetResourceMetadata(resourceName, 'version', 0)
    })

    print(string.format("^2[%s]^7 Initialized successfully. State of Meridian systems online.", resourceName))
end)

--[[
    MERIDIAN ROLEPLAY — meridian-emergency/shared/config.lua
--]]

EmergencyConfig = {}

EmergencyConfig.Agencies = {
    lspd = { label = "Los Santos Police Department", color = 3 },
    bcso = { label = "Blaine County Sheriff's Office", color = 2 },
    msp  = { label = "Meridian State Police", color = 38 },
    ems  = { label = "Meridian Emergency Medical Services", color = 1 }
}

EmergencyConfig.CallCodes = {
    ['10-90'] = { title = "Armed Robbery in Progress", priority = 3 },
    ['10-31'] = { title = "Crime in Progress", priority = 2 },
    ['10-71'] = { title = "Shots Fired", priority = 3 },
    ['10-47'] = { title = "Injured Civilian / Medical Request", priority = 3 },
    ['10-50'] = { title = "Vehicle Collision", priority = 1 }
}

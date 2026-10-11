--[[
    MERIDIAN ROLEPLAY — meridian-organizations/shared/config.lua
--]]

OrgConfig = {}

OrgConfig.MaxMembersPerOrg = 20
OrgConfig.BaseInfluence = 100

-- Robbery parameters
OrgConfig.Robbery = {
    DurationSeconds = 45,       -- Must hold the objective for 45s
    CooldownSeconds = 1800,     -- 30 min cooldown per target
    MinCashPayout = 800,
    MaxCashPayout = 1800,
    InfluenceReward = 15,
    RequiredCopsOnline = 0      -- Set to 0 for early testing; tune to 2+ for live play
}

OrgConfig.StoreTargets = {
    ['store_247_innocence'] = {
        name = "24/7 Supermarket Innocence Blvd",
        coords = vec3(25.6, -1346.5, 29.5)
    },
    ['store_ltd_grove'] = {
        name = "LTD Gasoline Grove St",
        coords = vec3(-48.4, -1757.7, 29.4)
    }
}

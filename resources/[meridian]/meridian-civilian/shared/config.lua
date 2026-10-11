--[[
    MERIDIAN ROLEPLAY — meridian-civilian/shared/config.lua
    Configuration for logistics depot, dropoff routes, wages, and security thresholds.
--]]

CivilianConfig = {}

CivilianConfig.Logistics = {
    -- Depot location (Port of Los Santos / Elysian Island)
    DepotCoords = vec3(153.25, -3211.5, 5.9),
    DepotHeading = 270.0,
    
    VehicleModel = `mule`,
    VehicleSpawnCoords = vec4(142.0, -3204.0, 5.85, 270.0),
    
    -- Security thresholds
    MinDeliveryDurationSeconds = 25, -- Minimum plausible travel time before dropoff can succeed
    MaxDropoffsPerRoute = 5,
    SecurityDistanceDropoff = 15.0,  -- Maximum player distance to drop point
    
    -- Economy balancing (provisional)
    BasePayPerDropoff = 175,
    MileageBonusPerKm = 80,
    CompletionBonus = 350,
    
    -- Dropoff nodes across Los Santos & Blaine County
    DropoffNodes = {
        { id = 1, name = "24/7 Supermarket Innocence Blvd", coords = vec3(25.6, -1346.5, 29.5) },
        { id = 2, name = "Liquor Ace Vinewood", coords = vec3(1135.8, -982.2, 46.4) },
        { id = 3, name = "Robs Liquor Great Ocean Hwy", coords = vec3(-3039.5, 585.9, 7.9) },
        { id = 4, name = "Limited LTD Gasoline Grove St", coords = vec3(-48.4, -1757.7, 29.4) },
        { id = 5, name = "Sandy Shores Medical Pantry", coords = vec3(1853.8, 3687.9, 34.2) },
        { id = 6, name = "Paleto Bay General Store", coords = vec3(-160.6, 6321.8, 31.5) }
    }
}

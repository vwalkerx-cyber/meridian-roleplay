--[[
    MERIDIAN ROLEPLAY — meridian-civilian/shared/config.lua
    Configuration for logistics depot, employment center, public jobs, duty checkpoints.
--]]

CivilianConfig = {}

--[[
    Public Career Employment Center (City Hall / Job Center)
    Players can visit this location to browse, apply, or quit public jobs.
--]]
CivilianConfig.JobCenter = {
    Coords = vec3(-544.95, -204.65, 38.22), -- Los Santos City Hall
    Heading = 210.0,
    Blip = {
        Sprite = 407,
        Color = 3,
        Scale = 0.85,
        Label = "City Employment Center"
    },
    AvailableJobs = {
        {
            job = 'unemployed',
            label = 'Civilian (Freelancer)',
            description = 'Leave current formal employment and become a self-employed freelancer.',
            icon = 'user'
        },
        {
            job = 'garbage',
            label = 'Department of Sanitation',
            description = 'San Andreas municipal waste collection. Reliable municipal wage.',
            icon = 'trash'
        },
        {
            job = 'bus',
            label = 'Transit Authority',
            description = 'Public bus transit operator. City routes and express coach shifts.',
            icon = 'bus'
        },
        {
            job = 'taxi',
            label = 'Downtown Cab Co.',
            description = 'Passenger taxi and transport services across greater Los Santos.',
            icon = 'taxi'
        },
        {
            job = 'trucker',
            label = 'State Logistics & Hauling',
            description = 'Freight supply chain logistics, port distributions, and deliveries.',
            icon = 'truck'
        },
        {
            job = 'tow',
            label = 'Impound & Towing',
            description = 'Vehicle recovery, roadside assistance, and city impound services.',
            icon = 'truck-pickup'
        },
        {
            job = 'reporter',
            label = 'Weazel News Network',
            description = 'Field reporting, breaking news coverage, and investigative journalism.',
            icon = 'newspaper'
        },
        {
            job = 'vineyard',
            label = 'Marlowe Vineyards',
            description = 'Agricultural harvesting, grape sorting, and fine winemaking.',
            icon = 'wine-bottle'
        },
        {
            job = 'hotdog',
            label = 'Street Vendors Guild',
            description = 'Operate mobile street carts and sell fast food across the city.',
            icon = 'hotdog'
        }
    }
}

--[[
    Duty Stations & Checkpoints
    Allows workers to clock in and out on duty.
--]]
CivilianConfig.DutyCheckpoints = {
    {
        name = "City Hall Employment Office",
        coords = vec3(-543.2, -202.8, 38.22),
        allowedJobs = { 'garbage', 'bus', 'taxi', 'trucker', 'tow', 'reporter', 'vineyard', 'hotdog' },
        blip = false
    },
    {
        name = "Sanitation Depot Clock-In",
        coords = vec3(-321.8, -1546.0, 31.0),
        allowedJobs = { 'garbage' },
        blip = { sprite = 318, color = 5, label = "Sanitation Duty Station" }
    },
    {
        name = "Transit Bus Terminal Clock-In",
        coords = vec3(453.6, -600.8, 28.5),
        allowedJobs = { 'bus' },
        blip = { sprite = 513, color = 5, label = "Transit Duty Station" }
    },
    {
        name = "Downtown Cab Depot Clock-In",
        coords = vec3(902.8, -165.6, 74.0),
        allowedJobs = { 'taxi' },
        blip = { sprite = 198, color = 5, label = "Taxi Duty Station" }
    },
    {
        name = "Logistics Freight Depot Clock-In",
        coords = vec3(153.25, -3211.5, 5.9),
        allowedJobs = { 'trucker' },
        blip = false -- Covered by main freight depot blip
    },
    {
        name = "Los Santos Tow Impound Clock-In",
        coords = vec3(409.0, -1623.2, 29.3),
        allowedJobs = { 'tow' },
        blip = { sprite = 68, color = 5, label = "Towing Duty Station" }
    },
    {
        name = "Weazel News Headquarters Clock-In",
        coords = vec3(-598.6, -929.8, 23.8),
        allowedJobs = { 'reporter' },
        blip = { sprite = 459, color = 5, label = "Weazel News Duty Station" }
    },
    {
        name = "Marlowe Vineyards Clock-In",
        coords = vec3(-1928.0, 2060.0, 140.8),
        allowedJobs = { 'vineyard' },
        blip = { sprite = 85, color = 5, label = "Vineyard Duty Station" }
    }
}

CivilianConfig.Logistics = {
    -- Depot location (Port of Los Santos / Elysian Island)
    DepotCoords = vec3(153.25, -3211.5, 5.9),
    DepotHeading = 270.0,
    
    VehicleModel = `mule`,
    VehicleSpawnCoords = vec4(142.0, -3204.0, 5.85, 270.0),
    
    -- Security thresholds
    MinDeliveryDurationSeconds = 25,
    MaxDropoffsPerRoute = 5,
    SecurityDistanceDropoff = 15.0,
    
    -- Economy balancing
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

--[[
    MERIDIAN ROLEPLAY — meridian-organizations/server/territories.lua
    Territory influence calculations, contestation cooldowns, and zone dominance.
--]]

local MeridianTerritories = {}

--[[
    Get all territory influence states
--]]
function MeridianTerritories.GetAllTerritories()
    return MySQL.query.await([[
        SELECT t.*, o.name AS dominant_org_name 
        FROM meridian_territory_influence t
        LEFT JOIN meridian_organizations o ON t.dominant_org_id = o.org_id
    ]])
end

--[[
    Contest territory influence
--]]
function MeridianTerritories.ContestInfluence(zoneName, orgId, influenceDelta, citizenId)
    local territory = MySQL.single.await([[
        SELECT * FROM meridian_territory_influence WHERE zone_name = ? LIMIT 1
    ]], { zoneName })

    if not territory then return false, "Zone does not exist." end

    local newScore = territory.influence_score
    local dominant = territory.dominant_org_id

    if dominant == orgId then
        newScore = newScore + influenceDelta
    else
        newScore = newScore - influenceDelta
        if newScore <= 0 then
            dominant = orgId
            newScore = math.abs(newScore)
        end
    end

    MySQL.update.await([[
        UPDATE meridian_territory_influence 
        SET dominant_org_id = ?, influence_score = ?, last_contested_at = NOW() 
        WHERE zone_name = ?
    ]], { dominant, newScore, zoneName })

    exports['meridian-core']:LogAudit(citizenId, "TERRITORY_INFLUENCE_CONTESTED", {
        zone = zoneName,
        org = orgId,
        newDominant = dominant,
        newScore = newScore
    })

    return true, { dominant = dominant, score = newScore }
end

exports('GetAllTerritories', MeridianTerritories.GetAllTerritories)
exports('ContestInfluence', MeridianTerritories.ContestInfluence)

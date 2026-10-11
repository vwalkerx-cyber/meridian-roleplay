--[[
    MERIDIAN ROLEPLAY — meridian-organizations/server/organizations.lua
    Criminal syndicate management and influence rating tracking.
--]]

local MeridianOrgs = {}

function MeridianOrgs.GetOrganization(orgId)
    return MySQL.single.await([[
        SELECT * FROM meridian_organizations WHERE org_id = ? LIMIT 1
    ]], { orgId })
end

function MeridianOrgs.GetMemberRank(orgId, citizenId)
    return MySQL.single.await([[
        SELECT rank, role_title, can_manage, can_armory 
        FROM meridian_organization_members 
        WHERE org_id = ? AND citizenid = ? 
        LIMIT 1
    ]], { orgId, citizenId })
end

function MeridianOrgs.CreateOrganization(orgId, name, leaderCitizenId, tagline)
    local existing = MeridianOrgs.GetOrganization(orgId)
    if existing then return false, "Organization ID already exists." end

    local queries = {
        {
            query = [[
                INSERT INTO meridian_organizations (org_id, name, leader_citizenid, tagline, influence_score)
                VALUES (?, ?, ?, ?, ?)
            ]],
            values = { orgId, name, leaderCitizenId, tagline or "", OrgConfig.BaseInfluence }
        },
        {
            query = [[
                INSERT INTO meridian_organization_members (org_id, citizenid, rank, role_title, can_manage, can_armory)
                VALUES (?, ?, 5, 'Boss', 1, 1)
            ]],
            values = { orgId, leaderCitizenId }
        }
    }

    local success, err = exports['meridian-core']:ExecuteTransaction(queries)
    if not success then
        exports['meridian-core']:LogError("ORG_CREATE", "Failed to create organization", tostring(err))
        return false, "Failed to register organization."
    end

    exports['meridian-core']:LogAudit(leaderCitizenId, "ORGANIZATION_CREATED", {
        orgId = orgId,
        name = name
    })

    return true
end

function MeridianOrgs.AdjustInfluence(orgId, delta)
    MySQL.update.await([[
        UPDATE meridian_organizations SET influence_score = GREATEST(0, influence_score + ?) WHERE org_id = ?
    ]], { delta, orgId })
end

exports('GetOrganization', MeridianOrgs.GetOrganization)
exports('GetMemberRank', MeridianOrgs.GetMemberRank)
exports('CreateOrganization', MeridianOrgs.CreateOrganization)
exports('AdjustInfluence', MeridianOrgs.AdjustInfluence)

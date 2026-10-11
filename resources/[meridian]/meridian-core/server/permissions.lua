--[[
    MERIDIAN ROLEPLAY — server/permissions.lua
    Server-authoritative role, job, and permission checks.
--]]

Meridian = Meridian or {}
Meridian.Permissions = {}

local QBCore = nil

local function GetQBCoreObject()
    if QBCore then return QBCore end
    local status, obj = pcall(function()
        return exports['qb-core']:GetCoreObject()
    end)
    if status and obj then
        QBCore = obj
        return QBCore
    end
    return nil
end

function Meridian.Permissions.GetPlayer(source)
    local qb = GetQBCoreObject()
    if not qb then return nil end
    return qb.Functions.GetPlayer(source)
end

function Meridian.Permissions.GetCitizenId(source)
    local player = Meridian.Permissions.GetPlayer(source)
    if not player or not player.PlayerData then return nil end
    return player.PlayerData.citizenid
end

function Meridian.Permissions.GetJob(source)
    local player = Meridian.Permissions.GetPlayer(source)
    if not player or not player.PlayerData or not player.PlayerData.job then
        return { name = "unemployed", grade = { level = 0, name = "Unemployed" }, onduty = false }
    end
    return player.PlayerData.job
end

function Meridian.Permissions.IsOnDuty(source)
    local job = Meridian.Permissions.GetJob(source)
    return job and job.onduty == true
end

--[[
    Validates if a player matches a job and optional minimum grade.
    requiredJob: string or table of strings (e.g., {'lspd', 'bcso', 'msp'})
    minGrade: integer (optional)
--]]
function Meridian.Permissions.HasJobPermission(source, requiredJob, minGrade)
    local job = Meridian.Permissions.GetJob(source)
    if not job then return false end

    local jobMatches = false
    if type(requiredJob) == "table" then
        for _, name in ipairs(requiredJob) do
            if job.name == name then
                jobMatches = true
                break
            end
        end
    else
        jobMatches = (job.name == requiredJob)
    end

    if not jobMatches then return false end

    if minGrade and (job.grade.level < minGrade) then
        return false
    end

    return true
end

exports('GetPlayerCitizenId', Meridian.Permissions.GetCitizenId)
exports('GetPlayerJob', Meridian.Permissions.GetJob)
exports('IsDuty', Meridian.Permissions.IsOnDuty)
exports('HasPermission', Meridian.Permissions.HasJobPermission)

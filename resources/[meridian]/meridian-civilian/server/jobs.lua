--[[
    MERIDIAN ROLEPLAY — meridian-civilian/server/jobs.lua
    Server callbacks and authority for selecting civilian jobs and toggling duty.
--]]

local QBCore = exports['qb-core']:GetCoreObject()

--[[
    Apply for a public job from the Job Center
--]]
lib.callback.register('meridian-civilian:server:selectJob', function(source, jobName)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false, "Player not found." end

    local currentJob = Player.PlayerData.job.name
    if currentJob == jobName then
        return false, "You already hold this employment title."
    end

    -- Verify job is in public roster
    local isAllowed = false
    for _, v in ipairs(CivilianConfig.JobCenter.AvailableJobs) do
        if v.job == jobName then
            isAllowed = true
            break
        end
    end

    if not isAllowed then
        return false, "This job is not open for public application."
    end

    -- Assign grade 0 for civilian career
    local success = Player.Functions.SetJob(jobName, 0)
    if success then
        Player.Functions.SetJobDuty(true)
        exports['meridian-core']:LogAudit(Player.PlayerData.citizenid, "PUBLIC_JOB_SELECTED", {
            previousJob = currentJob,
            newJob = jobName
        })
        return true, { job = jobName, label = QBCore.Shared.Jobs[jobName].label }
    end

    return false, "Unable to update employment records."
end)

--[[
    Toggle duty at a checkpoint
--]]
lib.callback.register('meridian-civilian:server:toggleDuty', function(source)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then return false, "Player not found." end

    local job = Player.PlayerData.job
    local newDutyState = not job.onduty
    Player.Functions.SetJobDuty(newDutyState)

    exports['meridian-core']:LogAudit(Player.PlayerData.citizenid, "DUTY_TOGGLED", {
        job = job.name,
        onDuty = newDutyState
    })

    return true, newDutyState
end)

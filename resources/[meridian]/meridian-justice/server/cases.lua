--[[
    MERIDIAN ROLEPLAY — meridian-justice/server/cases.lua
    Casefile management, warrant requests, judge approvals, and penal citations.
--]]

local MeridianJustice = {}

--[[
    Create a new criminal casefile
--]]
function MeridianJustice.CreateCase(title, summary, leadInvestigator, agency)
    agency = agency or 'lspd'
    local caseNumber = string.format("CASE-%s-%d", os.date("%Y"), math.random(1000, 9999))

    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_cases (case_number, title, summary, lead_investigator_citizenid, agency, status)
        VALUES (?, ?, ?, ?, ?, 'open')
    ]], { caseNumber, title, summary, leadInvestigator, agency })

    if insertId then
        exports['meridian-core']:LogAudit(leadInvestigator, "CASE_CREATED", {
            caseNumber = caseNumber,
            title = title,
            agency = agency
        })
        return true, caseNumber
    end
    return false, "Failed to create case file."
end

--[[
    Add a suspect to a casefile
--]]
function MeridianJustice.AddSuspect(caseNumber, suspectCitizenId, involvement, notes, officerCitizenId)
    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_case_suspects (case_id, citizenid, involvement_level, notes)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE involvement_level = VALUES(involvement_level), notes = VALUES(notes)
    ]], { caseNumber, suspectCitizenId, involvement or 'person_of_interest', notes or '' })

    exports['meridian-core']:LogAudit(officerCitizenId, "CASE_SUSPECT_ADDED", {
        caseNumber = caseNumber,
        suspect = suspectCitizenId,
        involvement = involvement
    })

    return true
end

--[[
    Request a warrant (arrest or search)
--]]
function MeridianJustice.RequestWarrant(caseNumber, targetCitizenId, targetName, warrantType, reason, officerCitizenId)
    local warrantId = string.format("WAR-%s-%d", os.date("%Y"), math.random(1000, 9999))
    local expiresAt = os.date("!%Y-%m-%d %H:%M:%S", os.time() + (7 * 86400)) -- 7 days expiry

    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_warrants (warrant_id, case_id, target_citizenid, target_name, warrant_type, requested_by, reason, status, expires_at)
        VALUES (?, ?, ?, ?, ?, ?, ?, 'pending', ?)
    ]], { warrantId, caseNumber, targetCitizenId, targetName, warrantType or 'arrest', officerCitizenId, reason, expiresAt })

    if insertId then
        exports['meridian-core']:LogAudit(officerCitizenId, "WARRANT_REQUESTED", {
            warrantId = warrantId,
            target = targetCitizenId,
            type = warrantType
        })
        return true, warrantId
    end

    return false, "Failed to request warrant."
end

--[[
    Approve or deny warrant (DOJ / Judge role authoritative)
--]]
function MeridianJustice.ReviewWarrant(warrantId, isApproved, judgeCitizenId)
    local newStatus = isApproved and 'approved' or 'denied'
    MySQL.update.await([[
        UPDATE meridian_warrants 
        SET status = ?, approved_by_judge = ? 
        WHERE warrant_id = ? AND status = 'pending'
    ]], { newStatus, judgeCitizenId, warrantId })

    exports['meridian-core']:LogAudit(judgeCitizenId, "WARRANT_REVIEWED", {
        warrantId = warrantId,
        approved = isApproved
    })

    return true
end

-- Exports
exports('CreateCase', MeridianJustice.CreateCase)
exports('AddSuspect', MeridianJustice.AddSuspect)
exports('RequestWarrant', MeridianJustice.RequestWarrant)
exports('ReviewWarrant', MeridianJustice.ReviewWarrant)

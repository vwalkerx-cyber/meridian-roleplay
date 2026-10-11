--[[
    MERIDIAN ROLEPLAY — meridian-justice/server/evidence.lua
    Forensic evidence registry, ballistics, DNA hashing, and chain-of-custody tracking.
--]]

local MeridianEvidence = {}

--[[
    Create physical evidence entry
--]]
function MeridianEvidence.CreateEvidence(evidenceType, identifier, description, coords, collectedBy, caseId)
    local evidenceId = string.format("EVD-%s-%d", os.date("%Y%m%d"), math.random(10000, 99999))
    local x = (coords and coords.x) or nil
    local y = (coords and coords.y) or nil
    local z = (coords and coords.z) or nil

    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_evidence 
        (evidence_id, evidence_type, identifier, description, case_id, collected_by, coords_x, coords_y, coords_z)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]], { evidenceId, evidenceType, identifier, description, caseId, collectedBy, x, y, z })

    if insertId then
        exports['meridian-core']:LogAudit(collectedBy, "EVIDENCE_REGISTERED", {
            evidenceId = evidenceId,
            type = evidenceType,
            identifier = identifier,
            caseId = caseId
        })
        return evidenceId
    end

    return nil
end

--[[
    Get evidence record by ID
--]]
function MeridianEvidence.GetEvidenceById(evidenceId)
    return MySQL.single.await([[
        SELECT * FROM meridian_evidence WHERE evidence_id = ? LIMIT 1
    ]], { evidenceId })
end

--[[
    Update chain of custody location / handler
--]]
function MeridianEvidence.TransferEvidenceCustody(evidenceId, newLocation, officerCitizenId)
    local current = MeridianEvidence.GetEvidenceById(evidenceId)
    if not current then return false, "Evidence not found." end

    MySQL.update.await([[
        UPDATE meridian_evidence SET current_location = ? WHERE evidence_id = ?
    ]], { newLocation, evidenceId })

    exports['meridian-core']:LogAudit(officerCitizenId, "EVIDENCE_CUSTODY_TRANSFER", {
        evidenceId = evidenceId,
        from = current.current_location,
        to = newLocation
    })

    return true
end

-- Exports
exports('CreateEvidence', MeridianEvidence.CreateEvidence)
exports('GetEvidenceById', MeridianEvidence.GetEvidenceById)
exports('TransferEvidenceCustody', MeridianEvidence.TransferEvidenceCustody)

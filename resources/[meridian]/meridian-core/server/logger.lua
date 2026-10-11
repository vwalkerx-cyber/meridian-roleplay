--[[
    MERIDIAN ROLEPLAY — server/logger.lua
    Structured JSON audit, security, and error logging.
--]]

Meridian = Meridian or {}
Meridian.Logger = {}

local LogLevels = {
    debug = 1,
    info = 2,
    warn = 3,
    error = 4
}

local function CurrentTimestamp()
    return os.date("!%Y-%m-%dT%H:%M:%SZ")
end

local function OutputLog(level, category, message, metadata)
    local configuredLevel = (Meridian.Config and Meridian.Config.LogLevel) or "debug"
    if (LogLevels[level] or 1) < (LogLevels[configuredLevel] or 1) then
        return
    end

    local payload = {
        timestamp = CurrentTimestamp(),
        level = string.upper(level),
        category = category,
        message = message,
        data = metadata or {}
    }

    local serialized = json.encode(payload)
    print(string.format("^4[MERIDIAN-%s]^7 ^3[%s]^7 %s", string.upper(level), category, serialized))

    -- Persist security & audit records asynchronously to database if oxmysql is loaded
    if category == "AUDIT" or category == "SECURITY" then
        pcall(function()
            if MySQL and MySQL.insert then
                MySQL.insert.await([[
                    INSERT INTO meridian_audit_logs (category, message, metadata, created_at)
                    VALUES (?, ?, ?, NOW())
                ]], { category, message, json.encode(metadata or {}) })
            end
        end)
    end
end

function Meridian.Logger.Audit(sourceIdentifier, action, details)
    OutputLog("info", "AUDIT", string.format("Action [%s] by [%s]", action, tostring(sourceIdentifier)), {
        actor = sourceIdentifier,
        action = action,
        details = details
    })
end

function Meridian.Logger.Security(sourceIdentifier, reason, details)
    OutputLog("warn", "SECURITY", string.format("Security alert: [%s] by [%s]", reason, tostring(sourceIdentifier)), {
        actor = sourceIdentifier,
        reason = reason,
        details = details
    })
end

function Meridian.Logger.Error(source, errorMessage, stackTrace)
    OutputLog("error", "ERROR", tostring(errorMessage), {
        source = source,
        stack = stackTrace or debug.traceback()
    })
end

exports('LogAudit', Meridian.Logger.Audit)
exports('LogSecurity', Meridian.Logger.Security)
exports('LogError', Meridian.Logger.Error)

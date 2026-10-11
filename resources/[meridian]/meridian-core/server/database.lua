--[[
    MERIDIAN ROLEPLAY — server/database.lua
    Database abstraction and safe transaction executor wrapping oxmysql.
--]]

Meridian = Meridian or {}
Meridian.Database = {}

--[[
    Execute a series of queries in an atomic database transaction.
    queries: array of { query = string, values = table }
    returns: boolean success, table/string resultOrError
--]]
function Meridian.Database.Transaction(queries)
    if not queries or #queries == 0 then
        return false, "No queries provided to transaction"
    end

    if not MySQL or not MySQL.transaction then
        Meridian.Logger.Error("DATABASE", "oxmysql MySQL.transaction is not available.")
        return false, "Database driver unavailable"
    end

    local success, result = pcall(function()
        return MySQL.transaction.await(queries)
    end)

    if not success then
        Meridian.Logger.Error("DATABASE", "Database transaction failed", tostring(result))
        return false, result
    end

    return true, result
end

exports('ExecuteTransaction', Meridian.Database.Transaction)

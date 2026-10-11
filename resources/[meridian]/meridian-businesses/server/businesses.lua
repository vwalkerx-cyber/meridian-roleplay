--[[
    MERIDIAN ROLEPLAY — meridian-businesses/server/businesses.lua
    Business registry, role-based access, and fund-backed payroll distribution.
--]]

local MeridianBusinesses = {}

--[[
    Fetch business details
--]]
function MeridianBusinesses.GetBusiness(businessId)
    return MySQL.single.await([[
        SELECT * FROM meridian_businesses WHERE business_id = ? LIMIT 1
    ]], { businessId })
end

--[[
    Get employee role and permissions within a business
--]]
function MeridianBusinesses.GetEmployeeRole(businessId, citizenId)
    return MySQL.single.await([[
        SELECT role, salary, can_invoice, can_withdraw, can_hire 
        FROM meridian_business_employees 
        WHERE business_id = ? AND citizenid = ? 
        LIMIT 1
    ]], { businessId, citizenId })
end

--[[
    Register a new legal enterprise
--]]
function MeridianBusinesses.RegisterBusiness(businessId, label, ownerCitizenId)
    local existing = MeridianBusinesses.GetBusiness(businessId)
    if existing then
        return false, "Business ID already registered."
    end

    -- Create dedicated corporate bank account
    local accountNumber = exports['meridian-banking']:CreateAccount("business", label .. " Operating Account", businessId, 5000)
    if not accountNumber then
        return false, "Failed to create corporate account."
    end

    local queries = {
        {
            query = [[
                INSERT INTO meridian_businesses (business_id, label, owner_citizenid, account_number)
                VALUES (?, ?, ?, ?)
            ]],
            values = { businessId, label, ownerCitizenId, accountNumber }
        },
        {
            query = [[
                INSERT INTO meridian_business_employees (business_id, citizenid, role, salary, can_invoice, can_withdraw, can_hire)
                VALUES (?, ?, 'owner', 0, 1, 1, 1)
            ]],
            values = { businessId, ownerCitizenId }
        }
    }

    local success, err = exports['meridian-core']:ExecuteTransaction(queries)
    if not success then
        exports['meridian-core']:LogError("BUSINESS_REGISTER", "Failed to register enterprise", tostring(err))
        return false, "Failed to register enterprise."
    end

    exports['meridian-core']:LogAudit(ownerCitizenId, "BUSINESS_REGISTERED", {
        businessId = businessId,
        label = label,
        account = accountNumber
    })

    return true, accountNumber
end

--[[
    Process payroll for all employees of a business.
    Guarantees: Funds are withdrawn directly from the business treasury.
                If business treasury is insufficient, payroll halts without partial balance corruption.
--]]
function MeridianBusinesses.ProcessPayroll(businessId, actorCitizenId)
    local biz = MeridianBusinesses.GetBusiness(businessId)
    if not biz then
        return false, "Business not found."
    end

    local callerRole = MeridianBusinesses.GetEmployeeRole(businessId, actorCitizenId)
    if not callerRole or (callerRole.role ~= 'owner' and callerRole.role ~= 'manager') then
        return false, exports['meridian-core']:GetLocale('common_no_permission')
    end

    local employees = MySQL.query.await([[
        SELECT e.citizenid, e.salary, a.account_number AS personal_account
        FROM meridian_business_employees e
        JOIN meridian_bank_accounts a ON a.owner_identifier = e.citizenid AND a.account_type = 'personal'
        WHERE e.business_id = ? AND e.salary > 0
    ]], { businessId })

    if not employees or #employees == 0 then
        return false, "No salaried employees found."
    end

    -- Calculate total payroll liability
    local totalRequired = 0
    for _, emp in ipairs(employees) do
        totalRequired = totalRequired + emp.salary
    end

    local bizBalance = exports['meridian-banking']:GetAccountBalance(biz.account_number)
    if not bizBalance or bizBalance < totalRequired then
        return false, exports['meridian-core']:GetLocale('common_insufficient_funds') .. " (Payroll liability exceeds treasury balance)."
    end

    -- Build atomic payroll batch
    local txQueries = {}
    local refPrefix = string.format("PAY-%s-%d", os.date("%Y%m%d"), math.random(1000, 9999))

    -- 1. Deduct total from business account
    table.insert(txQueries, {
        query = "UPDATE meridian_bank_accounts SET balance = balance - ? WHERE account_number = ?",
        values = { totalRequired, biz.account_number }
    })

    -- 2. Credit each employee and record transaction
    for i, emp in ipairs(employees) do
        table.insert(txQueries, {
            query = "UPDATE meridian_bank_accounts SET balance = balance + ? WHERE account_number = ?",
            values = { emp.salary, emp.personal_account }
        })
        table.insert(txQueries, {
            query = [[
                INSERT INTO meridian_bank_transactions 
                (transaction_reference, from_account, to_account, amount, category, description, performed_by)
                VALUES (?, ?, ?, ?, 'payroll', ?, ?)
            ]],
            values = {
                string.format("%s-%d", refPrefix, i),
                biz.account_number,
                emp.personal_account,
                emp.salary,
                string.format("Payroll from %s", biz.label),
                actorCitizenId
            }
        })
    end

    local success, err = exports['meridian-core']:ExecuteTransaction(txQueries)
    if not success then
        exports['meridian-core']:LogError("PAYROLL_PROCESS", "Transaction failed", tostring(err))
        return false, "Failed to disburse payroll atomically."
    end

    exports['meridian-core']:LogAudit(actorCitizenId, "PAYROLL_DISBURSED", {
        business = businessId,
        totalAmount = totalRequired,
        employeeCount = #employees
    })

    return true, { total = totalRequired, count = #employees }
end

-- Callbacks
lib.callback.register('meridian-businesses:server:runPayroll', function(source, businessId)
    local cid = exports['meridian-core']:GetPlayerCitizenId(source)
    if not cid then return false, "Player not found." end
    return MeridianBusinesses.ProcessPayroll(businessId, cid)
end)

-- Exports
exports('GetBusiness', MeridianBusinesses.GetBusiness)
exports('GetEmployeeRole', MeridianBusinesses.GetEmployeeRole)
exports('ProcessPayroll', MeridianBusinesses.ProcessPayroll)
exports('RegisterBusiness', MeridianBusinesses.RegisterBusiness)

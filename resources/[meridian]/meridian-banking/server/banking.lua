--[[
    MERIDIAN ROLEPLAY — meridian-banking/server/banking.lua
    Atomic transfers, double-entry ledger bookkeeping, and invoice processing.
--]]

local MeridianBanking = {}

local function GenerateAccountNumber(prefix)
    local chars = "0123456789"
    local num = (prefix or "MRD") .. "-"
    for i = 1, 6 do
        local r = math.random(1, #chars)
        num = num .. string.sub(chars, r, r)
    end
    return num
end

--[[
    Fetch balance of an account
--]]
function MeridianBanking.GetAccountBalance(accountNumber)
    local row = MySQL.single.await([[
        SELECT balance, is_frozen FROM meridian_bank_accounts WHERE account_number = ? LIMIT 1
    ]], { accountNumber })
    if not row then return nil end
    return row.balance, row.is_frozen == 1
end

--[[
    Create a new account
--]]
function MeridianBanking.CreateAccount(accountType, name, ownerIdentifier, initialBalance)
    local accNum = GenerateAccountNumber(accountType == "business" and "BIZ" or "PER")
    local balance = initialBalance or 0

    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_bank_accounts (account_number, account_name, account_type, owner_identifier, balance)
        VALUES (?, ?, ?, ?, ?)
    ]], { accNum, name, accountType, ownerIdentifier, balance })

    if insertId then
        exports['meridian-core']:LogAudit(ownerIdentifier, "BANK_ACCOUNT_CREATED", {
            accountNumber = accNum,
            type = accountType,
            initialBalance = balance
        })
        return accNum
    end
    return nil
end

--[[
    Atomic double-entry fund transfer
--]]
function MeridianBanking.TransferFunds(fromAcc, toAcc, amount, category, description, actorIdentifier)
    amount = math.floor(tonumber(amount) or 0)
    if amount < BankingConfig.MinTransferAmount or amount > BankingConfig.MaxTransferAmount then
        return false, "Invalid transfer amount."
    end

    if fromAcc == toAcc then
        return false, "Cannot transfer funds to the same account."
    end

    -- Verify source account has sufficient funds
    local fromData = MySQL.single.await([[
        SELECT balance, is_frozen FROM meridian_bank_accounts WHERE account_number = ? LIMIT 1
    ]], { fromAcc })

    if not fromData then
        return false, "Origin account does not exist."
    end

    if fromData.is_frozen == 1 then
        return false, "Origin account is frozen by court or state order."
    end

    if fromData.balance < amount then
        return false, exports['meridian-core']:GetLocale('common_insufficient_funds')
    end

    local toData = MySQL.single.await([[
        SELECT id, is_frozen FROM meridian_bank_accounts WHERE account_number = ? LIMIT 1
    ]], { toAcc })

    if not toData then
        return false, "Destination account does not exist."
    end

    if toData.is_frozen == 1 then
        return false, "Destination account is frozen."
    end

    local reference = string.format("TX-%s-%d", os.date("%Y%m%d"), math.random(100000, 999999))

    -- Atomic database transaction
    local queries = {
        {
            query = "UPDATE meridian_bank_accounts SET balance = balance - ? WHERE account_number = ?",
            values = { amount, fromAcc }
        },
        {
            query = "UPDATE meridian_bank_accounts SET balance = balance + ? WHERE account_number = ?",
            values = { amount, toAcc }
        },
        {
            query = [[
                INSERT INTO meridian_bank_transactions 
                (transaction_reference, from_account, to_account, amount, category, description, performed_by)
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ]],
            values = { reference, fromAcc, toAcc, amount, category, description or "Wire Transfer", actorIdentifier or "SYSTEM" }
        }
    }

    local success, err = exports['meridian-core']:ExecuteTransaction(queries)
    if not success then
        exports['meridian-core']:LogError("BANKING_TRANSFER", "Failed to commit transfer", tostring(err))
        return false, "Failed to complete transaction safely."
    end

    exports['meridian-core']:LogAudit(actorIdentifier or "SYSTEM", "BANK_TRANSFER_SUCCESS", {
        reference = reference,
        from = fromAcc,
        to = toAcc,
        amount = amount,
        category = category
    })

    return true, reference
end

--[[
    Create an invoice issued to a citizen
--]]
function MeridianBanking.CreateInvoice(businessId, issuerCitizenId, targetCitizenId, amount, description)
    amount = math.floor(tonumber(amount) or 0)
    if amount <= 0 then
        return false, "Amount must be greater than zero."
    end

    local invRef = string.format("INV-%s-%d", os.date("%Y%m%d"), math.random(1000, 9999))

    local insertId = MySQL.insert.await([[
        INSERT INTO meridian_invoices (invoice_reference, business_id, issuer_citizenid, target_citizenid, amount, description)
        VALUES (?, ?, ?, ?, ?, ?)
    ]], { invRef, businessId, issuerCitizenId, targetCitizenId, amount, description })

    if insertId then
        exports['meridian-core']:LogAudit(issuerCitizenId, "INVOICE_ISSUED", {
            reference = invRef,
            business = businessId,
            target = targetCitizenId,
            amount = amount
        })
        return true, invRef
    end

    return false, "Failed to create invoice."
end

--[[
    Pay an existing invoice
--]]
function MeridianBanking.PayInvoice(invoiceReference, payerCitizenId, payerAccountNumber)
    local invoice = MySQL.single.await([[
        SELECT i.*, b.account_number AS business_account
        FROM meridian_invoices i
        JOIN meridian_businesses b ON i.business_id = b.business_id
        WHERE i.invoice_reference = ? AND i.status = 'pending'
        LIMIT 1
    ]], { invoiceReference })

    if not invoice then
        return false, "Invoice not found or already settled."
    end

    if invoice.target_citizenid ~= payerCitizenId then
        return false, "You are not authorized to settle this invoice."
    end

    local transferSuccess, res = MeridianBanking.TransferFunds(
        payerAccountNumber,
        invoice.business_account,
        invoice.amount,
        "invoice",
        string.format("Payment for %s: %s", invoice.invoice_reference, invoice.description),
        payerCitizenId
    )

    if not transferSuccess then
        return false, res
    end

    MySQL.update.await([[
        UPDATE meridian_invoices SET status = 'paid', settled_at = NOW() WHERE invoice_reference = ?
    ]], { invoiceReference })

    exports['meridian-core']:LogAudit(payerCitizenId, "INVOICE_SETTLED", {
        reference = invoiceReference,
        amount = invoice.amount,
        business = invoice.business_id
    })

    return true, invoice.amount
end

-- Callbacks
lib.callback.register('meridian-banking:server:transfer', function(source, toAcc, amount, description)
    local cid = exports['meridian-core']:GetPlayerCitizenId(source)
    if not cid then return false, "Player not found." end

    local userAcc = MySQL.scalar.await([[
        SELECT account_number FROM meridian_bank_accounts WHERE owner_identifier = ? AND account_type = 'personal' LIMIT 1
    ]], { cid })

    if not userAcc then return false, "No bank account found." end

    return MeridianBanking.TransferFunds(userAcc, toAcc, amount, "transfer", description, cid)
end)

-- Exports
exports('GetAccountBalance', MeridianBanking.GetAccountBalance)
exports('CreateAccount', MeridianBanking.CreateAccount)
exports('TransferFunds', MeridianBanking.TransferFunds)
exports('CreateInvoice', MeridianBanking.CreateInvoice)
exports('PayInvoice', MeridianBanking.PayInvoice)

--[[
    MERIDIAN ROLEPLAY — shared/types.lua
    Common constants, roles, and status enums.
--]]

Meridian = Meridian or {}
Meridian.Types = {}

-- Law Enforcement & Emergency Services
Meridian.Types.Agencies = {
    LSPD = "lspd",
    BCSO = "bcso",
    MSP = "msp",
    SAFD = "safd",
    EMS = "ems",
    DOJ = "doj"
}

-- Case Statuses
Meridian.Types.CaseStatus = {
    OPEN = "open",
    PENDING_WARRANT = "pending_warrant",
    UNDER_REVIEW = "under_review",
    CLOSED = "closed",
    DISMISSED = "dismissed"
}

-- Transaction Categories
Meridian.Types.TransactionCategory = {
    PAYROLL = "payroll",
    INVOICE = "invoice",
    TAX = "tax",
    PURCHASE = "purchase",
    TRANSFER = "transfer",
    FINE = "fine",
    CRIME_HEIST = "crime_heist",
    ADMIN = "admin"
}

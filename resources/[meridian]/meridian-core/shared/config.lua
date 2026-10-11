--[[
    MERIDIAN ROLEPLAY — shared/config.lua
    Server-wide constants, currency formats, and global behavior flags.
--]]

Meridian = Meridian or {}
Meridian.Config = {}

-- State & Identity
Meridian.Config.ServerName = "Meridian Roleplay"
Meridian.Config.StateName = "The State of Meridian"
Meridian.Config.CapitalCity = "Los Santos"
Meridian.Config.Tagline = "Every Choice Shapes the State"

-- Localization: 'en' or 'id'
Meridian.Config.DefaultLocale = "en"

-- Economic Defaults (Provisional)
Meridian.Config.CurrencySymbol = "$"
Meridian.Config.TaxRate = 0.05 -- 5% baseline state sales tax

-- Logging Settings
Meridian.Config.LogLevel = "debug" -- 'debug' | 'info' | 'warn' | 'error'
Meridian.Config.DiscordWebhooks = {
    audit = "",
    security = "",
    economy = ""
}

-- Anti-Spam / Rate Limiting (Server-side)
Meridian.Config.RateLimits = {
    GeneralCallbackMs = 300,
    FinancialActionMs = 1000,
    InventoryTransferMs = 500
}

function Meridian.GetConfig()
    return Meridian.Config
end

exports('GetCoreConfig', Meridian.GetConfig)

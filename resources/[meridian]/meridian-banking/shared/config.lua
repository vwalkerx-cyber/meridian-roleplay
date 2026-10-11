--[[
    MERIDIAN ROLEPLAY — meridian-banking/shared/config.lua
--]]

BankingConfig = {}

BankingConfig.StateTreasuryAccount = "MRD-STATE-001"
BankingConfig.DefaultStartingBalance = 1500
BankingConfig.TransferFeePercentage = 0.01 -- 1% bank wire fee
BankingConfig.MinTransferAmount = 10
BankingConfig.MaxTransferAmount = 10000000 -- $10M hard single limit to prevent integer overflow

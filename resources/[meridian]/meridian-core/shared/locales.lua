--[[
    MERIDIAN ROLEPLAY — shared/locales.lua
    Bilingual localization matrix (English and Indonesian).
--]]

Meridian = Meridian or {}
Meridian.Locales = {}

Meridian.Locales['en'] = {
    -- Common
    ['common_error'] = 'An unexpected error occurred.',
    ['common_no_permission'] = 'You do not have permission to perform this action.',
    ['common_action_too_fast'] = 'Please wait before trying again.',
    ['common_insufficient_funds'] = 'Insufficient funds for this transaction.',
    ['common_invalid_input'] = 'Invalid parameters provided.',
    ['common_success'] = 'Operation completed successfully.',
    
    -- Emergency & Police
    ['police_badge_verified'] = 'Peace officer credentials verified: %s (%s)',
    ['police_evidence_logged'] = 'Evidence item #%s secured into chain of custody.',
    
    -- Business & Economy
    ['biz_payroll_processed'] = 'Payroll processed: %s received $%s.',
    ['biz_invoice_created'] = 'Invoice #%s issued for $%s.',
    ['biz_invoice_paid'] = 'Invoice #%s was settled successfully.',
    
    -- Organization
    ['org_action_unauthorized'] = 'You do not hold sufficient rank in this organization.'
}

Meridian.Locales['id'] = {
    -- Common
    ['common_error'] = 'Terjadi kesalahan sistem yang tidak terduga.',
    ['common_no_permission'] = 'Anda tidak memiliki izin untuk melakukan tindakan ini.',
    ['common_action_too_fast'] = 'Mohon tunggu sebentar sebelum mencoba lagi.',
    ['common_insufficient_funds'] = 'Saldo tidak mencukupi untuk transaksi ini.',
    ['common_invalid_input'] = 'Parameter yang dimasukkan tidak valid.',
    ['common_success'] = 'Operasi berhasil diselesaikan.',
    
    -- Emergency & Police
    ['police_badge_verified'] = 'Lencana petugas terverifikasi: %s (%s)',
    ['police_evidence_logged'] = 'Barang bukti #%s berhasil dicatat ke rantai bukti (chain of custody).',
    
    -- Business & Economy
    ['biz_payroll_processed'] = 'Gaji berhasil dibayarkan: %s menerima $%s.',
    ['biz_invoice_created'] = 'Tagihan #%s berhasil dibuat sebesar $%s.',
    ['biz_invoice_paid'] = 'Tagihan #%s telah berhasil dilunasi.',
    
    -- Organization
    ['org_action_unauthorized'] = 'Pangkat Anda tidak mencukupi dalam organisasi ini.'
}

function Meridian.Locale(key, ...)
    local lang = (Meridian.Config and Meridian.Config.DefaultLocale) or 'en'
    local dict = Meridian.Locales[lang] or Meridian.Locales['en']
    local str = dict[key] or Meridian.Locales['en'][key] or key
    if select('#', ...) > 0 then
        return string.format(str, ...)
    end
    return str
end

function Meridian.FormatCurrency(amount)
    local formatted = tostring(math.floor(tonumber(amount) or 0))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return (Meridian.Config.CurrencySymbol or "$") .. formatted
end

exports('GetLocale', Meridian.Locale)
exports('FormatCurrency', Meridian.FormatCurrency)

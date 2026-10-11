-- -------------------------------------------------------------
-- MERIDIAN ROLEPLAY — Migration 002
-- Interconnected Banking & Business Schemas
-- -------------------------------------------------------------

-- 1. Banking Accounts (Personal, Business, Government)
CREATE TABLE IF NOT EXISTS `meridian_bank_accounts` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `account_number` VARCHAR(32) NOT NULL,
    `account_name` VARCHAR(100) NOT NULL,
    `account_type` ENUM('personal', 'business', 'agency', 'state') NOT NULL DEFAULT 'personal',
    `owner_identifier` VARCHAR(64) DEFAULT NULL, -- citizenid or business slug
    `balance` BIGINT NOT NULL DEFAULT 0,
    `is_frozen` TINYINT(1) NOT NULL DEFAULT 0,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_account_number` (`account_number`),
    INDEX `idx_owner_identifier` (`owner_identifier`),
    INDEX `idx_account_type` (`account_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Double-Entry Transaction Ledger
CREATE TABLE IF NOT EXISTS `meridian_bank_transactions` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `transaction_reference` VARCHAR(64) NOT NULL,
    `from_account` VARCHAR(32) DEFAULT NULL,
    `to_account` VARCHAR(32) NOT NULL,
    `amount` BIGINT UNSIGNED NOT NULL,
    `category` VARCHAR(32) NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `performed_by` VARCHAR(64) NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_trans_reference` (`transaction_reference`),
    INDEX `idx_trans_from` (`from_account`),
    INDEX `idx_trans_to` (`to_account`),
    INDEX `idx_trans_category` (`category`),
    INDEX `idx_trans_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Business Registry
CREATE TABLE IF NOT EXISTS `meridian_businesses` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `business_id` VARCHAR(64) NOT NULL,
    `label` VARCHAR(100) NOT NULL,
    `owner_citizenid` VARCHAR(64) NOT NULL,
    `account_number` VARCHAR(32) NOT NULL,
    `tax_rate` DECIMAL(5, 2) NOT NULL DEFAULT 5.00,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_business_id` (`business_id`),
    UNIQUE KEY `uk_business_account` (`account_number`),
    INDEX `idx_business_owner` (`owner_citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Business Employees & Permissions
CREATE TABLE IF NOT EXISTS `meridian_business_employees` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `business_id` VARCHAR(64) NOT NULL,
    `citizenid` VARCHAR(64) NOT NULL,
    `role` ENUM('owner', 'manager', 'employee') NOT NULL DEFAULT 'employee',
    `salary` INT UNSIGNED NOT NULL DEFAULT 0,
    `can_invoice` TINYINT(1) NOT NULL DEFAULT 1,
    `can_withdraw` TINYINT(1) NOT NULL DEFAULT 0,
    `can_hire` TINYINT(1) NOT NULL DEFAULT 0,
    `hired_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_biz_employee` (`business_id`, `citizenid`),
    INDEX `idx_emp_citizenid` (`citizenid`),
    CONSTRAINT `fk_biz_emp_business` FOREIGN KEY (`business_id`) REFERENCES `meridian_businesses` (`business_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Invoicing & Billing
CREATE TABLE IF NOT EXISTS `meridian_invoices` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `invoice_reference` VARCHAR(64) NOT NULL,
    `business_id` VARCHAR(64) NOT NULL,
    `issuer_citizenid` VARCHAR(64) NOT NULL,
    `target_citizenid` VARCHAR(64) NOT NULL,
    `amount` BIGINT UNSIGNED NOT NULL,
    `description` VARCHAR(255) NOT NULL,
    `status` ENUM('pending', 'paid', 'cancelled') NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `settled_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_invoice_reference` (`invoice_reference`),
    INDEX `idx_inv_business` (`business_id`),
    INDEX `idx_inv_target` (`target_citizenid`),
    INDEX `idx_inv_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `meridian_schema_migrations` (`version`) VALUES ('002_banking_and_businesses');

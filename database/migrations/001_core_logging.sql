-- -------------------------------------------------------------
-- MERIDIAN ROLEPLAY — Migration 001
-- Base Audit & Security Logging Tables
-- -------------------------------------------------------------

CREATE TABLE IF NOT EXISTS `meridian_audit_logs` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `category` VARCHAR(32) NOT NULL,
    `message` TEXT NOT NULL,
    `metadata` JSON DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    INDEX `idx_meridian_audit_category` (`category`),
    INDEX `idx_meridian_audit_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `meridian_schema_migrations` (
    `version` VARCHAR(64) NOT NULL,
    `applied_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `meridian_schema_migrations` (`version`) VALUES ('001_core_logging');

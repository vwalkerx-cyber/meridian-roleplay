-- -------------------------------------------------------------
-- MERIDIAN ROLEPLAY — Migration 004
-- Judicial Cases, Legal Warrants, Charges & Territory Influence
-- -------------------------------------------------------------

-- 1. Judicial Case Files
CREATE TABLE IF NOT EXISTS `meridian_cases` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `case_number` VARCHAR(64) NOT NULL,            -- e.g. 'CASE-2026-0042'
    `title` VARCHAR(150) NOT NULL,
    `status` ENUM('open', 'under_investigation', 'pending_warrant', 'trial_scheduled', 'closed', 'dismissed') NOT NULL DEFAULT 'open',
    `lead_investigator_citizenid` VARCHAR(64) NOT NULL,
    `agency` VARCHAR(32) NOT NULL DEFAULT 'lspd',   -- 'lspd', 'bcso', 'msp', 'doj'
    `summary` TEXT NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `closed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_case_number` (`case_number`),
    INDEX `idx_case_investigator` (`lead_investigator_citizenid`),
    INDEX `idx_case_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Case Suspects & Persons of Interest
CREATE TABLE IF NOT EXISTS `meridian_case_suspects` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `case_id` VARCHAR(64) NOT NULL,
    `citizenid` VARCHAR(64) NOT NULL,
    `involvement_level` ENUM('person_of_interest', 'suspect', 'indicted', 'cleared') NOT NULL DEFAULT 'person_of_interest',
    `notes` TEXT DEFAULT NULL,
    `added_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_case_suspect` (`case_id`, `citizenid`),
    INDEX `idx_suspect_citizenid` (`citizenid`),
    CONSTRAINT `fk_case_suspect_case` FOREIGN KEY (`case_id`) REFERENCES `meridian_cases` (`case_number`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Arrest & Search Warrants
CREATE TABLE IF NOT EXISTS `meridian_warrants` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `warrant_id` VARCHAR(64) NOT NULL,             -- e.g. 'WAR-2026-0089'
    `case_id` VARCHAR(64) DEFAULT NULL,
    `target_citizenid` VARCHAR(64) NOT NULL,
    `target_name` VARCHAR(100) NOT NULL,
    `warrant_type` ENUM('arrest', 'search') NOT NULL DEFAULT 'arrest',
    `requested_by` VARCHAR(64) NOT NULL,           -- officer citizenid
    `approved_by_judge` VARCHAR(64) DEFAULT NULL,  -- judge/DOJ citizenid
    `reason` TEXT NOT NULL,
    `status` ENUM('pending', 'approved', 'served', 'expired', 'denied') NOT NULL DEFAULT 'pending',
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `expires_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `served_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_warrant_id` (`warrant_id`),
    INDEX `idx_warrant_target` (`target_citizenid`),
    INDEX `idx_warrant_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Penal Code & Criminal Charges
CREATE TABLE IF NOT EXISTS `meridian_penal_charges` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `charge_code` VARCHAR(32) NOT NULL,            -- e.g. 'PC-187', 'PC-211'
    `title` VARCHAR(100) NOT NULL,
    `category` ENUM('infraction', 'misdemeanor', 'felony') NOT NULL,
    `fine_amount` INT UNSIGNED NOT NULL DEFAULT 0,
    `jail_time_seconds` INT UNSIGNED NOT NULL DEFAULT 0,
    `points` INT UNSIGNED NOT NULL DEFAULT 0,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_charge_code` (`charge_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Territorial Influence Points
CREATE TABLE IF NOT EXISTS `meridian_territory_influence` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `zone_name` VARCHAR(64) NOT NULL,              -- e.g. 'davis', 'rancho', 'chumash'
    `dominant_org_id` VARCHAR(64) DEFAULT NULL,
    `influence_score` INT UNSIGNED NOT NULL DEFAULT 0,
    `last_contested_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_zone_name` (`zone_name`),
    INDEX `idx_zone_org` (`dominant_org_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Seed Baseline Penal Code Entries
INSERT IGNORE INTO `meridian_penal_charges` (`charge_code`, `title`, `category`, `fine_amount`, `jail_time_seconds`, `points`) VALUES
('PC-101', 'Speeding / Reckless Driving', 'infraction', 350, 0, 2),
('PC-201', 'Failure to Comply with a Peace Officer', 'misdemeanor', 750, 300, 3),
('PC-211', 'Commercial Armed Robbery', 'felony', 4500, 1200, 10),
('PC-245', 'Assault with a Deadly Weapon', 'felony', 6000, 1800, 15),
('PC-459', 'Burglary & Breaking and Entering', 'felony', 3000, 900, 8);

-- Seed Baseline Territories
INSERT IGNORE INTO `meridian_territory_influence` (`zone_name`, `dominant_org_id`, `influence_score`) VALUES
('davis', NULL, 0),
('rancho', NULL, 0),
('chamberlain', NULL, 0),
('sandy_shores', NULL, 0),
('paleto_bay', NULL, 0);

INSERT IGNORE INTO `meridian_schema_migrations` (`version`) VALUES ('004_justice_warrants_territories');

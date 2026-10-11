-- -------------------------------------------------------------
-- MERIDIAN ROLEPLAY — Migration 003
-- Emergency Services, Dispatch, Organizations & Evidence
-- -------------------------------------------------------------

-- 1. Emergency Dispatch Calls
CREATE TABLE IF NOT EXISTS `meridian_dispatch_calls` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `call_code` VARCHAR(32) NOT NULL,          -- e.g. '10-90', '10-31', '10-71'
    `title` VARCHAR(100) NOT NULL,
    `message` TEXT NOT NULL,
    `agency` VARCHAR(32) NOT NULL DEFAULT 'all', -- 'lspd', 'bcso', 'msp', 'safd', 'ems', 'all'
    `priority` TINYINT UNSIGNED NOT NULL DEFAULT 1, -- 1: Routine, 2: Priority, 3: Emergency
    `coords_x` FLOAT NOT NULL,
    `coords_y` FLOAT NOT NULL,
    `coords_z` FLOAT NOT NULL,
    `street_name` VARCHAR(100) DEFAULT NULL,
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `cleared_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_call_active` (`is_active`),
    INDEX `idx_call_agency` (`agency`),
    INDEX `idx_call_priority` (`priority`),
    INDEX `idx_call_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Physical & Forensic Evidence (Chain of Custody)
CREATE TABLE IF NOT EXISTS `meridian_evidence` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `evidence_id` VARCHAR(64) NOT NULL,
    `evidence_type` ENUM('casing', 'blood', 'fingerprint', 'weapon', 'narcotics', 'document') NOT NULL,
    `identifier` VARCHAR(100) NOT NULL,         -- weapon serial, caliber type, or DNA sequence hash
    `description` TEXT NOT NULL,
    `case_id` VARCHAR(64) DEFAULT NULL,
    `collected_by` VARCHAR(64) NOT NULL,        -- officer citizenid
    `current_location` VARCHAR(100) NOT NULL DEFAULT 'LSPD Evidence Locker A',
    `is_tampered` TINYINT(1) NOT NULL DEFAULT 0,
    `coords_x` FLOAT DEFAULT NULL,
    `coords_y` FLOAT DEFAULT NULL,
    `coords_z` FLOAT DEFAULT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_evidence_id` (`evidence_id`),
    INDEX `idx_evid_case` (`case_id`),
    INDEX `idx_evid_type` (`evidence_type`),
    INDEX `idx_evid_collected` (`collected_by`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Criminal Organizations & Syndicates
CREATE TABLE IF NOT EXISTS `meridian_organizations` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `org_id` VARCHAR(64) NOT NULL,
    `name` VARCHAR(100) NOT NULL,
    `tagline` VARCHAR(255) DEFAULT NULL,
    `leader_citizenid` VARCHAR(64) NOT NULL,
    `influence_score` INT NOT NULL DEFAULT 100,
    `status` ENUM('applicant', 'probationary', 'recognized', 'disbanded') NOT NULL DEFAULT 'applicant',
    `is_active` TINYINT(1) NOT NULL DEFAULT 1,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_org_id` (`org_id`),
    INDEX `idx_org_leader` (`leader_citizenid`),
    INDEX `idx_org_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Organization Members & Ranks
CREATE TABLE IF NOT EXISTS `meridian_organization_members` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `org_id` VARCHAR(64) NOT NULL,
    `citizenid` VARCHAR(64) NOT NULL,
    `rank` INT UNSIGNED NOT NULL DEFAULT 1,     -- 1: Associate/Prospect, 2: Soldier, 3: Enforcer, 4: Underboss, 5: Boss
    `role_title` VARCHAR(50) NOT NULL DEFAULT 'Associate',
    `can_manage` TINYINT(1) NOT NULL DEFAULT 0,
    `can_armory` TINYINT(1) NOT NULL DEFAULT 0,
    `joined_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`id`),
    UNIQUE KEY `uk_org_member` (`org_id`, `citizenid`),
    INDEX `idx_member_citizenid` (`citizenid`),
    CONSTRAINT `fk_org_member` FOREIGN KEY (`org_id`) REFERENCES `meridian_organizations` (`org_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Criminal Activity Logs & Cooldowns
CREATE TABLE IF NOT EXISTS `meridian_criminal_activities` (
    `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
    `activity_type` VARCHAR(64) NOT NULL,       -- e.g. 'store_robbery', 'freight_hijack'
    `target_id` VARCHAR(64) NOT NULL,           -- e.g. 'store_247_innocence'
    `initiator_citizenid` VARCHAR(64) NOT NULL,
    `org_id` VARCHAR(64) DEFAULT NULL,
    `status` ENUM('in_progress', 'completed', 'failed', 'cancelled') NOT NULL DEFAULT 'in_progress',
    `payout` INT UNSIGNED NOT NULL DEFAULT 0,
    `cooldown_until` TIMESTAMP NOT NULL,
    `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    `completed_at` TIMESTAMP NULL DEFAULT NULL,
    PRIMARY KEY (`id`),
    INDEX `idx_act_type_target` (`activity_type`, `target_id`),
    INDEX `idx_act_status` (`status`),
    INDEX `idx_act_cooldown` (`cooldown_until`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `meridian_schema_migrations` (`version`) VALUES ('003_emergency_evidence_organizations');

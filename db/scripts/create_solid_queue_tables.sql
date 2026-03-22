-- Create SolidQueue tables for mrdbid_production_queue database

CREATE TABLE IF NOT EXISTS `solid_queue_jobs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `queue_name` varchar(255) NOT NULL,
  `class_name` varchar(255) NOT NULL,
  `arguments` text,
  `priority` int NOT NULL DEFAULT '0',
  `active_job_id` varchar(255) DEFAULT NULL,
  `scheduled_at` datetime(6) DEFAULT NULL,
  `finished_at` datetime(6) DEFAULT NULL,
  `concurrency_key` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_solid_queue_jobs_on_active_job_id` (`active_job_id`),
  KEY `index_solid_queue_jobs_on_class_name` (`class_name`),
  KEY `index_solid_queue_jobs_on_finished_at` (`finished_at`),
  KEY `index_solid_queue_jobs_for_filtering` (`queue_name`,`finished_at`),
  KEY `index_solid_queue_jobs_for_alerting` (`scheduled_at`,`finished_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_blocked_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `queue_name` varchar(255) NOT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `concurrency_key` varchar(255) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_blocked_executions_on_job_id` (`job_id`),
  KEY `index_solid_queue_blocked_executions_for_release` (`concurrency_key`,`priority`,`job_id`),
  KEY `index_solid_queue_blocked_executions_for_maintenance` (`expires_at`,`concurrency_key`),
  CONSTRAINT `fk_rails_blocked_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_claimed_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `process_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_claimed_executions_on_job_id` (`job_id`),
  KEY `index_solid_queue_claimed_executions_on_process_id_and_job_id` (`process_id`,`job_id`),
  CONSTRAINT `fk_rails_claimed_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_failed_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `error` text,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_failed_executions_on_job_id` (`job_id`),
  CONSTRAINT `fk_rails_failed_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_pauses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `queue_name` varchar(255) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_pauses_on_queue_name` (`queue_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_processes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `kind` varchar(255) NOT NULL,
  `last_heartbeat_at` datetime(6) NOT NULL,
  `supervisor_id` bigint DEFAULT NULL,
  `pid` int NOT NULL,
  `hostname` varchar(255) DEFAULT NULL,
  `metadata` text,
  `created_at` datetime(6) NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_processes_on_name_and_supervisor_id` (`name`,`supervisor_id`),
  KEY `index_solid_queue_processes_on_last_heartbeat_at` (`last_heartbeat_at`),
  KEY `index_solid_queue_processes_on_supervisor_id` (`supervisor_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_ready_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `queue_name` varchar(255) NOT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_ready_executions_on_job_id` (`job_id`),
  KEY `index_solid_queue_poll_all` (`priority`,`job_id`),
  KEY `index_solid_queue_poll_by_queue` (`queue_name`,`priority`,`job_id`),
  CONSTRAINT `fk_rails_ready_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_recurring_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `task_key` varchar(255) NOT NULL,
  `run_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_recurring_executions_on_job_id` (`job_id`),
  UNIQUE KEY `index_solid_queue_recurring_executions_on_task_key_and_run_at` (`task_key`,`run_at`),
  CONSTRAINT `fk_rails_recurring_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_recurring_tasks` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `schedule` varchar(255) NOT NULL,
  `command` varchar(2048) DEFAULT NULL,
  `class_name` varchar(255) DEFAULT NULL,
  `arguments` text,
  `queue_name` varchar(255) DEFAULT NULL,
  `priority` int DEFAULT '0',
  `static` tinyint(1) NOT NULL DEFAULT '1',
  `description` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_recurring_tasks_on_key` (`key`),
  KEY `index_solid_queue_recurring_tasks_on_static` (`static`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_scheduled_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `queue_name` varchar(255) NOT NULL,
  `priority` int NOT NULL DEFAULT '0',
  `scheduled_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_scheduled_executions_on_job_id` (`job_id`),
  KEY `index_solid_queue_dispatch_all` (`scheduled_at`,`priority`,`job_id`),
  CONSTRAINT `fk_rails_scheduled_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

CREATE TABLE IF NOT EXISTS `solid_queue_semaphores` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` int NOT NULL DEFAULT '1',
  `expires_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_semaphores_on_key` (`key`),
  KEY `index_solid_queue_semaphores_on_expires_at` (`expires_at`),
  KEY `index_solid_queue_semaphores_on_key_and_value` (`key`,`value`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

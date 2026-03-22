-- Create SolidCache table for mrdbid_production_cache database
-- Run this on the mrdbid_production_cache database

CREATE TABLE IF NOT EXISTS `solid_cache_entries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varbinary(1024) NOT NULL,
  `value` longblob NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `key_hash` bigint NOT NULL,
  `byte_size` int NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_cache_entries_on_key_hash` (`key_hash`),
  KEY `index_solid_cache_entries_on_byte_size` (`byte_size`),
  KEY `index_solid_cache_entries_on_key_hash_and_byte_size` (`key_hash`,`byte_size`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

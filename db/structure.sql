
/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
DROP TABLE IF EXISTS `active_storage_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_attachments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `record_type` varchar(255) NOT NULL,
  `record_id` bigint NOT NULL,
  `blob_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_attachments_uniqueness` (`record_type`,`record_id`,`name`,`blob_id`),
  KEY `index_active_storage_attachments_on_blob_id` (`blob_id`),
  CONSTRAINT `fk_rails_c3b3935057` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2680 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_blobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_blobs` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `filename` varchar(255) NOT NULL,
  `content_type` varchar(255) DEFAULT NULL,
  `metadata` text,
  `service_name` varchar(255) NOT NULL,
  `byte_size` bigint NOT NULL,
  `checksum` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_blobs_on_key` (`key`)
) ENGINE=InnoDB AUTO_INCREMENT=2680 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `active_storage_variant_records`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `active_storage_variant_records` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `blob_id` bigint NOT NULL,
  `variation_digest` varchar(255) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_active_storage_variant_records_uniqueness` (`blob_id`,`variation_digest`),
  CONSTRAINT `fk_rails_993965df05` FOREIGN KEY (`blob_id`) REFERENCES `active_storage_blobs` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2350 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `admin_todos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `admin_todos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `description` text,
  `done` tinyint(1) NOT NULL DEFAULT '0',
  `user_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_admin_todos_on_user_id` (`user_id`),
  KEY `index_admin_todos_on_done` (`done`),
  KEY `index_admin_todos_on_created_at` (`created_at`),
  CONSTRAINT `fk_rails_796e8b80d9` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `all_group_mushrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `all_group_mushrooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `all_group_id` bigint DEFAULT NULL,
  `mushroom_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_all_group_mushrooms_on_all_group_id` (`all_group_id`),
  KEY `index_all_group_mushrooms_on_mushroom_id` (`mushroom_id`),
  CONSTRAINT `fk_rails_bf88171658` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`),
  CONSTRAINT `fk_rails_f845056653` FOREIGN KEY (`all_group_id`) REFERENCES `all_groups` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `all_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `all_groups` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_all_groups_on_user_id_and_lower_name` (`user_id`,`name`),
  KEY `index_all_groups_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_daa4ade1c1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=16 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `ar_internal_metadata`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ar_internal_metadata` (
  `key` varchar(255) NOT NULL,
  `value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `articles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `articles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `summary` text,
  `body` text NOT NULL,
  `published_at` datetime(6) DEFAULT NULL,
  `published` tinyint(1) NOT NULL DEFAULT '1',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint DEFAULT NULL,
  `subject_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_articles_on_slug` (`slug`),
  KEY `index_articles_on_published_at` (`published_at`),
  KEY `index_articles_on_user_id` (`user_id`),
  KEY `index_articles_on_published` (`published`),
  KEY `index_articles_on_subject_id` (`subject_id`),
  CONSTRAINT `fk_rails_25f84e0977` FOREIGN KEY (`subject_id`) REFERENCES `subjects` (`id`),
  CONSTRAINT `fk_rails_3d31dad1cc` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `camera_makes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `camera_makes` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `source` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `camera_models`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `camera_models` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `source` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cameras`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cameras` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `camera_make_id` bigint DEFAULT NULL,
  `camera_model_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cameras_on_camera_make_id` (`camera_make_id`),
  KEY `index_cameras_on_camera_model_id` (`camera_model_id`),
  CONSTRAINT `fk_rails_237c9aa076` FOREIGN KEY (`camera_make_id`) REFERENCES `camera_makes` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_7eb7504f0f` FOREIGN KEY (`camera_model_id`) REFERENCES `camera_models` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `cluster_mushrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cluster_mushrooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `cluster_id` bigint DEFAULT NULL,
  `mushroom_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_cluster_mushrooms_on_cluster_id` (`cluster_id`),
  KEY `index_cluster_mushrooms_on_mushroom_id` (`mushroom_id`),
  CONSTRAINT `fk_rails_96b70e2520` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`),
  CONSTRAINT `fk_rails_ff0c33bdff` FOREIGN KEY (`cluster_id`) REFERENCES `clusters` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `clusters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clusters` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_clusters_on_user_id_and_lower_name` (`user_id`,`name`),
  KEY `index_clusters_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_ac3a663d79` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `colors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `colors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `latin_name` varchar(255) NOT NULL,
  `common_name` varchar(255) DEFAULT NULL,
  `color_group` int DEFAULT NULL,
  `hex` varchar(255) NOT NULL,
  `sequence` int DEFAULT NULL,
  `r_val` int NOT NULL,
  `g_val` int NOT NULL,
  `b_val` int NOT NULL,
  `closest_websafe_color` varchar(255) DEFAULT NULL,
  `cwc_r` varchar(255) DEFAULT NULL,
  `cwc_g` varchar(255) DEFAULT NULL,
  `cwc_b` varchar(255) DEFAULT NULL,
  `image_file_address` varchar(255) NOT NULL DEFAULT 'default_image_path.jpg',
  `metadata` json DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `color_family` varchar(255) DEFAULT NULL,
  `color_variant` varchar(255) DEFAULT NULL,
  `display_order` int DEFAULT NULL,
  `is_simplified` tinyint(1) DEFAULT '0',
  `simplified_color_id` int DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_colors_on_latin_name` (`latin_name`),
  UNIQUE KEY `index_colors_on_hex` (`hex`),
  KEY `index_colors_on_color_family` (`color_family`),
  KEY `index_colors_on_is_simplified` (`is_simplified`),
  KEY `index_colors_on_display_order` (`display_order`),
  KEY `index_colors_on_simplified_color_id` (`simplified_color_id`)
) ENGINE=InnoDB AUTO_INCREMENT=128 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `commentable_type` varchar(255) NOT NULL,
  `commentable_id` bigint NOT NULL,
  `user_id` bigint NOT NULL,
  `body` text NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_comments_on_commentable` (`commentable_type`,`commentable_id`),
  KEY `index_comments_on_user_id` (`user_id`),
  KEY `index_comments_on_commentable_and_created_at` (`commentable_type`,`commentable_id`,`created_at`),
  CONSTRAINT `fk_rails_03de2dc08c` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `core_character_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `core_character_sequences` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `fungus_type_id` bigint NOT NULL,
  `mr_character_id` bigint NOT NULL,
  `sequence` int NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_core_sequences_on_fungus_and_character` (`fungus_type_id`,`mr_character_id`),
  KEY `index_core_character_sequences_on_fungus_type_id` (`fungus_type_id`),
  KEY `index_core_character_sequences_on_mr_character_id` (`mr_character_id`),
  KEY `index_core_sequences_on_fungus_and_sequence` (`fungus_type_id`,`sequence`),
  CONSTRAINT `fk_rails_938c368c40` FOREIGN KEY (`mr_character_id`) REFERENCES `mr_characters` (`id`),
  CONSTRAINT `fk_rails_c56fce473c` FOREIGN KEY (`fungus_type_id`) REFERENCES `fungus_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `countries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `countries` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `country_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_countries_on_country_code` (`country_code`)
) ENGINE=InnoDB AUTO_INCREMENT=980190987 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `display_options`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `display_options` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1011827592 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `dna_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `dna_sequences` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mushroom_id` bigint DEFAULT NULL,
  `notes` text,
  `dna_barcode_its` text,
  `genbank_number_url` varchar(255) DEFAULT NULL,
  `genbank_accession_number` varchar(255) DEFAULT NULL,
  `herbarium_catalog_number` varchar(255) DEFAULT NULL,
  `mycomap_blast_results` varchar(255) DEFAULT NULL,
  `provisional_species_name` varchar(255) DEFAULT NULL,
  `sequencing_technology` varchar(255) DEFAULT NULL,
  `trace_files_raw_dna_data` varchar(255) DEFAULT NULL,
  `voucher_number` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_dna_sequences_on_mushroom_id` (`mushroom_id`),
  CONSTRAINT `fk_rails_54c17fadd6` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `fungus_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fungus_types` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980190977 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `genera`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `genera` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mblist_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_genera_on_name` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=980191037 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `genus_mushrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `genus_mushrooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `genus_id` bigint NOT NULL,
  `mushroom_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_genus_mushrooms_on_mushroom_id_and_genus_id` (`mushroom_id`,`genus_id`),
  KEY `index_genus_mushrooms_on_genus_id` (`genus_id`),
  KEY `index_genus_mushrooms_on_mushroom_id` (`mushroom_id`),
  CONSTRAINT `fk_rails_8d2e9914c5` FOREIGN KEY (`genus_id`) REFERENCES `genera` (`id`),
  CONSTRAINT `fk_rails_ff6ffa05e8` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191011 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `image_mushrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `image_mushrooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mushroom_id` bigint DEFAULT NULL,
  `part_id` bigint DEFAULT NULL,
  `image_name` varchar(255) DEFAULT NULL,
  `image_width` int DEFAULT NULL,
  `image_height` int DEFAULT NULL,
  `exif_lens` varchar(255) DEFAULT NULL,
  `exposure` varchar(255) DEFAULT NULL,
  `aperture` varchar(255) DEFAULT NULL,
  `iso` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `exif_make` varchar(255) DEFAULT NULL,
  `exif_model` varchar(255) DEFAULT NULL,
  `comments` text,
  `lens_id` bigint DEFAULT NULL,
  `camera_make_id` bigint DEFAULT NULL,
  `camera_model_id` bigint DEFAULT NULL,
  `date_taken` datetime(6) DEFAULT NULL,
  `latitude` decimal(10,7) DEFAULT NULL,
  `longitude` decimal(10,7) DEFAULT NULL,
  `image_storage_key` varchar(255) DEFAULT NULL,
  `image_public_url` varchar(255) DEFAULT NULL,
  `image_content_type` varchar(255) DEFAULT NULL,
  `image_byte_size` bigint DEFAULT NULL,
  `dominant_hex` varchar(255) DEFAULT NULL,
  `dominant_hue` int DEFAULT NULL,
  `color_bucket` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_image_mushrooms_on_mushroom_id` (`mushroom_id`),
  KEY `index_image_mushrooms_on_part_id` (`part_id`),
  KEY `index_image_mushrooms_on_lens_id` (`lens_id`),
  KEY `index_image_mushrooms_on_camera_make_id` (`camera_make_id`),
  KEY `index_image_mushrooms_on_camera_model_id` (`camera_model_id`),
  KEY `index_image_mushrooms_on_dominant_hue` (`dominant_hue`),
  CONSTRAINT `fk_rails_6d2bc30fcf` FOREIGN KEY (`camera_model_id`) REFERENCES `camera_models` (`id`),
  CONSTRAINT `fk_rails_974ee9e8a8` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`),
  CONSTRAINT `fk_rails_a39371cd65` FOREIGN KEY (`lens_id`) REFERENCES `lenses` (`id`),
  CONSTRAINT `fk_rails_acebcc46f8` FOREIGN KEY (`part_id`) REFERENCES `parts` (`id`),
  CONSTRAINT `fk_rails_dd82651639` FOREIGN KEY (`camera_make_id`) REFERENCES `camera_makes` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=348 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `inaturalist_observation_fields`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `inaturalist_observation_fields` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `inaturalist_id` int NOT NULL,
  `name` varchar(255) NOT NULL,
  `datatype` varchar(255) DEFAULT NULL,
  `user_id` int DEFAULT NULL,
  `description` text,
  `allowed_values` text,
  `values_count` int DEFAULT NULL,
  `users_count` int DEFAULT NULL,
  `uuid` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_inaturalist_observation_fields_on_inaturalist_id` (`inaturalist_id`),
  UNIQUE KEY `index_inaturalist_observation_fields_on_uuid` (`uuid`),
  KEY `index_inaturalist_observation_fields_on_name` (`name`),
  KEY `index_inaturalist_observation_fields_on_created_at` (`created_at`)
) ENGINE=InnoDB AUTO_INCREMENT=19521 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `invitation_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `invitation_tokens` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `token` varchar(255) NOT NULL,
  `used_at` datetime(6) DEFAULT NULL,
  `admin_expires_at` datetime(6) NOT NULL,
  `created_by_user_id` int NOT NULL,
  `invited_user_id` int DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_invitation_tokens_on_token` (`token`),
  KEY `index_invitation_tokens_on_created_by_user_id` (`created_by_user_id`),
  KEY `index_invitation_tokens_on_email` (`email`),
  KEY `index_invitation_tokens_on_invited_user_id` (`invited_user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `lenses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lenses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `make` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=54 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `lookup_items`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lookup_items` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mr_character_id` bigint NOT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `source_data_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_lookup_items_on_mr_character_id` (`mr_character_id`),
  KEY `index_lookup_items_on_source_data_id` (`source_data_id`),
  CONSTRAINT `fk_rails_7986eea0da` FOREIGN KEY (`mr_character_id`) REFERENCES `mr_characters` (`id`),
  CONSTRAINT `fk_rails_d80ecc7a8c` FOREIGN KEY (`source_data_id`) REFERENCES `source_data` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1533 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mb_lists`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mb_lists` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mblist_id` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `taxon_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `authors` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `rank_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `year_of_effective_publication` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `name_status` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `mycobank_number` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `hyperlink` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `classification` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `current_name` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  `synonymy` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_as_cs,
  PRIMARY KEY (`id`),
  KEY `index_mblists_on_taxon_name_and_rank_name` (`taxon_name`(255),`rank_name`(255)),
  KEY `index_mblists_on_taxon_name` (`taxon_name`(255)),
  KEY `index_mblists_on_rank_name` (`rank_name`(255)),
  KEY `index_mblists_on_name_status` (`name_status`(255))
) ENGINE=InnoDB AUTO_INCREMENT=980191295 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_as_cs;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mr_character_mushroom_colors`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mr_character_mushroom_colors` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mr_character_mushroom_id` bigint NOT NULL,
  `color_id` bigint NOT NULL,
  `display_order` int NOT NULL DEFAULT '1' COMMENT '1=primary, 2=secondary, etc.',
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mcm_colors_unique` (`mr_character_mushroom_id`,`color_id`),
  KEY `index_mcm_colors_on_mcm_id` (`mr_character_mushroom_id`),
  KEY `index_mr_character_mushroom_colors_on_color_id` (`color_id`),
  KEY `index_mcm_colors_on_color` (`color_id`,`mr_character_mushroom_id`),
  CONSTRAINT `fk_rails_cf8c40bad0` FOREIGN KEY (`mr_character_mushroom_id`) REFERENCES `mr_character_mushrooms` (`id`),
  CONSTRAINT `fk_rails_e89ab97506` FOREIGN KEY (`color_id`) REFERENCES `colors` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=100 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mr_character_mushrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mr_character_mushrooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mr_character_id` bigint DEFAULT NULL,
  `mushroom_id` bigint DEFAULT NULL,
  `character_value` varchar(255) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mr_character_mushrooms_on_mr_character_id` (`mr_character_id`),
  KEY `index_mr_character_mushrooms_on_mushroom_id` (`mushroom_id`),
  CONSTRAINT `fk_rails_976623cbea` FOREIGN KEY (`mr_character_id`) REFERENCES `mr_characters` (`id`),
  CONSTRAINT `fk_rails_ba5a019ccc` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1032208699 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mr_characters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mr_characters` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Human-readable description of the character',
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Internal notes/comments for the character (text field)',
  `part_id` bigint DEFAULT NULL,
  `observation_method_id` bigint DEFAULT NULL,
  `display_option_id` bigint DEFAULT NULL,
  `source_data_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `fungus_type_id` bigint DEFAULT NULL,
  `properties` json DEFAULT NULL,
  `needs_review` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  KEY `index_mr_characters_on_part_id` (`part_id`),
  KEY `index_mr_characters_on_observation_method_id` (`observation_method_id`),
  KEY `index_mr_characters_on_display_option_id` (`display_option_id`),
  KEY `index_mr_characters_on_source_data_id` (`source_data_id`),
  KEY `index_mr_characters_on_fungus_type_id` (`fungus_type_id`),
  CONSTRAINT `fk_rails_4452ee2843` FOREIGN KEY (`display_option_id`) REFERENCES `display_options` (`id`),
  CONSTRAINT `fk_rails_97936aa437` FOREIGN KEY (`part_id`) REFERENCES `parts` (`id`),
  CONSTRAINT `fk_rails_bbdf126be9` FOREIGN KEY (`fungus_type_id`) REFERENCES `fungus_types` (`id`),
  CONSTRAINT `fk_rails_f1528c1890` FOREIGN KEY (`observation_method_id`) REFERENCES `observation_methods` (`id`),
  CONSTRAINT `fk_rails_f919b11cf9` FOREIGN KEY (`source_data_id`) REFERENCES `source_data` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980190989 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mushroom_comparisons`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mushroom_comparisons` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mushroom_id` bigint NOT NULL,
  `compared_mushroom_id` bigint NOT NULL,
  `similarity_score` int NOT NULL DEFAULT '0' COMMENT 'Percentage similarity 0-100',
  `matching_characters` int NOT NULL DEFAULT '0' COMMENT 'Count of matching character values',
  `total_characters` int NOT NULL DEFAULT '0' COMMENT 'Total unique characters compared',
  `status` varchar(255) NOT NULL DEFAULT 'pending' COMMENT 'pending, completed, failed',
  `completed_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_comparisons_on_mushroom_pair` (`mushroom_id`,`compared_mushroom_id`),
  KEY `index_mushroom_comparisons_on_mushroom_id` (`mushroom_id`),
  KEY `index_mushroom_comparisons_on_compared_mushroom_id` (`compared_mushroom_id`),
  KEY `index_comparisons_on_mushroom_and_score` (`mushroom_id`,`similarity_score` DESC),
  KEY `index_comparisons_on_compared_mushroom` (`compared_mushroom_id`),
  KEY `index_comparisons_on_status` (`status`),
  CONSTRAINT `fk_rails_2067a26337` FOREIGN KEY (`compared_mushroom_id`) REFERENCES `mushrooms` (`id`),
  CONSTRAINT `fk_rails_4731c6d6bb` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=577629832 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mushroom_plants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mushroom_plants` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mushroom_id` bigint DEFAULT NULL,
  `plant_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mushroom_plants_on_mushroom_id_and_plant_id` (`mushroom_id`,`plant_id`),
  KEY `index_mushroom_plants_on_mushroom_id` (`mushroom_id`),
  KEY `index_mushroom_plants_on_plant_id` (`plant_id`),
  CONSTRAINT `fk_rails_1124497b59` FOREIGN KEY (`plant_id`) REFERENCES `plants` (`id`),
  CONSTRAINT `fk_rails_bf9b461fbf` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191023 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mushroom_projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mushroom_projects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mushroom_id` bigint DEFAULT NULL,
  `project_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_mushroom_projects_on_mushroom_id` (`mushroom_id`),
  KEY `index_mushroom_projects_on_project_id` (`project_id`),
  CONSTRAINT `fk_rails_41497fb7fc` FOREIGN KEY (`project_id`) REFERENCES `projects` (`id`),
  CONSTRAINT `fk_rails_8f62572610` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191029 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mushroom_species`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mushroom_species` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `species_id` bigint NOT NULL,
  `mushroom_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `is_primary` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mushroom_species_on_mushroom_id_and_species_id` (`mushroom_id`,`species_id`),
  KEY `index_mushroom_species_on_species_id` (`species_id`),
  KEY `index_mushroom_species_on_mushroom_id` (`mushroom_id`),
  CONSTRAINT `fk_rails_8833fee8ab` FOREIGN KEY (`species_id`) REFERENCES `species` (`id`),
  CONSTRAINT `fk_rails_c97af38f94` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191029 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mushroom_trees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mushroom_trees` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mushroom_id` bigint DEFAULT NULL,
  `tree_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mushroom_trees_on_mushroom_id_and_tree_id` (`mushroom_id`,`tree_id`),
  KEY `index_mushroom_trees_on_mushroom_id` (`mushroom_id`),
  KEY `index_mushroom_trees_on_tree_id` (`tree_id`),
  CONSTRAINT `fk_rails_4aa8d80201` FOREIGN KEY (`mushroom_id`) REFERENCES `mushrooms` (`id`),
  CONSTRAINT `fk_rails_995b7eb943` FOREIGN KEY (`tree_id`) REFERENCES `trees` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191019 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `mushrooms`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mushrooms` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` text,
  `comments` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci COMMENT 'Internal notes/comments for the mushroom (text field)',
  `user_id` bigint DEFAULT NULL,
  `country_id` bigint DEFAULT NULL,
  `state_id` bigint DEFAULT NULL,
  `fungus_type_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `trees_count` int NOT NULL DEFAULT '0',
  `plants_count` int NOT NULL DEFAULT '0',
  `mr_character_mushrooms_count` int NOT NULL DEFAULT '0',
  `collection_date` date DEFAULT NULL,
  `date_found` date DEFAULT NULL,
  `is_template` tinyint(1) NOT NULL DEFAULT '0',
  `template_name` varchar(255) DEFAULT NULL,
  `template_description` text,
  `city` varchar(255) DEFAULT NULL,
  `county` varchar(255) DEFAULT NULL,
  `personal_notes` text,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_mushrooms_on_user_id_and_name` (`user_id`,`name`),
  KEY `index_mushrooms_on_user_id` (`user_id`),
  KEY `index_mushrooms_on_country_id` (`country_id`),
  KEY `index_mushrooms_on_state_id` (`state_id`),
  KEY `index_mushrooms_on_fungus_type_id` (`fungus_type_id`),
  KEY `index_mushrooms_on_is_template` (`is_template`),
  KEY `index_mushrooms_on_fungus_type_id_and_is_template` (`fungus_type_id`,`is_template`),
  KEY `index_mushrooms_on_collection_date` (`collection_date`),
  FULLTEXT KEY `mushrooms_fulltext_idx` (`name`,`description`,`comments`),
  CONSTRAINT `fk_rails_0e85826c18` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rails_1d15355ab0` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_rails_5f7cae6dda` FOREIGN KEY (`state_id`) REFERENCES `states` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rails_abffdaf589` FOREIGN KEY (`fungus_type_id`) REFERENCES `fungus_types` (`id`) ON DELETE RESTRICT
) ENGINE=InnoDB AUTO_INCREMENT=134 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `newsletter_campaigns`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletter_campaigns` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `subject` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `from_email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` int NOT NULL DEFAULT '0',
  `recipients_count` int NOT NULL DEFAULT '0',
  `delivered_count` int NOT NULL DEFAULT '0',
  `failed_count` int NOT NULL DEFAULT '0',
  `queued_at` datetime(6) DEFAULT NULL,
  `started_at` datetime(6) DEFAULT NULL,
  `sent_at` datetime(6) DEFAULT NULL,
  `last_error` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_newsletter_campaigns_on_user_id` (`user_id`),
  KEY `index_newsletter_campaigns_on_status` (`status`),
  KEY `index_newsletter_campaigns_on_sent_at` (`sent_at`),
  CONSTRAINT `fk_rails_bcc4d60231` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `newsletter_subscribers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `newsletter_subscribers` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` int NOT NULL DEFAULT '0',
  `confirmation_sent_at` datetime(6) DEFAULT NULL,
  `confirmed_at` datetime(6) DEFAULT NULL,
  `unsubscribed_at` datetime(6) DEFAULT NULL,
  `last_emailed_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_newsletter_subscribers_on_email` (`email`),
  KEY `index_newsletter_subscribers_on_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `observation_methods`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `observation_methods` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `parts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `parts` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `plants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `plants` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `projects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `projects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `mushroom_projects_count` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_projects_on_name_unique` (`name`),
  KEY `index_projects_on_user_id` (`user_id`),
  CONSTRAINT `fk_rails_b872a6760a` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `role_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `role_permissions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `role_id` bigint NOT NULL,
  `permission_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_role_permissions_on_role_id` (`role_id`),
  KEY `index_role_permissions_on_permission_id` (`permission_id`),
  CONSTRAINT `fk_rails_439e640a3f` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`),
  CONSTRAINT `fk_rails_60126080bd` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `roles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `schema_migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `schema_migrations` (
  `version` varchar(255) NOT NULL,
  PRIMARY KEY (`version`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_blocked_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_blocked_executions` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_claimed_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
DROP TABLE IF EXISTS `solid_queue_claimed_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_claimed_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `process_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_claimed_executions_on_job_id` (`job_id`),
  KEY `index_solid_queue_claimed_executions_on_process_id_and_job_id` (`process_id`,`job_id`),
  CONSTRAINT `fk_rails_claimed_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_failed_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_failed_executions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `job_id` bigint NOT NULL,
  `error` text,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_failed_executions_on_job_id` (`job_id`),
  CONSTRAINT `fk_rails_failed_job_id` FOREIGN KEY (`job_id`) REFERENCES `solid_queue_jobs` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_jobs` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_pauses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_pauses` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `queue_name` varchar(255) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_solid_queue_pauses_on_queue_name` (`queue_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_processes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_processes` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_ready_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_ready_executions` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_recurring_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_recurring_executions` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_recurring_tasks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_recurring_tasks` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_scheduled_executions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_scheduled_executions` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `solid_queue_semaphores`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `solid_queue_semaphores` (
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
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `source_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
DROP TABLE IF EXISTS `source_data`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `source_data` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `title` varchar(255) DEFAULT NULL,
  `author` varchar(255) DEFAULT NULL,
  `ref` varchar(255) DEFAULT NULL,
  `item_code` varchar(255) DEFAULT NULL,
  `source_data_type_id` bigint DEFAULT NULL,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `user_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_source_data_on_source_data_type_id` (`source_data_type_id`),
  KEY `index_source_data_on_user_id` (`user_id`),
  KEY `index_source_data_on_user_id_and_source_data_type_id` (`user_id`,`source_data_type_id`),
  CONSTRAINT `fk_rails_2d439870ca` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_e2b6e4c854` FOREIGN KEY (`source_data_type_id`) REFERENCES `source_data_types` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980190985 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `source_data_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `source_data_types` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980190993 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `species`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `species` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `mblist_id` varchar(255) DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `genera_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_species_on_genera_id_and_name` (`genera_id`,`name`),
  KEY `index_species_on_genera_id` (`genera_id`),
  CONSTRAINT `fk_rails_21d681ad0e` FOREIGN KEY (`genera_id`) REFERENCES `genera` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191045 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `states`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `states` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `country_id` bigint DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `state_code` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_states_on_country_id` (`country_id`),
  CONSTRAINT `fk_rails_40bd891262` FOREIGN KEY (`country_id`) REFERENCES `countries` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191031 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `storage_locations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `storage_locations` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=43 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `subjects` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `slug` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_subjects_on_name` (`name`),
  UNIQUE KEY `index_subjects_on_slug` (`slug`)
) ENGINE=InnoDB AUTO_INCREMENT=857772753 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `trees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trees` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) DEFAULT NULL,
  `description` text,
  `comments` text,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=980191071 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `trusted_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `trusted_devices` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `device_token` varchar(255) NOT NULL,
  `device_fingerprint` varchar(255) NOT NULL,
  `trusted_at` datetime(6) NOT NULL,
  `expires_at` datetime(6) NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_trusted_devices_on_device_token` (`device_token`),
  KEY `index_trusted_devices_on_user_id` (`user_id`),
  KEY `index_trusted_devices_on_user_id_and_device_fingerprint` (`user_id`,`device_fingerprint`),
  CONSTRAINT `fk_rails_96c1dacf00` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `user_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_roles` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `index_user_roles_on_user_id` (`user_id`),
  KEY `index_user_roles_on_role_id` (`role_id`),
  CONSTRAINT `fk_rails_318345354e` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_rails_3369e0d5fc` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=69190601 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL DEFAULT '',
  `display_name` varchar(255) NOT NULL DEFAULT '',
  `permission_id` bigint DEFAULT '9',
  `encrypted_password` varchar(255) NOT NULL DEFAULT '',
  `otp_secret` varchar(255) DEFAULT NULL,
  `consumed_timestep` int DEFAULT NULL,
  `otp_required_for_login` tinyint(1) DEFAULT NULL,
  `reset_password_token` varchar(255) DEFAULT NULL,
  `reset_password_sent_at` datetime(6) DEFAULT NULL,
  `remember_created_at` datetime(6) DEFAULT NULL,
  `sign_in_count` int NOT NULL DEFAULT '0',
  `current_sign_in_at` datetime(6) DEFAULT NULL,
  `last_sign_in_at` datetime(6) DEFAULT NULL,
  `current_sign_in_ip` varchar(255) DEFAULT NULL,
  `last_sign_in_ip` varchar(255) DEFAULT NULL,
  `confirmation_token` varchar(255) DEFAULT NULL,
  `confirmed_at` datetime(6) DEFAULT NULL,
  `confirmation_sent_at` datetime(6) DEFAULT NULL,
  `unconfirmed_email` varchar(255) DEFAULT NULL,
  `failed_attempts` int NOT NULL DEFAULT '0',
  `unlock_token` varchar(255) DEFAULT NULL,
  `locked_at` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) NOT NULL,
  `updated_at` datetime(6) NOT NULL,
  `otp_backup_codes` json DEFAULT NULL,
  `default_country_id` bigint DEFAULT NULL,
  `default_state_id` bigint DEFAULT NULL,
  `default_city` varchar(255) DEFAULT NULL,
  `default_county` varchar(255) DEFAULT NULL,
  `temporary_admin` tinyint(1) NOT NULL DEFAULT '0',
  `admin_expires_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `index_users_on_email` (`email`),
  UNIQUE KEY `index_users_on_reset_password_token` (`reset_password_token`),
  UNIQUE KEY `index_users_on_confirmation_token` (`confirmation_token`),
  UNIQUE KEY `index_users_on_unlock_token` (`unlock_token`),
  KEY `index_users_on_permission_id` (`permission_id`),
  KEY `index_users_on_otp_required_for_login` (`otp_required_for_login`),
  KEY `index_users_on_default_country_id` (`default_country_id`),
  KEY `index_users_on_default_state_id` (`default_state_id`),
  KEY `index_users_on_admin_expires_at` (`admin_expires_at`),
  CONSTRAINT `fk_rails_1dc7d54aa4` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`),
  CONSTRAINT `fk_rails_cf1db3f966` FOREIGN KEY (`default_country_id`) REFERENCES `countries` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_rails_fa46210d28` FOREIGN KEY (`default_state_id`) REFERENCES `states` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=21 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
DROP TABLE IF EXISTS `versions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `versions` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `item_type` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `item_id` bigint NOT NULL,
  `event` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `whodunnit` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
  `object` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `index_versions_on_item_type_and_item_id` (`item_type`,`item_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1212 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

INSERT INTO `schema_migrations` (version) VALUES
('20260322180300'),
('20260322180200'),
('20260322174200'),
('20260322174100'),
('20260320150000'),
('20260320120000'),
('20260319160000'),
('20260319114749'),
('20260317075227'),
('20260313130000'),
('20260313123000'),
('20260224203800'),
('20260119114150'),
('20260115140618'),
('20260106131559'),
('20260105000002'),
('20260105000001'),
('20260101143053'),
('20251223143303'),
('20251221140452'),
('20251221134848'),
('20251221134829'),
('20251218163001'),
('20251218163000'),
('20251218003424'),
('20251218003419'),
('20251214200444'),
('20251210114118'),
('20251208163813'),
('20251201142731'),
('20251201142049'),
('20251126163733'),
('20251126163539'),
('20251121004557'),
('20251112170255'),
('20251110191731'),
('20251108194116'),
('20251107204901'),
('20251107125052'),
('20251107121443'),
('20251106124555'),
('20251104201925'),
('20251102203058'),
('20251102182005'),
('20251102163524'),
('20251102150009'),
('20251030232300'),
('20251021185144'),
('20251021185141'),
('20251021175901'),
('20251006000001'),
('20251005121500'),
('20251005120000'),
('20251005000001'),
('20250929000002'),
('20250929000001'),
('20250915000000'),
('20250914193147'),
('20250914000002'),
('20250902000002'),
('20250902000001'),
('20250901000001'),
('20250831000001'),
('20250822201733'),
('20250819000001'),
('20250814000109'),
('20250814000108'),
('20250814000092'),
('20250814000088'),
('20250814000084'),
('20250814000080'),
('20250814000078'),
('20250814000076'),
('20250814000074'),
('20250814000072'),
('20250814000068'),
('20250814000064'),
('20250814000060'),
('20250814000056'),
('20250814000052'),
('20250814000048'),
('20250814000044'),
('20250814000040'),
('20250814000038'),
('20250814000034'),
('20250814000026'),
('20250814000024'),
('20250814000022'),
('20250814000020'),
('20250814000017'),
('20250814000015'),
('20250814000014'),
('20250814000013'),
('20250814000012'),
('20250814000011'),
('20250814000010'),
('20250814000009'),
('20250814000008'),
('20250814000006'),
('20250814000005'),
('20250814000004'),
('20250814000003'),
('20250814000002'),
('20250814000001'),
('20250813000001');


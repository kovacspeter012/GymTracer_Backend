-- MySQL database export
START TRANSACTION;

CREATE DATABASE IF NOT EXISTS gymtracerdb
	CHARACTER SET utf8mb4
	COLLATE utf8mb4_hungarian_ci;

USE gymtracerdb;

CREATE TABLE IF NOT EXISTS `training_user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `training_id` BIGINT NOT NULL,
    `user_id` BIGINT NOT NULL,
    `application_date` DATETIME NOT NULL,
    `on_waitinglist` TINYINT(1) NOT NULL,
    `presence` TINYINT(1) NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `user_ticket` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `ticket_id` BIGINT NOT NULL,
    `payment_id` BIGINT NOT NULL,
    `creation_date` DATE NOT NULL,
    `expiration_date` DATE NOT NULL,
    `usage_amount` BIGINT UNSIGNED NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `ticket` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `type` ENUM ('training','daily','monthly','x_usage') NOT NULL,
    `description` TEXT NOT NULL,
    `is_student` TINYINT(1) NOT NULL,
    `price` BIGINT UNSIGNED NOT NULL,
    `tax_key` DECIMAL(5,2) UNSIGNED NOT NULL,
    `max_usage` BIGINT UNSIGNED,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `user` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) UNIQUE NOT NULL,
    `password` VARCHAR(255) NOT NULL,
    `birth_date` DATE,
    `role` ENUM('customer','trainer','staff','admin') NOT NULL,
    `creation_date` DATETIME NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `training` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `trainer_id` BIGINT NOT NULL,
    `name` VARCHAR(255) NOT NULL,
    `description` TEXT NOT NULL,
    `image` VARCHAR(255) NOT NULL,
    `start_time` DATETIME UNIQUE NOT NULL,
    `end_time` DATETIME UNIQUE NOT NULL,
    `max_participant` BIGINT NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `payments` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `issuer_id` BIGINT NOT NULL,
    `due_date` DATETIME NOT NULL,
    `payment_date` DATETIME,
    `total_price` BIGINT UNSIGNED NOT NULL,
    `receipt_number` VARCHAR(255) UNIQUE NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `usage_logs` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `card_id` BIGINT NOT NULL,
    `use_date` DATETIME NOT NULL,
    `gate` ENUM('main_entrance','main_exit','locker_room') NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `token` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL,
    `revoked_at` DATETIME,
    `token` VARCHAR(255) UNIQUE NOT NULL,
    PRIMARY KEY (`id`)
);



CREATE TABLE IF NOT EXISTS `card` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `user_id` BIGINT NOT NULL,
    `created_at` DATETIME NOT NULL,
    `revoked_at` DATETIME,
    `code` CHAR(36) UNIQUE NOT NULL,
    PRIMARY KEY (`id`)
);

CREATE TABLE IF NOT EXISTS `training_ticket` (
    `id` BIGINT NOT NULL AUTO_INCREMENT,
    `training_id` BIGINT NOT NULL,
    `ticket_id` BIGINT NOT NULL,
    PRIMARY KEY (`id`)
);


-- Foreign key constraints and unique indexes
ALTER TABLE `usage_logs` ADD CONSTRAINT `fk_usage_logs_card_id` FOREIGN KEY(`card_id`) REFERENCES `card`(`id`);

ALTER TABLE `card` ADD CONSTRAINT `fk_card_user_id` FOREIGN KEY(`user_id`) REFERENCES `user`(`id`);

ALTER TABLE `training_user` ADD CONSTRAINT `fk_training_user_training_id` FOREIGN KEY(`training_id`) REFERENCES `training`(`id`);
ALTER TABLE `training_user` ADD CONSTRAINT `fk_training_user_user_id` FOREIGN KEY(`user_id`) REFERENCES `user`(`id`);
ALTER TABLE `training_user`ADD CONSTRAINT `unique_index_training_user` UNIQUE(`training_id`,`user_id`);

ALTER TABLE `training` ADD CONSTRAINT `fk_training_trainer_id` FOREIGN KEY(`trainer_id`) REFERENCES `user`(`id`);

ALTER TABLE `token` ADD CONSTRAINT `fk_token_user_id` FOREIGN KEY(`user_id`) REFERENCES `user`(`id`);

ALTER TABLE `user_ticket` ADD CONSTRAINT `fk_user_ticket_payment_id` FOREIGN KEY(`payment_id`) REFERENCES `payments`(`id`);

ALTER TABLE `payments` ADD CONSTRAINT `fk_payments_issuer_id` FOREIGN KEY(`issuer_id`) REFERENCES `user`(`id`);

ALTER TABLE `user_ticket` ADD CONSTRAINT `fk_user_ticket_ticket_id` FOREIGN KEY(`ticket_id`) REFERENCES `ticket`(`id`);
ALTER TABLE `user_ticket` ADD CONSTRAINT `fk_user_ticket_user_id` FOREIGN KEY(`user_id`) REFERENCES `user`(`id`);

ALTER TABLE `training_ticket` ADD CONSTRAINT `fk_training_ticket_training_id` FOREIGN KEY(`training_id`) REFERENCES `training`(`id`);
ALTER TABLE `training_ticket` ADD CONSTRAINT `fk_training_ticket_ticket_id` FOREIGN KEY(`ticket_id`) REFERENCES `ticket`(`id`);
ALTER TABLE `training_ticket`ADD CONSTRAINT `unique_index_training_ticket` UNIQUE(`training_id`,`ticket_id`);


COMMIT;

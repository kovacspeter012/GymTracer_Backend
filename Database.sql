CREATE TABLE `Users` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `Name` varchar(100) NOT NULL,
    `Email` varchar(100) NOT NULL,
    `Password` varchar(128) NOT NULL,
    `BirthDate` datetime(6) NULL,
    `Role` int NOT NULL,
    `CreationDate` datetime(6) NOT NULL,
    `Active` tinyint(1) NOT NULL,
    PRIMARY KEY (`Id`)
);


CREATE TABLE `Cards` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `UserId` bigint NOT NULL,
    `CreatedAt` datetime(6) NOT NULL,
    `RevokedAt` datetime(6) NULL,
    `Code` char(36) NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Cards_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);


CREATE TABLE `Payments` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `IssuerId` bigint NOT NULL,
    `DueDate` datetime(6) NOT NULL,
    `PaymentDate` datetime(6) NULL,
    `TotalPrice` bigint unsigned NOT NULL,
    `ReceiptNumber` varchar(20) NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Payments_Users_IssuerId` FOREIGN KEY (`IssuerId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);


CREATE TABLE `Tokens` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `UserId` bigint NOT NULL,
    `CreatedAt` datetime(6) NOT NULL,
    `RevokedAt` datetime(6) NOT NULL,
    `TokenString` varchar(128) NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Tokens_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);


CREATE TABLE `Trainings` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `TrainerId` bigint NOT NULL,
    `Name` varchar(100) NOT NULL,
    `Description` longtext NOT NULL,
    `Image` varchar(100) NOT NULL,
    `StartTime` datetime(6) NOT NULL,
    `EndTime` datetime(6) NOT NULL,
    `MaxParticipant` bigint unsigned NOT NULL,
    `Active` tinyint(1) NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_Trainings_Users_TrainerId` FOREIGN KEY (`TrainerId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);


CREATE TABLE `UsageLogs` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `CardId` bigint NOT NULL,
    `UseDate` datetime(6) NOT NULL,
    `Gate` int NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_UsageLogs_Cards_CardId` FOREIGN KEY (`CardId`) REFERENCES `Cards` (`Id`) ON DELETE CASCADE
);


CREATE TABLE `Tickets` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `Type` int NOT NULL,
    `Description` longtext NOT NULL,
    `IsStudent` tinyint(1) NOT NULL,
    `Price` bigint unsigned NOT NULL,
    `Tax_key` decimal(5,2) NOT NULL,
    `MaxUsage` bigint unsigned NULL,
    `IsActive` tinyint(1) NOT NULL DEFAULT TRUE,
    `TrainingId` bigint NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `Tax_key_positive` CHECK (`Tax_key` >= 0),
    CONSTRAINT `FK_Tickets_Trainings_TrainingId` FOREIGN KEY (`TrainingId`) REFERENCES `Trainings` (`Id`)
);


CREATE TABLE `TrainingUsers` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `TrainingId` bigint NOT NULL,
    `UserId` bigint NOT NULL,
    `ApplicationDate` datetime(6) NOT NULL,
    `OnWaitinglist` tinyint(1) NOT NULL,
    `Presence` tinyint(1) NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_TrainingUsers_Trainings_TrainingId` FOREIGN KEY (`TrainingId`) REFERENCES `Trainings` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_TrainingUsers_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);


CREATE TABLE `UserTickets` (
    `Id` bigint NOT NULL AUTO_INCREMENT,
    `UserId` bigint NOT NULL,
    `TicketId` bigint NOT NULL,
    `PaymentId` bigint NOT NULL,
    `CreationDate` datetime(6) NOT NULL,
    `ExpirationDate` datetime(6) NOT NULL,
    `UsageAmount` bigint unsigned NOT NULL,
    PRIMARY KEY (`Id`),
    CONSTRAINT `FK_UserTickets_Payments_PaymentId` FOREIGN KEY (`PaymentId`) REFERENCES `Payments` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_UserTickets_Tickets_TicketId` FOREIGN KEY (`TicketId`) REFERENCES `Tickets` (`Id`) ON DELETE CASCADE,
    CONSTRAINT `FK_UserTickets_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
);


INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (1, 'Napijegy', TRUE, FALSE, 1, 2500, 27.0, NULL, 1);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (2, 'Havi bérlet', TRUE, FALSE, NULL, 18000, 27.0, NULL, 2);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (3, '10 alkalmas bérlet', TRUE, FALSE, 10, 22000, 27.0, NULL, 3);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (42, 'Napijegy Diák', TRUE, TRUE, 1, 1250, 27.0, NULL, 1);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (43, 'Havi bérlet Diák', TRUE, TRUE, NULL, 9000, 27.0, NULL, 2);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (44, '10 alkalmas bérlet Diák', TRUE, TRUE, 10, 11000, 27.0, NULL, 3);
SELECT ROW_COUNT();



INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (1, TRUE, '1985-05-10 00:00:00.000000', '2026-05-01 08:00:00.000000', 'admin@gym.hu', 'Adminisztrátor Anna', '$pbkdf2$sha256$10$9EpqZbBCER6wbi+1cQZIrA==$b27NmGCjC5ll/Xx9tp4atkezneCrwoHuQ7/972kLuDAlXaiTqkHXUwT809/wU+Zr', 3);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (2, TRUE, '1995-02-15 00:00:00.000000', '2026-05-01 08:00:00.000000', 'ricsi.staff@gym.hu', 'Recepciós Ricsi', '$pbkdf2$sha256$10$X2mISW/tTvaFPjHNmiVzHg==$MTCqu9sBR+HyMZ5L+WAsuWdu2VK90AncgJpJh/igzGSZxvbudqA8D+tKfHwrXpDm', 2);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (3, TRUE, '1990-11-20 00:00:00.000000', '2026-05-01 08:00:00.000000', 'elemer.edzo@gym.hu', 'Edző Elemér', '$pbkdf2$sha256$10$UwmbS+nW7ONxybIb7ZKkwg==$PKmOZkVG5LCfFYHCEG5XtprjBI1Hh8ZoxXoIolKRVWaGX8uubwipc7OACmqhu34p', 1);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (4, TRUE, '1992-06-11 00:00:00.000000', '2026-05-01 08:00:00.000000', 'eszter.edzo@gym.hu', 'Edző Eszter', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 1);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (5, TRUE, '1988-04-03 00:00:00.000000', '2026-05-01 08:00:00.000000', 'erik.edzo@gym.hu', 'Edző Erik', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 1);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (6, TRUE, '1994-09-21 00:00:00.000000', '2026-05-01 08:00:00.000000', 'edit.edzo@gym.hu', 'Edző Edit', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 1);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (7, TRUE, '1991-01-30 00:00:00.000000', '2026-05-01 08:00:00.000000', 'endre.edzo@gym.hu', 'Edző Endre', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 1);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (8, TRUE, '2001-03-12 00:00:00.000000', '2026-05-01 09:15:00.000000', 'janos.kovacs@email.com', 'Kovács János', '$pbkdf2$sha256$10$OMmHJZpe1+i+mqmppuZl7g==$e5iKNiO0PRFvk4cH2rhX0MfwLjm8NYuQpIpZ1M/T3E/0TejxJV3f8PQCPIH1qoWo', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (9, TRUE, '1998-07-25 00:00:00.000000', '2026-05-01 09:20:00.000000', 'anna.nagy@email.com', 'Nagy Anna', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (10, TRUE, '2003-11-05 00:00:00.000000', '2026-05-01 09:30:00.000000', 'peter.szabo@email.com', 'Szabó Péter', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (11, TRUE, '1995-12-18 00:00:00.000000', '2026-05-01 09:40:00.000000', 'maria.toth@email.com', 'Tóth Mária', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (12, TRUE, '1990-08-30 00:00:00.000000', '2026-05-01 09:45:00.000000', 'laszlo.kiss@email.com', 'Kiss László', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (13, TRUE, '1987-02-14 00:00:00.000000', '2026-05-01 09:50:00.000000', 'eva.varga@email.com', 'Varga Éva', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (14, TRUE, '1992-05-06 00:00:00.000000', '2026-05-01 09:55:00.000000', 'gabor.molnar@email.com', 'Molnár Gábor', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (15, TRUE, '1999-09-17 00:00:00.000000', '2026-05-01 10:00:00.000000', 'judit.farkas@email.com', 'Farkas Judit', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (16, TRUE, '2000-01-01 00:00:00.000000', '2026-05-01 10:10:00.000000', 'zoltan.balogh@email.com', 'Balogh Zoltán', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (17, TRUE, '1985-06-23 00:00:00.000000', '2026-05-01 10:15:00.000000', 'andrea.papp@email.com', 'Papp Andrea', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (18, TRUE, '1994-04-14 00:00:00.000000', '2026-05-01 10:20:00.000000', 'miklos.takacs@email.com', 'Takács Miklós', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (19, TRUE, '1996-03-08 00:00:00.000000', '2026-05-01 10:25:00.000000', 'katalin.juhasz@email.com', 'Juhász Katalin', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (20, TRUE, '1991-10-31 00:00:00.000000', '2026-05-01 10:30:00.000000', 'csaba.lakatos@email.com', 'Lakatos Csaba', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (21, TRUE, '2002-08-11 00:00:00.000000', '2026-05-01 10:35:00.000000', 'krisztina.meszaros@email.com', 'Mészáros Krisztina', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (22, TRUE, '1989-12-05 00:00:00.000000', '2026-05-01 10:40:00.000000', 'attila.simon@email.com', 'Simon Attila', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (23, TRUE, '1997-05-22 00:00:00.000000', '2026-05-01 10:45:00.000000', 'agnes.fekete@email.com', 'Fekete Ágnes', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (24, TRUE, '1986-07-07 00:00:00.000000', '2026-05-01 10:50:00.000000', 'zsolt.toth@email.com', 'Tóth Zsolt', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (25, TRUE, '1993-02-28 00:00:00.000000', '2026-05-01 10:55:00.000000', 'ildiko.szilagyi@email.com', 'Szilágyi Ildikó', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (26, TRUE, '1998-11-16 00:00:00.000000', '2026-05-01 11:00:00.000000', 'balazs.torok@email.com', 'Török Balázs', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (27, TRUE, '2004-01-09 00:00:00.000000', '2026-05-01 11:05:00.000000', 'dora.feher@email.com', 'Fehér Dóra', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (28, TRUE, '1995-10-24 00:00:00.000000', '2026-05-01 11:10:00.000000', 'tamas.racz@email.com', 'Rácz Tamás', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (29, TRUE, '1992-03-19 00:00:00.000000', '2026-05-01 11:15:00.000000', 'viktoria.kis@email.com', 'Kis Viktória', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();

INSERT INTO `Users` (`Id`, `Active`, `BirthDate`, `CreationDate`, `Email`, `Name`, `Password`, `Role`)
VALUES (30, TRUE, '1990-08-08 00:00:00.000000', '2026-05-01 11:20:00.000000', 'gergo.gal@email.com', 'Gál Gergő', '$pbkdf2$sha256$10$RzwqSi7MgrYQEcgSthPT7A==$db3Q+KxFdWEHFCemUKpLK7ygLIlIlChcJD+JJE0ltzXhNxobieAX2KjfnMVGJnyG', 0);
SELECT ROW_COUNT();



INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (1, 'ae25016a-edd0-4e2a-85cf-5fb04f53a001', '2026-05-01 12:00:00.000000', NULL, 8);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (2, 'ae25016a-edd0-4e2a-85cf-5fb04f53a002', '2026-05-01 12:05:00.000000', NULL, 9);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (3, 'ae25016a-edd0-4e2a-85cf-5fb04f53a003', '2026-05-01 12:10:00.000000', NULL, 10);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (4, 'ae25016a-edd0-4e2a-85cf-5fb04f53a004', '2026-05-01 12:15:00.000000', NULL, 11);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (5, 'ae25016a-edd0-4e2a-85cf-5fb04f53a005', '2026-05-01 12:20:00.000000', NULL, 12);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (6, 'ae25016a-edd0-4e2a-85cf-5fb04f53a999', '2026-05-01 12:30:00.000000', NULL, 12);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (7, 'ae25016a-edd0-4e2a-85cf-5fb04f53a007', '2026-05-01 12:30:00.000000', NULL, 14);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (8, 'ae25016a-edd0-4e2a-85cf-5fb04f53a008', '2026-05-01 12:35:00.000000', NULL, 15);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (9, 'ae25016a-edd0-4e2a-85cf-5fb04f53a009', '2026-05-01 12:40:00.000000', NULL, 16);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (10, 'ae25016a-edd0-4e2a-85cf-5fb04f53a010', '2026-05-01 12:45:00.000000', NULL, 17);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (11, 'ae25016a-edd0-4e2a-85cf-5fb04f53a011', '2026-05-01 12:50:00.000000', NULL, 18);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (12, 'ae25016a-edd0-4e2a-85cf-5fb04f53a012', '2026-05-01 12:55:00.000000', NULL, 19);
SELECT ROW_COUNT();

INSERT INTO `Cards` (`Id`, `Code`, `CreatedAt`, `RevokedAt`, `UserId`)
VALUES (13, 'ae25016a-edd0-4e2a-85cf-5fb04f53a013', '2026-05-01 13:00:00.000000', NULL, 20);
SELECT ROW_COUNT();



INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (1, '2026-05-01 10:00:00.000000', 8, '2026-05-01 10:00:00.000000', 'INV-202605-001', 2000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (2, '2026-05-01 11:00:00.000000', 9, '2026-05-01 11:00:00.000000', 'INV-202605-002', 18000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (3, '2026-05-01 11:30:00.000000', 10, '2026-05-01 11:30:00.000000', 'INV-202605-003', 2500);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (4, '2026-05-01 12:00:00.000000', 11, '2026-05-01 12:00:00.000000', 'INV-202605-004', 22000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (5, '2026-05-01 12:15:00.000000', 12, '2026-05-01 12:15:00.000000', 'INV-202605-005', 1800);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (6, '2026-05-01 12:30:00.000000', 13, '2026-05-01 12:30:00.000000', 'INV-202605-006', 18000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (7, '2026-05-01 13:00:00.000000', 14, '2026-05-01 13:00:00.000000', 'INV-202605-007', 2500);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (8, '2026-05-01 13:30:00.000000', 15, '2026-05-01 13:30:00.000000', 'INV-202605-008', 22000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (9, '2026-05-01 14:00:00.000000', 16, '2026-05-01 14:00:00.000000', 'INV-202605-009', 2000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (10, '2026-05-01 14:15:00.000000', 17, '2026-05-01 14:15:00.000000', 'INV-202605-010', 1500);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (11, '2026-05-01 14:30:00.000000', 18, '2026-05-01 14:30:00.000000', 'INV-202605-011', 18000);
SELECT ROW_COUNT();

INSERT INTO `Payments` (`Id`, `DueDate`, `IssuerId`, `PaymentDate`, `ReceiptNumber`, `TotalPrice`)
VALUES (12, '2026-05-01 15:00:00.000000', 19, '2026-05-01 15:00:00.000000', 'INV-202605-012', 2500);
SELECT ROW_COUNT();



INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (1, '2026-05-01 08:05:00.000000', '2026-05-02 08:05:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A360', 1);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (2, '2026-05-01 10:00:00.000000', '2026-05-02 10:00:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A361', 8);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (3, '2026-05-01 10:15:00.000000', '2026-05-02 10:15:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A362', 9);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (4, '2026-05-01 10:30:00.000000', '2026-05-02 10:30:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A363', 10);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (5, '2026-05-01 10:45:00.000000', '2026-05-02 10:45:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A364', 11);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (6, '2026-05-01 11:00:00.000000', '2026-05-02 11:00:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A365', 12);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (7, '2026-05-01 11:15:00.000000', '2026-05-02 11:15:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A366', 13);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (8, '2026-05-01 11:30:00.000000', '2026-05-02 11:30:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A367', 14);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (9, '2026-05-01 11:45:00.000000', '2026-05-02 11:45:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A368', 15);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (10, '2026-05-01 12:00:00.000000', '2026-05-02 12:00:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A369', 16);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (11, '2026-05-01 12:15:00.000000', '2026-05-02 12:15:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A370', 17);
SELECT ROW_COUNT();

INSERT INTO `Tokens` (`Id`, `CreatedAt`, `RevokedAt`, `TokenString`, `UserId`)
VALUES (12, '2026-05-01 12:30:00.000000', '2026-05-02 12:30:00.000000', '575D6F6985153B428B4BEF8FD525BEA1F78E502B9DA6654A1EB774997C06B9F30FF132D9A44F296E176767A148175538579C459051474120FB85530D89C7A371', 18);
SELECT ROW_COUNT();



INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (1, TRUE, 'Frissítő napindító jóga', '2026-05-05 08:00:00.000000', 'yoga_morning.jpg', 15, 'Reggeli Jóga', '2026-05-05 07:00:00.000000', 3);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (2, TRUE, 'Alapok elsajátítása', '2026-05-06 18:30:00.000000', 'crossfit_basic.jpg', 10, 'CrossFit Kezdő', '2026-05-06 17:00:00.000000', 4);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (3, TRUE, 'Saját testsúlyos edzés', '2026-05-07 19:00:00.000000', 'trx_pro.jpg', 12, 'Haladó TRX', '2026-05-07 18:00:00.000000', 5);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (4, TRUE, 'Táncos kardió', '2026-05-08 20:00:00.000000', 'zumba.jpg', 20, 'Zumba Fit', '2026-05-08 19:00:00.000000', 6);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (5, TRUE, 'Erőfejlesztés', '2026-05-10 17:30:00.000000', 'weightlifting.jpg', 8, 'Súlyemelés', '2026-05-10 16:00:00.000000', 7);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (6, TRUE, 'Kardió tekerés', '2026-05-12 19:00:00.000000', 'spinning1.jpg', 15, 'Spinning 1', '2026-05-12 18:00:00.000000', 3);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (7, TRUE, 'Core izmok erősítése', '2026-05-14 18:00:00.000000', 'pilates.jpg', 15, 'Pilates', '2026-05-14 17:00:00.000000', 4);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (8, TRUE, 'Dinamikus erőnléti', '2026-05-15 19:30:00.000000', 'kettlebell.jpg', 12, 'Kettlebell', '2026-05-15 18:30:00.000000', 5);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (9, TRUE, 'Technika és állóképesség', '2026-05-18 20:30:00.000000', 'box.jpg', 10, 'Box edzés', '2026-05-18 19:00:00.000000', 6);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (10, TRUE, 'Magas intenzitású intervall', '2026-05-20 19:00:00.000000', 'hiit.jpg', 20, 'HIIT', '2026-05-20 18:00:00.000000', 7);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (11, TRUE, 'Törzsizomzat fejlesztése', '2026-05-22 18:30:00.000000', 'core.jpg', 15, 'Core tréning', '2026-05-22 17:30:00.000000', 3);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (12, TRUE, 'Nyújtás és lazítás', '2026-05-25 20:00:00.000000', 'stretching.jpg', 20, 'Stretching', '2026-05-25 19:00:00.000000', 4);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (13, TRUE, 'Összetett gyakorlatok', '2026-05-27 19:00:00.000000', 'functional.jpg', 12, 'Funkcionális edzés', '2026-05-27 18:00:00.000000', 5);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (14, TRUE, 'Klasszikus aerobik', '2026-05-29 18:00:00.000000', 'aerobik.jpg', 25, 'Aerobik', '2026-05-29 17:00:00.000000', 6);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (15, TRUE, 'Szülés utáni regeneráció', '2026-06-02 11:00:00.000000', 'babamama.jpg', 10, 'Baba-mama torna', '2026-06-02 10:00:00.000000', 7);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (16, TRUE, 'Tartásjavító torna', '2026-06-05 17:00:00.000000', 'gerinc.jpg', 15, 'Gerinctorna', '2026-06-05 16:00:00.000000', 3);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (17, TRUE, 'Állóképesség fejlesztés', '2026-06-10 19:00:00.000000', 'cardio.jpg', 20, 'Kardió mix', '2026-06-10 18:00:00.000000', 4);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (18, TRUE, 'Nehéz súlyok', '2026-06-15 19:00:00.000000', 'powerlifting.jpg', 8, 'Erőemelés', '2026-06-15 17:30:00.000000', 5);
SELECT ROW_COUNT();

INSERT INTO `Trainings` (`Id`, `Active`, `Description`, `EndTime`, `Image`, `MaxParticipant`, `Name`, `StartTime`, `TrainerId`)
VALUES (19, TRUE, 'Haladó tekerés', '2026-06-20 20:00:00.000000', 'spinning2.jpg', 15, 'Spinning 2', '2026-06-20 19:00:00.000000', 6);
SELECT ROW_COUNT();



INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (4, 'Reggeli Jóga Jegy', TRUE, FALSE, 1, 2000, 27.0, 1, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (5, 'Reggeli Jóga Diák', TRUE, TRUE, 1, 1500, 27.0, 1, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (6, 'CrossFit Kezdő Jegy', TRUE, FALSE, 1, 2500, 27.0, 2, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (7, 'CrossFit Kezdő Diák', TRUE, TRUE, 1, 1800, 27.0, 2, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (8, 'Haladó TRX Jegy', TRUE, FALSE, 1, 2200, 27.0, 3, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (9, 'Haladó TRX Diák', TRUE, TRUE, 1, 1600, 27.0, 3, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (10, 'Zumba Fit Jegy', TRUE, FALSE, 1, 1800, 27.0, 4, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (11, 'Zumba Fit Diák', TRUE, TRUE, 1, 1400, 27.0, 4, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (12, 'Súlyemelés Jegy', TRUE, FALSE, 1, 2500, 27.0, 5, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (13, 'Súlyemelés Diák', TRUE, TRUE, 1, 1800, 27.0, 5, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (14, 'Spinning 1 Jegy', TRUE, FALSE, 1, 2000, 27.0, 6, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (15, 'Spinning 1 Diák', TRUE, TRUE, 1, 1500, 27.0, 6, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (16, 'Pilates Jegy', TRUE, FALSE, 1, 2000, 27.0, 7, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (17, 'Pilates Diák', TRUE, TRUE, 1, 1500, 27.0, 7, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (18, 'Kettlebell Jegy', TRUE, FALSE, 1, 2200, 27.0, 8, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (19, 'Kettlebell Diák', TRUE, TRUE, 1, 1600, 27.0, 8, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (20, 'Box edzés Jegy', TRUE, FALSE, 1, 2500, 27.0, 9, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (21, 'Box edzés Diák', TRUE, TRUE, 1, 1800, 27.0, 9, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (22, 'HIIT Jegy', TRUE, FALSE, 1, 2000, 27.0, 10, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (23, 'HIIT Diák', TRUE, TRUE, 1, 1500, 27.0, 10, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (24, 'Core tréning Jegy', TRUE, FALSE, 1, 1800, 27.0, 11, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (25, 'Core tréning Diák', TRUE, TRUE, 1, 1400, 27.0, 11, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (26, 'Stretching Jegy', TRUE, FALSE, 1, 1500, 27.0, 12, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (27, 'Stretching Diák', TRUE, TRUE, 1, 1000, 27.0, 12, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (28, 'Funkcionális Jegy', TRUE, FALSE, 1, 2200, 27.0, 13, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (29, 'Funkcionális Diák', TRUE, TRUE, 1, 1600, 27.0, 13, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (30, 'Aerobik Jegy', TRUE, FALSE, 1, 1800, 27.0, 14, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (31, 'Aerobik Diák', TRUE, TRUE, 1, 1400, 27.0, 14, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (32, 'Baba-mama Jegy', TRUE, FALSE, 1, 2000, 27.0, 15, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (33, 'Baba-mama Diák', TRUE, TRUE, 1, 1500, 27.0, 15, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (34, 'Gerinctorna Jegy', TRUE, FALSE, 1, 1800, 27.0, 16, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (35, 'Gerinctorna Diák', TRUE, TRUE, 1, 1400, 27.0, 16, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (36, 'Kardió mix Jegy', TRUE, FALSE, 1, 2000, 27.0, 17, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (37, 'Kardió mix Diák', TRUE, TRUE, 1, 1500, 27.0, 17, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (38, 'Erőemelés Jegy', TRUE, FALSE, 1, 2500, 27.0, 18, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (39, 'Erőemelés Diák', TRUE, TRUE, 1, 1800, 27.0, 18, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (40, 'Spinning 2 Jegy', TRUE, FALSE, 1, 2200, 27.0, 19, 0);
SELECT ROW_COUNT();

INSERT INTO `Tickets` (`Id`, `Description`, `IsActive`, `IsStudent`, `MaxUsage`, `Price`, `Tax_key`, `TrainingId`, `Type`)
VALUES (41, 'Spinning 2 Diák', TRUE, TRUE, 1, 1600, 27.0, 19, 0);
SELECT ROW_COUNT();



INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (1, '2026-05-01 10:10:00.000000', FALSE, FALSE, 1, 8);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (2, '2026-05-01 10:15:00.000000', FALSE, FALSE, 1, 9);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (3, '2026-05-01 10:20:00.000000', FALSE, FALSE, 2, 10);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (4, '2026-05-01 10:25:00.000000', FALSE, FALSE, 2, 11);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (5, '2026-05-01 10:30:00.000000', FALSE, FALSE, 3, 12);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (6, '2026-05-01 10:35:00.000000', FALSE, FALSE, 3, 13);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (7, '2026-05-01 10:40:00.000000', FALSE, FALSE, 4, 14);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (8, '2026-05-01 10:45:00.000000', FALSE, FALSE, 4, 15);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (9, '2026-05-01 10:50:00.000000', FALSE, FALSE, 5, 16);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (10, '2026-05-01 10:55:00.000000', TRUE, FALSE, 5, 17);
SELECT ROW_COUNT();

INSERT INTO `TrainingUsers` (`Id`, `ApplicationDate`, `OnWaitinglist`, `Presence`, `TrainingId`, `UserId`)
VALUES (11, '2026-05-01 11:00:00.000000', FALSE, FALSE, 6, 18);
SELECT ROW_COUNT();



INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (1, 3, 1, '2026-05-01 07:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (2, 8, 0, '2026-05-01 08:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (3, 12, 2, '2026-05-01 10:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (4, 5, 1, '2026-05-02 16:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (5, 1, 0, '2026-05-02 17:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (6, 9, 2, '2026-05-03 09:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (7, 2, 1, '2026-05-03 11:55:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (8, 13, 0, '2026-05-04 06:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (9, 7, 2, '2026-05-04 18:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (10, 4, 1, '2026-05-05 08:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (11, 11, 0, '2026-05-05 19:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (12, 6, 2, '2026-05-06 14:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (13, 10, 1, '2026-05-06 15:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (14, 8, 0, '2026-05-07 07:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (15, 3, 2, '2026-05-07 12:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (16, 1, 1, '2026-05-08 09:00:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (17, 5, 0, '2026-05-08 16:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (18, 12, 2, '2026-05-09 10:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (19, 2, 1, '2026-05-09 11:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (20, 9, 0, '2026-05-10 08:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (21, 13, 2, '2026-05-10 17:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (22, 7, 1, '2026-05-11 19:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (23, 4, 0, '2026-05-11 20:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (24, 11, 2, '2026-05-12 07:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (25, 6, 1, '2026-05-12 15:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (26, 10, 0, '2026-05-13 16:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (27, 8, 2, '2026-05-13 18:00:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (28, 3, 1, '2026-05-14 09:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (29, 1, 0, '2026-05-14 10:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (30, 5, 2, '2026-05-15 08:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (31, 12, 1, '2026-05-15 12:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (32, 2, 0, '2026-05-16 14:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (33, 9, 2, '2026-05-16 17:55:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (34, 13, 1, '2026-05-17 11:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (35, 7, 0, '2026-05-17 18:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (36, 4, 2, '2026-05-18 07:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (37, 11, 1, '2026-05-18 09:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (38, 6, 0, '2026-05-19 16:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (39, 10, 2, '2026-05-19 19:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (40, 8, 1, '2026-05-20 08:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (41, 3, 0, '2026-05-20 11:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (42, 1, 2, '2026-05-21 15:00:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (43, 5, 1, '2026-05-21 17:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (44, 12, 0, '2026-05-22 06:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (45, 2, 2, '2026-05-22 09:55:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (46, 9, 1, '2026-05-23 14:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (47, 13, 0, '2026-05-23 18:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (48, 7, 2, '2026-05-24 10:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (49, 4, 1, '2026-05-24 12:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (50, 11, 0, '2026-05-25 08:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (51, 6, 2, '2026-05-25 16:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (52, 10, 1, '2026-05-26 19:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (53, 8, 0, '2026-05-26 20:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (54, 3, 2, '2026-05-27 07:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (55, 1, 1, '2026-05-27 11:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (56, 5, 0, '2026-05-28 15:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (57, 12, 2, '2026-05-28 18:00:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (58, 2, 1, '2026-05-29 09:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (59, 9, 0, '2026-05-29 13:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (60, 13, 2, '2026-05-30 08:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (61, 7, 1, '2026-05-30 10:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (62, 4, 0, '2026-05-31 16:55:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (63, 11, 2, '2026-05-31 19:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (64, 6, 1, '2026-06-01 07:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (65, 10, 0, '2026-06-01 12:00:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (66, 8, 2, '2026-06-02 15:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (67, 3, 1, '2026-06-02 18:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (68, 1, 0, '2026-06-03 09:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (69, 5, 2, '2026-06-03 11:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (70, 12, 1, '2026-06-04 16:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (71, 2, 0, '2026-06-04 19:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (72, 9, 2, '2026-06-05 08:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (73, 13, 1, '2026-06-05 14:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (74, 7, 0, '2026-06-06 17:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (75, 4, 2, '2026-06-06 20:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (76, 11, 1, '2026-06-07 07:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (77, 6, 0, '2026-06-07 10:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (78, 10, 2, '2026-06-08 15:55:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (79, 8, 1, '2026-06-08 18:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (80, 3, 0, '2026-06-09 09:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (81, 1, 2, '2026-06-09 12:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (82, 5, 1, '2026-06-10 16:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (83, 12, 0, '2026-06-10 19:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (84, 2, 2, '2026-06-11 08:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (85, 9, 1, '2026-06-11 11:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (86, 13, 0, '2026-06-12 15:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (87, 7, 2, '2026-06-12 18:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (88, 4, 1, '2026-06-13 09:40:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (89, 11, 0, '2026-06-14 14:25:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (90, 6, 2, '2026-06-15 17:10:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (91, 10, 1, '2026-06-16 19:55:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (92, 8, 0, '2026-06-17 08:30:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (93, 3, 2, '2026-06-18 11:15:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (94, 1, 1, '2026-06-19 15:00:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (95, 5, 0, '2026-06-20 18:45:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (96, 12, 2, '2026-06-22 09:20:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (97, 2, 1, '2026-06-24 12:05:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (98, 9, 0, '2026-06-26 16:50:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (99, 13, 2, '2026-06-28 19:35:00.000000');
SELECT ROW_COUNT();

INSERT INTO `UsageLogs` (`Id`, `CardId`, `Gate`, `UseDate`)
VALUES (100, 7, 1, '2026-06-30 08:10:00.000000');
SELECT ROW_COUNT();



INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (2, '2026-05-01 11:05:00.000000', '2026-06-01 23:59:59.000000', 2, 2, 0, 9);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (3, '2026-05-01 11:35:00.000000', '2026-05-01 23:59:59.000000', 3, 1, 0, 10);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (4, '2026-05-01 12:05:00.000000', '2026-08-01 23:59:59.000000', 4, 3, 0, 11);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (6, '2026-05-01 12:35:00.000000', '2026-06-01 23:59:59.000000', 6, 2, 0, 13);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (8, '2026-05-01 13:35:00.000000', '2026-08-01 23:59:59.000000', 8, 3, 0, 15);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (11, '2026-05-01 14:35:00.000000', '2026-06-01 23:59:59.000000', 11, 2, 0, 18);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (12, '2026-05-01 15:05:00.000000', '2026-05-01 23:59:59.000000', 12, 1, 0, 19);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (1, '2026-05-01 10:05:00.000000', '2026-05-05 08:00:00.000000', 1, 4, 0, 8);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (5, '2026-05-01 12:20:00.000000', '2026-05-06 18:30:00.000000', 5, 7, 0, 12);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (7, '2026-05-01 13:05:00.000000', '2026-05-10 17:30:00.000000', 7, 12, 0, 14);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (9, '2026-05-01 14:05:00.000000', '2026-05-12 19:00:00.000000', 9, 14, 0, 16);
SELECT ROW_COUNT();

INSERT INTO `UserTickets` (`Id`, `CreationDate`, `ExpirationDate`, `PaymentId`, `TicketId`, `UsageAmount`, `UserId`)
VALUES (10, '2026-05-01 14:20:00.000000', '2026-05-14 18:00:00.000000', 10, 17, 0, 17);
SELECT ROW_COUNT();



CREATE UNIQUE INDEX `IX_Cards_Code` ON `Cards` (`Code`);


CREATE INDEX `IX_Cards_UserId` ON `Cards` (`UserId`);


CREATE INDEX `IX_Payments_IssuerId` ON `Payments` (`IssuerId`);


CREATE UNIQUE INDEX `IX_Payments_ReceiptNumber` ON `Payments` (`ReceiptNumber`);


CREATE INDEX `IX_Tickets_IsActive` ON `Tickets` (`IsActive`);


CREATE INDEX `IX_Tickets_TrainingId` ON `Tickets` (`TrainingId`);


CREATE UNIQUE INDEX `IX_Tokens_TokenString` ON `Tokens` (`TokenString`);


CREATE INDEX `IX_Tokens_UserId` ON `Tokens` (`UserId`);


CREATE INDEX `IX_Trainings_TrainerId` ON `Trainings` (`TrainerId`);


CREATE UNIQUE INDEX `IX_TrainingUsers_TrainingId_UserId` ON `TrainingUsers` (`TrainingId`, `UserId`);


CREATE INDEX `IX_TrainingUsers_UserId` ON `TrainingUsers` (`UserId`);


CREATE INDEX `IX_UsageLogs_CardId` ON `UsageLogs` (`CardId`);


CREATE UNIQUE INDEX `IX_Users_Email` ON `Users` (`Email`);


CREATE UNIQUE INDEX `IX_UserTickets_PaymentId` ON `UserTickets` (`PaymentId`);


CREATE INDEX `IX_UserTickets_TicketId` ON `UserTickets` (`TicketId`);


CREATE INDEX `IX_UserTickets_UserId` ON `UserTickets` (`UserId`);



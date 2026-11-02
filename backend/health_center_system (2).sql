-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jul 28, 2026 at 06:52 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `health_center_system`
--

-- --------------------------------------------------------

--
-- Table structure for table `admins`
--

CREATE TABLE `admins` (
  `id` int(11) NOT NULL,
  `name` varchar(120) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(60) NOT NULL DEFAULT 'RHU Staff',
  `branch` varchar(120) NOT NULL DEFAULT 'All Branches',
  `account_status` enum('Active','Disabled') NOT NULL DEFAULT 'Active',
  `last_notification_read_at` datetime DEFAULT NULL,
  `failed_login_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `last_login_at` datetime DEFAULT NULL,
  `last_activity_at` datetime DEFAULT NULL,
  `last_logout_at` datetime DEFAULT NULL,
  `last_ip` varchar(64) DEFAULT NULL,
  `last_user_agent` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admins`
--

INSERT INTO `admins` (`id`, `name`, `email`, `password_hash`, `role`, `branch`, `account_status`, `last_notification_read_at`, `failed_login_attempts`, `locked_until`, `created_at`, `last_login_at`, `last_activity_at`, `last_logout_at`, `last_ip`, `last_user_agent`) VALUES
(1, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', 'System Administrator', 'All Branches', 'Active', '2026-07-28 16:08:45', 0, NULL, '2026-07-13 13:32:15', '2026-07-28 20:13:49', '2026-07-28 20:27:54', '2026-07-28 20:27:54', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
(2, 'RHU I Staff', 'rhu1@pulilan.gov.ph', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', 'RHU Staff', 'RHU I - Poblacion', 'Active', '2026-07-27 22:45:30', 0, NULL, '2026-07-13 13:32:15', '2026-07-28 01:56:05', '2026-07-28 02:14:59', '2026-07-28 02:14:59', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
(3, 'RHU II Staff', 'rhu2@pulilan.gov.ph', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', 'RHU Staff', 'RHU II - Cutcot', 'Active', '2026-07-27 22:46:39', 0, NULL, '2026-07-13 13:32:15', '2026-07-28 02:15:10', '2026-07-28 02:15:23', '2026-07-28 02:15:23', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
(4, 'RHU III Staff', 'rhu3@pulilan.gov.ph', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', 'RHU Staff', 'RHU III - Tinejero', 'Active', '2026-07-27 22:47:12', 0, NULL, '2026-07-13 13:32:15', '2026-07-28 02:15:31', '2026-07-28 02:15:43', '2026-07-28 02:15:43', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
(5, 'RHU IV Staff', 'rhu4@pulilan.gov.ph', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', 'RHU Staff', 'RHU IV - Tibag', 'Active', '2026-07-27 22:47:41', 0, NULL, '2026-07-13 13:32:15', '2026-07-28 02:15:50', '2026-07-28 02:16:00', '2026-07-28 02:16:00', '::1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/150.0.0.0 Safari/537.36'),
(6, 'System Administrator', 'admin@pulilan.gov.ph', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', 'System Administrator', 'All Branches', 'Active', NULL, 0, NULL, '2026-07-13 13:32:34', NULL, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Table structure for table `announcements`
--

CREATE TABLE `announcements` (
  `id` int(11) NOT NULL,
  `title` varchar(180) NOT NULL,
  `message` text NOT NULL,
  `branch` varchar(120) NOT NULL DEFAULT 'All Branches',
  `target_barangay` varchar(120) NOT NULL DEFAULT 'All Barangays',
  `publish_at` datetime DEFAULT NULL,
  `expires_at` datetime DEFAULT NULL,
  `status` enum('Draft','Published','Archived') NOT NULL DEFAULT 'Published',
  `priority` enum('normal','important','urgent') NOT NULL DEFAULT 'normal',
  `attachment_path` varchar(255) DEFAULT NULL,
  `attachment_name` varchar(255) DEFAULT NULL,
  `attachment_mime` varchar(100) DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcements`
--

INSERT INTO `announcements` (`id`, `title`, `message`, `branch`, `target_barangay`, `publish_at`, `expires_at`, `status`, `priority`, `attachment_path`, `attachment_name`, `attachment_mime`, `created_by`, `created_at`, `updated_at`) VALUES
(1, 'Free Flu Vaccination', 'Free flu vaccination is available for senior citizens at Pulilan Health Center from July 28 to August 15, 2026. Please bring a valid ID and, if available, your vaccination record. Visit during clinic hours or contact your assigned RHU for assistance.', 'All Branches', 'All Barangays', '2026-07-28 14:37:00', '2026-07-30 14:37:00', 'Published', 'normal', 'uploads/announcements/e4bb22c6b45866272df1c8693ad2ac44.png', 'ChatGPT Image Jul 28_ 2026_ 02_37_43 PM.png', 'image/png', 1, '2026-07-13 16:07:50', '2026-07-28 06:51:46');

-- --------------------------------------------------------

--
-- Table structure for table `announcement_reads`
--

CREATE TABLE `announcement_reads` (
  `announcement_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `announcement_reads`
--

INSERT INTO `announcement_reads` (`announcement_id`, `patient_id`, `read_at`) VALUES
(1, 2, '2026-07-20 15:07:16'),
(1, 8, '2026-07-24 08:24:38'),
(1, 9, '2026-07-24 08:24:41'),
(1, 10, '2026-07-24 08:27:13'),
(1, 11, '2026-07-24 08:40:59'),
(1, 13, '2026-07-27 08:40:03'),
(1, 14, '2026-07-27 08:40:36'),
(1, 15, '2026-07-27 08:50:45'),
(1, 16, '2026-07-28 05:04:32'),
(1, 17, '2026-07-28 05:28:29'),
(1, 18, '2026-07-28 08:00:27'),
(1, 19, '2026-07-28 12:38:07'),
(1, 20, '2026-07-28 12:37:26'),
(1, 21, '2026-07-28 12:39:06'),
(1, 22, '2026-07-28 12:39:36'),
(1, 23, '2026-07-28 12:41:26'),
(1, 24, '2026-07-28 12:42:28'),
(1, 25, '2026-07-28 12:43:22'),
(1, 26, '2026-07-28 12:58:46'),
(1, 27, '2026-07-28 13:03:36');

-- --------------------------------------------------------

--
-- Table structure for table `appointments`
--

CREATE TABLE `appointments` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `queue_number` varchar(20) NOT NULL,
  `center` varchar(120) NOT NULL,
  `service` varchar(120) NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` varchar(30) NOT NULL,
  `queue_type` enum('regular','priority','emergency') DEFAULT 'regular',
  `priority_reason` varchar(120) DEFAULT NULL,
  `concern` text DEFAULT NULL,
  `status` enum('Pending','Confirmed','Serving','Done','Cancelled','No Show','Hold') DEFAULT 'Confirmed',
  `arrival_status` varchar(20) NOT NULL DEFAULT 'not_arrived',
  `arrived_at` datetime DEFAULT NULL,
  `service_started_at` datetime DEFAULT NULL,
  `completed_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `appointments`
--

INSERT INTO `appointments` (`id`, `patient_id`, `queue_number`, `center`, `service`, `appointment_date`, `appointment_time`, `queue_type`, `priority_reason`, `concern`, `status`, `arrival_status`, `arrived_at`, `service_started_at`, `completed_at`, `created_at`, `updated_at`) VALUES
(1, 2, 'A-001', 'RHU II - Cutcot', 'Vaccination', '2026-07-17', '08:30 AM', 'regular', '', NULL, 'Done', 'not_arrived', NULL, NULL, NULL, '2026-07-13 13:35:34', '2026-07-14 10:38:14'),
(2, 2, 'A-001', 'RHU I - Poblacion', 'Vaccination', '2026-07-15', '08:00 AM', 'regular', '', NULL, 'Done', 'not_arrived', NULL, NULL, '2026-07-28 16:08:12', '2026-07-14 12:09:51', '2026-07-28 08:08:12'),
(3, 2, 'A-001', 'RHU I - Poblacion', 'Vaccination', '2026-07-21', '09:30 AM', 'regular', '', NULL, 'Done', 'arrived', '2026-07-21 02:02:42', NULL, '2026-07-28 16:08:12', '2026-07-20 17:43:42', '2026-07-28 08:08:12'),
(4, 2, 'A-001', 'RHU I - Poblacion', 'Vaccination', '2026-07-22', '08:00 AM', 'regular', '', NULL, 'Done', 'not_arrived', NULL, NULL, '2026-07-28 16:08:12', '2026-07-21 16:32:35', '2026-07-28 08:08:12'),
(5, 8, 'A-001', 'RHU I - Poblacion', 'Vaccination', '2026-07-31', '10:00 AM', 'regular', '', NULL, 'Done', 'not_arrived', NULL, NULL, '2026-07-28 16:08:12', '2026-07-24 08:27:46', '2026-07-28 08:08:12'),
(6, 11, 'P-001', 'RHU I - Poblacion', 'Prenatal Care', '2026-07-25', '08:00 AM', 'priority', 'Pregnant', NULL, 'Done', 'arrived', '2026-07-25 01:12:55', NULL, NULL, '2026-07-24 08:45:10', '2026-07-24 17:14:29'),
(7, 8, 'A-001', 'RHU I - Poblacion', 'Vaccination', '2026-07-25', '08:00 AM', 'regular', '', NULL, 'Done', 'not_arrived', NULL, NULL, '2026-07-28 16:08:12', '2026-07-24 08:51:59', '2026-07-28 08:08:12'),
(8, 2, 'A-002', 'RHU I - Poblacion', 'Vaccination', '2026-07-27', '08:30 AM', 'regular', '', NULL, 'Done', 'arrived', '2026-07-27 16:44:23', '2026-07-27 16:44:30', '2026-07-27 16:46:06', '2026-07-26 07:06:23', '2026-07-27 08:46:06'),
(9, 12, 'E-001', 'RHU I - Poblacion', 'General Consultation', '2026-07-27', '16:39', 'emergency', 'Vomiting', NULL, 'Done', 'arrived', '2026-07-27 16:39:00', '2026-07-27 16:39:09', '2026-07-27 16:39:25', '2026-07-27 08:39:00', '2026-07-27 08:39:25'),
(10, 14, 'APT-00010', 'RHU I - Poblacion', 'General Consultation', '2026-07-28', '04:30 PM', 'regular', '', NULL, 'Cancelled', 'not_arrived', NULL, NULL, NULL, '2026-07-27 08:46:33', '2026-07-28 12:37:21'),
(11, 9, 'APT-00011', 'RHU III - Tinejero', 'General Consultation', '2026-07-28', '04:30 PM', 'priority', 'PWD', NULL, 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-27 08:48:05', '2026-07-27 13:37:47'),
(12, 13, 'APT-00012', 'RHU I - Poblacion', 'Vaccination', '2026-07-28', '04:30 PM', 'regular', '', NULL, 'Cancelled', 'not_arrived', NULL, NULL, NULL, '2026-07-27 08:48:15', '2026-07-28 12:37:20'),
(13, 15, 'APT-00013', 'RHU I - Poblacion', 'Prenatal Care', '2026-07-28', '04:30 PM', 'priority', 'Pregnant', NULL, 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-27 08:53:00', '2026-07-27 13:37:47'),
(14, 8, 'APT-00014', 'RHU I - Poblacion', 'Vaccination', '2026-07-28', '04:30 PM', 'priority', 'PWD', NULL, 'Cancelled', 'not_arrived', NULL, NULL, NULL, '2026-07-27 08:56:09', '2026-07-28 12:44:07'),
(15, 2, 'A-001', 'RHU I - Poblacion', 'Vaccination', '2026-07-28', '08:30 AM', 'regular', '', NULL, 'Done', 'arrived', '2026-07-28 16:06:51', '2026-07-28 16:06:58', '2026-07-28 16:08:12', '2026-07-27 09:10:47', '2026-07-28 08:08:12'),
(16, 17, 'APT-00016', 'RHU IV - Tibag', 'Family Planning', '2026-07-30', '09:30 AM', 'priority', 'PWD', 'Cfollow up check for my blood pressure', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 05:50:45', '2026-07-28 05:50:45'),
(17, 18, 'APT-00017', 'RHU I - Poblacion', 'Vaccination', '2026-07-29', '08:00 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 08:01:49', '2026-07-28 08:01:49'),
(18, 2, 'APT-00018', 'RHU III - Tinejero', 'Vaccination', '2026-07-29', '08:00 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 08:09:24', '2026-07-28 08:09:24'),
(19, 13, 'APT-00019', 'RHU I - Poblacion', 'Vaccination', '2026-07-29', '08:30 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:37:35', '2026-07-28 12:37:35'),
(20, 14, 'APT-00020', 'RHU II - Cutcot', 'General Consultation', '2026-07-29', '08:00 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:37:49', '2026-07-28 12:37:49'),
(21, 20, 'APT-00021', 'RHU III - Tinejero', 'Child Immunization', '2026-07-31', '11:00 AM', 'priority', 'Senior Citizen', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:39:46', '2026-07-28 12:39:46'),
(22, 19, 'APT-00022', 'RHU III - Tinejero', 'General Consultation', '2026-07-29', '10:30 AM', 'regular', '', 'hello', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:39:54', '2026-07-28 12:39:54'),
(23, 21, 'APT-00023', 'RHU II - Cutcot', 'Vaccination', '2026-07-29', '08:30 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:41:05', '2026-07-28 12:41:05'),
(24, 22, 'APT-00024', 'RHU I - Poblacion', 'General Consultation', '2026-07-29', '09:00 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:41:09', '2026-07-28 12:41:09'),
(25, 23, 'APT-00025', 'RHU II - Cutcot', 'Child Immunization', '2026-07-29', '09:00 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:42:50', '2026-07-28 12:42:50'),
(26, 24, 'APT-00026', 'RHU I - Poblacion', 'Vaccination', '2026-07-29', '09:30 AM', 'regular', '', '', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:44:15', '2026-07-28 12:44:15'),
(27, 25, 'APT-00027', 'RHU II - Cutcot', 'Vaccination', '2026-07-29', '08:00 AM', 'priority', 'PWD', 'hello', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:44:23', '2026-07-28 12:44:23'),
(28, 8, 'APT-00028', 'RHU I - Poblacion', 'Vaccination', '2026-07-29', '10:00 AM', 'regular', '', 'Nakagat ni Jamilla', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 12:44:41', '2026-07-28 12:44:41'),
(29, 26, 'APT-00029', 'RHU I - Poblacion', 'Vaccination', '2026-07-29', '10:30 AM', 'regular', '', 'Nakagat ni Max', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 13:01:38', '2026-07-28 13:01:38'),
(30, 27, 'APT-00030', 'RHU I - Poblacion', 'Vaccination', '2026-07-29', '09:30 AM', 'regular', '', 'Nakagat ni Max', 'Confirmed', 'not_arrived', NULL, NULL, NULL, '2026-07-28 13:14:02', '2026-07-28 13:14:02');

-- --------------------------------------------------------

--
-- Table structure for table `appointment_queue_sequences`
--

CREATE TABLE `appointment_queue_sequences` (
  `branch` varchar(120) NOT NULL,
  `appointment_date` date NOT NULL,
  `prefix` char(1) NOT NULL,
  `next_number` int(11) NOT NULL DEFAULT 1,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `appointment_queue_sequences`
--

INSERT INTO `appointment_queue_sequences` (`branch`, `appointment_date`, `prefix`, `next_number`, `updated_at`) VALUES
('RHU I - Poblacion', '2026-07-21', 'A', 2, '2026-07-20 17:43:42'),
('RHU I - Poblacion', '2026-07-22', 'A', 2, '2026-07-21 16:32:35'),
('RHU I - Poblacion', '2026-07-25', 'A', 2, '2026-07-24 08:51:59'),
('RHU I - Poblacion', '2026-07-25', 'P', 2, '2026-07-24 08:45:10'),
('RHU I - Poblacion', '2026-07-27', 'A', 3, '2026-07-27 08:44:23'),
('RHU I - Poblacion', '2026-07-27', 'E', 2, '2026-07-27 08:39:00'),
('RHU I - Poblacion', '2026-07-28', 'A', 2, '2026-07-28 08:06:51'),
('RHU I - Poblacion', '2026-07-31', 'A', 2, '2026-07-24 08:27:46');

-- --------------------------------------------------------

--
-- Table structure for table `appointment_waitlist`
--

CREATE TABLE `appointment_waitlist` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `center` varchar(120) NOT NULL,
  `service` varchar(150) NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` varchar(20) NOT NULL,
  `status` enum('waiting','offered','accepted','declined','expired','cancelled') NOT NULL DEFAULT 'waiting',
  `offer_expires_at` datetime DEFAULT NULL,
  `recovered_appointment_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `audit_events`
--

CREATE TABLE `audit_events` (
  `id` int(11) NOT NULL,
  `user_name` varchar(150) NOT NULL DEFAULT 'Unknown',
  `email` varchar(150) DEFAULT NULL,
  `role` varchar(100) DEFAULT NULL,
  `branch` varchar(150) DEFAULT NULL,
  `module` varchar(100) NOT NULL DEFAULT 'System',
  `action` varchar(120) NOT NULL,
  `details` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `audit_events`
--

INSERT INTO `audit_events` (`id`, `user_name`, `email`, `role`, `branch`, `module`, `action`, `details`, `created_at`) VALUES
(1, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Page', 'Opened Dashboard page', '2026-07-13 16:02:40'),
(2, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Dashboard', 'Opened Dashboard page', '2026-07-13 16:02:41'),
(3, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Page', 'Opened Dashboard page', '2026-07-13 16:02:48'),
(4, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Dashboard', 'Opened Dashboard page', '2026-07-13 16:02:48'),
(5, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue', 'Viewed Page', 'Opened Queue page', '2026-07-13 16:02:56'),
(6, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue Management', 'Viewed Queue Management', 'Opened Queue Management page', '2026-07-13 16:02:56'),
(7, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Page', 'Opened Dashboard page', '2026-07-13 16:03:05'),
(8, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Dashboard', 'Opened Dashboard page', '2026-07-13 16:03:05'),
(9, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue', 'Viewed Page', 'Opened Queue page', '2026-07-13 16:03:07'),
(10, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue Management', 'Viewed Queue Management', 'Opened Queue Management page', '2026-07-13 16:03:07'),
(11, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Page', 'Opened Dashboard page', '2026-07-13 16:03:12'),
(12, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Dashboard', 'Opened Dashboard page', '2026-07-13 16:03:12'),
(13, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Appointments', 'Viewed Page', 'Opened Appointments page', '2026-07-13 16:03:19'),
(14, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Appointments', 'Viewed Appointments', 'Opened Appointments page', '2026-07-13 16:03:19'),
(15, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Backup & Restore', 'Viewed Backup & Restore', 'Opened Backup & Restore page', '2026-07-13 16:03:26'),
(16, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Backup & Restore', 'Viewed Page', 'Opened Backup & Restore page', '2026-07-13 16:03:26'),
(17, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'User Management', 'Viewed Page', 'Opened User Management page', '2026-07-13 16:03:27'),
(18, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Users & Staff', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', '2026-07-13 16:03:27'),
(19, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Users & Staff', 'Viewed User Management', 'Opened Users & Staff page', '2026-07-13 16:03:27'),
(20, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Page', 'Opened Dashboard page', '2026-07-13 16:05:11'),
(21, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Dashboard', 'Opened Dashboard page', '2026-07-13 16:05:11'),
(22, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Backup & Restore', 'Viewed Backup & Restore', 'Opened Backup & Restore page', '2026-07-13 16:05:12'),
(23, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Backup & Restore', 'Viewed Page', 'Opened Backup & Restore page', '2026-07-13 16:05:12'),
(24, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'User Management', 'Viewed Page', 'Opened User Management page', '2026-07-13 16:05:13'),
(25, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Users & Staff', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', '2026-07-13 16:05:13'),
(26, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Users & Staff', 'Viewed User Management', 'Opened Users & Staff page', '2026-07-13 16:05:13'),
(27, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Page', 'Opened Dashboard page', '2026-07-13 16:05:17'),
(28, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Dashboard', 'Viewed Dashboard', 'Opened Dashboard page', '2026-07-13 16:05:17'),
(29, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Appointments', 'Viewed Page', 'Opened Appointments page', '2026-07-13 16:06:10'),
(30, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Appointments', 'Viewed Appointments', 'Opened Appointments page', '2026-07-13 16:06:10'),
(31, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue', 'Viewed Page', 'Opened Queue page', '2026-07-13 16:06:12'),
(32, 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue Management', 'Viewed Queue Management', 'Opened Queue Management page', '2026-07-13 16:06:12');

-- --------------------------------------------------------

--
-- Table structure for table `audit_logs`
--

CREATE TABLE `audit_logs` (
  `id` int(11) NOT NULL,
  `user_type` varchar(30) NOT NULL,
  `user_name` varchar(120) NOT NULL,
  `email` varchar(150) DEFAULT NULL,
  `role` varchar(100) DEFAULT NULL,
  `branch` varchar(150) DEFAULT NULL,
  `action` varchar(150) NOT NULL,
  `details` text DEFAULT NULL,
  `module` varchar(80) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `audit_logs`
--

INSERT INTO `audit_logs` (`id`, `user_type`, `user_name`, `email`, `role`, `branch`, `action`, `details`, `module`, `created_at`) VALUES
(1, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-14 11:41:08'),
(2, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 11:41:29'),
(3, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 11:41:30'),
(4, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 11:41:34'),
(5, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-14 11:41:37'),
(6, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-14 11:41:53'),
(7, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 11:44:26'),
(8, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 11:45:41'),
(9, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 11:45:42'),
(10, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-14 11:45:43'),
(11, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-14 11:45:44'),
(12, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-14 11:45:46'),
(13, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-14 11:48:00'),
(14, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-14 11:48:00'),
(15, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 11:48:28'),
(16, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 11:54:40'),
(17, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-14 11:54:41'),
(18, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-14 11:54:49'),
(19, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-14 11:54:51'),
(20, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 11:55:01'),
(21, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 11:55:34'),
(22, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-14 11:58:03'),
(23, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-14 11:58:05'),
(24, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-14 11:58:10'),
(25, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-14 11:58:10'),
(26, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-14 11:58:12'),
(27, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-14 11:58:13'),
(28, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-14 11:58:16'),
(29, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 11:58:24'),
(30, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-14 12:00:50'),
(31, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:00:53'),
(32, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:09:13'),
(33, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:09:26'),
(34, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:09:29'),
(35, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:09:32'),
(36, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:09:38'),
(37, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:09:40'),
(38, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:10:15'),
(39, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:10:17'),
(40, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:10:18'),
(41, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:10:24'),
(42, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:10:34'),
(43, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-14 12:10:35'),
(44, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-14 12:10:56'),
(45, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-14 12:11:49'),
(46, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-14 12:12:15'),
(47, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:12:15'),
(48, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:12:33'),
(49, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:12:52'),
(50, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:12:53'),
(51, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:13:03'),
(52, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:13:04'),
(53, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:13:07'),
(54, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:13:10'),
(55, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:13:20'),
(56, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:13:27'),
(57, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:14:08'),
(58, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:14:10'),
(59, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:14:53'),
(60, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:14:55'),
(61, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:14:57'),
(62, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:14:59'),
(63, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:15:00'),
(64, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:15:01'),
(65, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:34:19'),
(66, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:34:19'),
(67, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:34:22'),
(68, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:34:28'),
(69, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:34:29'),
(70, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:34:48'),
(71, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:34:49'),
(72, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:34:52'),
(73, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:34:54'),
(74, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:34:56'),
(75, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:34:57'),
(76, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:38:28'),
(77, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:38:29'),
(78, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:38:31'),
(79, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:38:41'),
(80, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:38:43'),
(81, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:38:44'),
(82, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:38:46'),
(83, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:38:47'),
(84, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:42:47'),
(85, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:43:01'),
(86, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:43:02'),
(87, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:43:06'),
(88, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:43:10'),
(89, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:43:12'),
(90, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:43:14'),
(91, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:43:16'),
(92, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:43:18'),
(93, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:43:46'),
(94, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:44:22'),
(95, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 12:44:33'),
(96, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 12:44:46'),
(97, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:49:50'),
(98, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 12:49:57'),
(99, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 12:50:03'),
(100, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:14:52'),
(101, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:28:27'),
(102, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:28:31'),
(103, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:28:53'),
(104, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:29:04'),
(105, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:29:07'),
(106, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:29:23'),
(107, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:30:04'),
(108, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:30:12'),
(109, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 13:30:23'),
(110, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:30:45'),
(111, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:38:45'),
(112, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:38:47'),
(113, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:38:59'),
(114, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:39:04'),
(115, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:07'),
(116, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:39:08'),
(117, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:10'),
(118, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:11'),
(119, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:13'),
(120, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:14'),
(121, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:15'),
(122, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:15'),
(123, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:16'),
(124, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 13:39:19'),
(125, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:39:24'),
(126, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:39:41'),
(127, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:39:46'),
(128, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:39:50'),
(129, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 13:40:16'),
(130, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:40:17'),
(131, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:43:37'),
(132, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:43:50'),
(133, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:43:59'),
(134, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:44:01'),
(135, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:44:07'),
(136, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:44:15'),
(137, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:48:47'),
(138, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:48:58'),
(139, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:49:01'),
(140, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:49:10'),
(141, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 13:49:11'),
(142, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 13:56:23'),
(143, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 13:56:52'),
(144, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 13:57:06'),
(145, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 13:57:09'),
(146, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:05:34'),
(147, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:05:51'),
(148, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 14:05:54'),
(149, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:05:58'),
(150, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:06:03'),
(151, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:06:19'),
(152, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:06:26'),
(153, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:06:36'),
(154, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:19:14'),
(155, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:19:30'),
(156, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:19:32'),
(157, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:19:34'),
(158, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 14:19:36'),
(159, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:19:40'),
(160, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:20:00'),
(161, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:20:02'),
(162, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:20:07'),
(163, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 14:20:11'),
(164, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:20:16'),
(165, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:23:26'),
(166, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 14:23:27'),
(167, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:23:29'),
(168, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:44:11'),
(169, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:45:19'),
(170, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 14:45:20'),
(171, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:45:24'),
(172, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 14:45:25'),
(173, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 14:45:29'),
(174, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 14:45:32'),
(175, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Exported Appointments', 'Exported appointments CSV', 'Appointments', '2026-07-14 15:16:47'),
(176, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 15:28:23'),
(177, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 15:34:21'),
(178, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 15:34:28'),
(179, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 15:34:39'),
(180, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 15:34:40'),
(181, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 15:35:04'),
(182, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 16:09:07'),
(183, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 16:09:11'),
(184, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 16:09:13'),
(185, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 16:09:16'),
(186, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-14 16:09:21'),
(187, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-14 16:09:55'),
(188, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 16:09:55'),
(189, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 16:10:11'),
(190, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-14 16:10:15'),
(191, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-14 16:10:26'),
(192, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-14 16:10:29'),
(193, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-14 16:10:34'),
(194, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-14 16:10:38'),
(195, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-14 16:10:41'),
(196, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-14 16:10:41'),
(197, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-14 16:10:43'),
(198, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-14 16:10:47'),
(199, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-14 16:10:47'),
(200, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-14 16:10:48'),
(201, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-14 16:10:50'),
(202, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-14 16:10:51'),
(203, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-14 16:10:53'),
(204, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-20 11:49:47'),
(205, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 11:49:47'),
(206, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Replied to Patient Inquiry', 'Patient ID 2', 'Patient Inquiries', '2026-07-20 11:49:55'),
(207, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 11:50:34'),
(208, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 11:50:36'),
(209, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 11:50:37'),
(210, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 11:50:39'),
(211, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 11:53:45'),
(212, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 11:54:03'),
(213, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 11:54:04'),
(214, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:13:40'),
(215, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 12:13:41'),
(216, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:13:58'),
(217, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 12:14:00'),
(218, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 12:14:01'),
(219, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:14:02'),
(220, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 12:14:05'),
(221, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:15:08'),
(222, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:15:08'),
(223, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 12:15:09'),
(224, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:16:28'),
(225, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:35:40'),
(226, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:35:46'),
(227, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:35:50'),
(228, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 12:37:01'),
(229, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 12:37:05'),
(230, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-20 12:37:08'),
(231, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 12:37:08'),
(232, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-20 12:37:09'),
(233, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-20 12:37:10'),
(234, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 12:37:11'),
(235, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-20 12:37:12'),
(236, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-20 12:37:13'),
(237, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 12:37:15'),
(238, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:37:22'),
(239, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:37:23'),
(240, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 12:37:23'),
(241, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:37:33'),
(242, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:37:34'),
(243, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:37:35'),
(244, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 12:37:40'),
(245, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:37:45'),
(246, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 12:37:46'),
(247, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:52:05'),
(248, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 12:52:06'),
(249, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 12:52:15'),
(250, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 12:52:17'),
(251, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 12:52:20'),
(252, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 12:52:21'),
(253, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 13:05:24'),
(254, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 13:05:28'),
(255, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 13:05:32'),
(256, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 13:05:41'),
(257, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 13:05:49'),
(258, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-20 13:05:51'),
(259, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 13:05:51'),
(260, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 13:09:36'),
(261, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 13:09:39'),
(262, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 13:09:41'),
(263, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Removed Legacy Demo Accounts', '5 duplicate/demo account(s) removed.', 'Users & Staff', '2026-07-20 13:09:43'),
(264, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 13:09:43'),
(265, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-20 17:22:30'),
(266, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 17:22:31'),
(267, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 17:23:09'),
(268, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 17:23:11'),
(269, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 17:23:12'),
(270, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 17:23:37'),
(271, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-20 17:23:39'),
(272, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 17:23:45'),
(273, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 17:23:58'),
(274, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 17:24:03'),
(275, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 17:24:06'),
(276, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 17:24:40'),
(277, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-20 17:24:42'),
(278, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-20 17:24:44');
INSERT INTO `audit_logs` (`id`, `user_type`, `user_name`, `email`, `role`, `branch`, `action`, `details`, `module`, `created_at`) VALUES
(279, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-20 17:24:46'),
(280, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 17:25:47'),
(281, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 17:25:59'),
(282, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 17:44:00'),
(283, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 17:44:05'),
(284, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 17:44:14'),
(285, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 17:44:22'),
(286, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 17:44:22'),
(287, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 17:44:25'),
(288, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 17:44:26'),
(289, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 17:44:28'),
(290, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-20 17:44:29'),
(291, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-20 17:44:30'),
(292, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-20 17:44:31'),
(293, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 17:44:36'),
(294, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-20 17:44:40'),
(295, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 17:47:50'),
(296, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Replied to Patient Inquiry', 'Patient ID 2; RHU II - Cutcot', 'Patient Inquiries', '2026-07-20 17:50:23'),
(297, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-20 18:01:24'),
(298, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 18:01:25'),
(299, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:01:27'),
(300, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:01:54'),
(301, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 18:02:13'),
(302, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:02:22'),
(303, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 18:02:39'),
(304, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Patient Arrived', 'Queue A-001 marked arrived at RHU I - Poblacion.', 'Appointments', '2026-07-20 18:02:42'),
(305, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Patient Arrived', 'A-001 - Ashley Marcelo added to today\'s queue', 'Appointments', '2026-07-20 18:02:42'),
(306, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:02:47'),
(307, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 18:02:50'),
(308, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue Action', 'Action call_specific in RHU I - Poblacion; queue A-001', 'Queue Management', '2026-07-20 18:02:54'),
(309, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 18:02:54'),
(310, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:02:56'),
(311, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:03:10'),
(312, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 18:03:30'),
(313, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 18:03:33'),
(314, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 18:03:41'),
(315, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 18:03:47'),
(316, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 18:03:54'),
(317, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-20 18:04:09'),
(318, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-20 18:04:13'),
(319, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-20 18:04:16'),
(320, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-20 18:04:18'),
(321, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:04:26'),
(322, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:06:48'),
(323, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-20 18:06:53'),
(324, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 18:06:55'),
(325, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 18:06:57'),
(326, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-20 18:07:02'),
(327, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-20 18:07:03'),
(328, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:08:06'),
(329, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-20 18:29:02'),
(330, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-20 18:29:03'),
(331, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-20 18:29:35'),
(332, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-21 09:44:19'),
(333, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 09:44:19'),
(334, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 09:44:32'),
(335, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 09:44:38'),
(336, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 09:47:30'),
(337, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-21 15:59:39'),
(338, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 15:59:39'),
(339, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 15:59:49'),
(340, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 15:59:55'),
(341, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU IV - Tibag', 'Queue', '2026-07-21 15:59:59'),
(342, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:00:08'),
(343, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-21 16:00:19'),
(344, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-21 16:00:22'),
(345, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-21 16:00:28'),
(346, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-21 16:00:33'),
(347, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-21 16:00:35'),
(348, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-21 16:00:37'),
(349, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-21 16:00:39'),
(350, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:00:53'),
(351, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:00:56'),
(352, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:01:01'),
(353, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Logout', 'Admin logged out', 'Login', '2026-07-21 16:01:02'),
(354, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-21 16:01:03'),
(355, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:01:26'),
(356, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:01:27'),
(357, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:01:40'),
(358, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:01:48'),
(359, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:01:49'),
(360, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:01:51'),
(361, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:02:00'),
(362, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:02:00'),
(363, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:02:09'),
(364, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:02:09'),
(365, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:02:14'),
(366, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:02:16'),
(367, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-21 16:02:18'),
(368, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:02:25'),
(369, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:05:28'),
(370, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:05:29'),
(371, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:05:42'),
(372, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:05:42'),
(373, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:05:43'),
(374, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:12:17'),
(375, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:12:17'),
(376, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:12:34'),
(377, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:12:39'),
(378, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Queue Action', 'Action call_next in RHU I - Poblacion', 'Queue Management', '2026-07-21 16:12:43'),
(379, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:12:43'),
(380, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Queue Action', 'Action call_next in RHU I - Poblacion', 'Queue Management', '2026-07-21 16:12:45'),
(381, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:12:46'),
(382, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Queue Action', 'Action call_next in RHU I - Poblacion', 'Queue Management', '2026-07-21 16:12:46'),
(383, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:12:47'),
(384, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:12:51'),
(385, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:16:53'),
(386, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:16:53'),
(387, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:16:57'),
(388, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:16:58'),
(389, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:16:59'),
(390, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:17:49'),
(391, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:17:49'),
(392, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:18:03'),
(393, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:18:04'),
(394, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:18:09'),
(395, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:18:43'),
(396, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:18:43'),
(397, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:18:47'),
(398, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:18:48'),
(399, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:18:52'),
(400, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:18:55'),
(401, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:18:56'),
(402, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:19:04'),
(403, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:19:05'),
(404, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:22:22'),
(405, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:22:22'),
(406, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:22:26'),
(407, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:22:29'),
(408, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Queue Action', 'Action call_next in RHU I - Poblacion', 'Queue Management', '2026-07-21 16:22:30'),
(409, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:22:31'),
(410, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:22:33'),
(411, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:22:57'),
(412, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:22:57'),
(413, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:00'),
(414, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:01'),
(415, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:01'),
(416, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:02'),
(417, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:02'),
(418, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:03'),
(419, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:03'),
(420, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:04'),
(421, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:04'),
(422, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:05'),
(423, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:05'),
(424, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:06'),
(425, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:07'),
(426, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:23:11'),
(427, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:12'),
(428, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:23:13'),
(429, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:23:15'),
(430, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:23:17'),
(431, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:23:18'),
(432, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:23:20'),
(433, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:30:00'),
(434, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:30:37'),
(435, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:30:39'),
(436, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:30:40'),
(437, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:30:42'),
(438, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:33:16'),
(439, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:33:16'),
(440, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:33:23'),
(441, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:33:26'),
(442, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:33:27'),
(443, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:33:31'),
(444, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:33:34'),
(445, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:33:40'),
(446, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:33:42'),
(447, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:43:32'),
(448, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:43:33'),
(449, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:43:38'),
(450, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:43:40'),
(451, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:43:41'),
(452, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:43:43'),
(453, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:43:45'),
(454, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:43:52'),
(455, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:43:53'),
(456, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:43:56'),
(457, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:44:00'),
(458, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-21 16:44:37'),
(459, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-21 16:45:36'),
(460, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:45:36'),
(461, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:45:43'),
(462, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:45:45'),
(463, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:45:47'),
(464, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-21 16:45:51'),
(465, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-21 16:45:52'),
(466, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-21 16:45:54'),
(467, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-21 16:45:55'),
(468, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-21 16:45:56'),
(469, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-21 16:45:57'),
(470, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-21 16:45:58'),
(471, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-21 16:46:01'),
(472, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-21 16:52:58'),
(473, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:52:59'),
(474, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:53:04'),
(475, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:53:06'),
(476, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-21 16:53:07'),
(477, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-21 16:53:07'),
(478, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-21 16:53:09'),
(479, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-21 16:53:16'),
(480, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-22 00:56:13'),
(481, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-22 00:56:14'),
(482, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-22 00:56:16'),
(483, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-22 00:56:18'),
(484, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:18'),
(485, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:21'),
(486, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:22'),
(487, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:23'),
(488, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:24'),
(489, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:24'),
(490, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 00:56:25'),
(491, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-22 00:57:17'),
(492, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-22 01:05:22'),
(493, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-22 01:05:22'),
(494, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-22 01:05:26'),
(495, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-22 01:05:36'),
(496, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-22 01:05:36'),
(497, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-22 01:05:50'),
(498, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-22 01:05:51'),
(499, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 01:05:52'),
(500, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-22 01:05:58'),
(501, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-22 01:06:00'),
(502, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-22 01:06:02'),
(503, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-22 01:06:08'),
(504, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-22 01:06:13'),
(505, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-23 13:06:53'),
(506, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-23 13:06:54'),
(507, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-23 13:07:14'),
(508, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-23 13:07:20'),
(509, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-23 13:07:44'),
(510, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-23 13:08:06'),
(511, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-23 13:08:10'),
(512, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-23 13:08:12'),
(513, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-23 13:08:22'),
(514, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-23 13:08:25'),
(515, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-23 13:08:29'),
(516, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-23 13:19:19'),
(517, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-23 13:19:19'),
(518, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-23 13:19:21'),
(519, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-23 13:19:23'),
(520, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-23 13:19:24'),
(521, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-23 13:19:28'),
(522, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-23 13:19:31'),
(523, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-23 13:19:37'),
(524, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-23 13:19:39'),
(525, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-23 13:19:47'),
(526, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-23 13:31:36'),
(527, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-23 13:31:37'),
(528, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-23 13:31:58'),
(529, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-24 05:46:38'),
(530, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 05:46:38'),
(531, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 05:47:30'),
(532, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 05:48:17'),
(533, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 05:48:18'),
(534, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 05:48:25'),
(535, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 05:48:26'),
(536, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 05:48:30'),
(537, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 05:48:39'),
(538, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 05:48:47'),
(539, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 05:48:48'),
(540, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 05:48:53'),
(541, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 05:48:59'),
(542, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 05:49:02'),
(543, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-24 06:31:49'),
(544, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 06:31:50'),
(545, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 06:31:54'),
(546, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 06:31:55'),
(547, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 06:31:58'),
(548, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 06:32:15'),
(549, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 06:32:21'),
(550, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 06:32:25'),
(551, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 06:35:09'),
(552, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 06:55:34'),
(553, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 06:55:36'),
(554, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 06:55:36'),
(555, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 06:55:41');
INSERT INTO `audit_logs` (`id`, `user_type`, `user_name`, `email`, `role`, `branch`, `action`, `details`, `module`, `created_at`) VALUES
(556, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 06:55:45'),
(557, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 06:55:48'),
(558, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 06:55:52'),
(559, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 06:55:52'),
(560, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 06:58:23'),
(561, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:03:48'),
(562, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:04:33'),
(563, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:04:36'),
(564, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:07:13'),
(565, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:07:15'),
(566, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:09:58'),
(567, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 07:10:01'),
(568, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-24 07:10:03'),
(569, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 07:10:04'),
(570, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:10:08'),
(571, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:10:29'),
(572, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 07:10:33'),
(573, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 07:10:44'),
(574, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-24 07:10:47'),
(575, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:10:57'),
(576, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:17:08'),
(577, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:17:11'),
(578, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:17:14'),
(579, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:17:21'),
(580, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:17:21'),
(581, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:17:24'),
(582, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:17:25'),
(583, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:17:28'),
(584, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:17:31'),
(585, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:17:34'),
(586, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:17:36'),
(587, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:17:41'),
(588, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 07:17:44'),
(589, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 07:17:49'),
(590, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:17:50'),
(591, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 07:17:55'),
(592, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-24 07:17:58'),
(593, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:18:03'),
(594, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:18:05'),
(595, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 07:18:07'),
(596, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:18:09'),
(597, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 07:18:11'),
(598, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 07:18:17'),
(599, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:18:17'),
(600, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 07:18:19'),
(601, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:18:21'),
(602, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:18:26'),
(603, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:19:23'),
(604, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:20:49'),
(605, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:20:51'),
(606, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:20:55'),
(607, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:20:56'),
(608, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:20:56'),
(609, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:20:58'),
(610, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:21:00'),
(611, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:21:01'),
(612, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:21:08'),
(613, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Disease Trends & Case Heatmap', 'Disease Trends', '2026-07-24 07:21:10'),
(614, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:21:11'),
(615, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 07:21:17'),
(616, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:21'),
(617, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:39'),
(618, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:40'),
(619, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:40'),
(620, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:40'),
(621, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:41'),
(622, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:21:45'),
(623, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:21:48'),
(624, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 07:21:52'),
(625, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:21:54'),
(626, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:27:20'),
(627, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:27:21'),
(628, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:27:23'),
(629, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:27:24'),
(630, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:27:28'),
(631, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:27:40'),
(632, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:27:44'),
(633, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-24 07:27:47'),
(634, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:31:39'),
(635, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 07:32:33'),
(636, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-24 07:36:53'),
(637, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:36:54'),
(638, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:36:56'),
(639, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:36:57'),
(640, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:37:01'),
(641, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:37:02'),
(642, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:37:04'),
(643, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:37:06'),
(644, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:44:24'),
(645, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:44:25'),
(646, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 07:44:27'),
(647, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 07:44:28'),
(648, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 07:44:30'),
(649, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 07:44:36'),
(650, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-24 07:44:39'),
(651, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 07:44:41'),
(652, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 07:44:42'),
(653, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 07:44:43'),
(654, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-24 07:44:45'),
(655, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 07:44:49'),
(656, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-24 08:24:05'),
(657, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:24:06'),
(658, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:26:28'),
(659, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:28:06'),
(660, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:28:10'),
(661, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:28:15'),
(662, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:28:17'),
(663, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:29:24'),
(664, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 08:29:37'),
(665, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:29:50'),
(666, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 08:29:52'),
(667, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:29:53'),
(668, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 08:29:57'),
(669, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 08:30:00'),
(670, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 08:30:20'),
(671, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:30:25'),
(672, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 08:32:46'),
(673, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:37:25'),
(674, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 08:37:48'),
(675, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 08:37:53'),
(676, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:37:57'),
(677, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 08:40:13'),
(678, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 08:40:17'),
(679, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:40:19'),
(680, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:41:09'),
(681, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:41:11'),
(682, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:42:52'),
(683, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:45:39'),
(684, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:45:40'),
(685, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:47:17'),
(686, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:48:31'),
(687, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 08:48:59'),
(688, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:49:03'),
(689, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 08:49:15'),
(690, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:51:32'),
(691, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Replied to Patient Inquiry', 'Patient ID 8; RHU I - Poblacion', 'Patient Inquiries', '2026-07-24 08:52:15'),
(692, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 08:56:34'),
(693, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Replied to Patient Inquiry', 'Patient ID 11; RHU I - Poblacion', 'Patient Inquiries', '2026-07-24 08:56:50'),
(694, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-24 09:15:41'),
(695, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-24 17:11:05'),
(696, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 17:11:05'),
(697, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 17:11:31'),
(698, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:11:41'),
(699, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 17:11:44'),
(700, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:11:49'),
(701, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 17:11:52'),
(702, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:11:59'),
(703, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-24 17:12:01'),
(704, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:12:04'),
(705, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-24 17:12:24'),
(706, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-24 17:12:29'),
(707, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-24 17:12:31'),
(708, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-24 17:12:34'),
(709, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-24 17:12:42'),
(710, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 17:12:46'),
(711, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 17:12:51'),
(712, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Patient Arrived', 'Queue P-001 marked arrived at RHU I - Poblacion.', 'Appointments', '2026-07-24 17:12:55'),
(713, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Patient Arrived', 'P-001 - Angela Lauren added to today\'s queue', 'Appointments', '2026-07-24 17:12:55'),
(714, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 17:13:00'),
(715, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:13:03'),
(716, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue Action', 'Action call_specific in RHU I - Poblacion; queue P-001', 'Queue Management', '2026-07-24 17:13:07'),
(717, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:13:08'),
(718, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 17:13:25'),
(719, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:13:28'),
(720, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:13:30'),
(721, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:14:25'),
(722, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Queue Action', 'Action done in RHU I - Poblacion; queue P-001', 'Queue Management', '2026-07-24 17:14:30'),
(723, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:14:30'),
(724, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:14:33'),
(725, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:14:38'),
(726, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-24 17:14:44'),
(727, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-24 17:14:47'),
(728, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 17:14:48'),
(729, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:14:50'),
(730, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 17:14:56'),
(731, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 17:15:16'),
(732, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 17:15:32'),
(733, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-24 17:15:40'),
(734, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-24 17:15:52'),
(735, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:15:55'),
(736, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-24 17:15:58'),
(737, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-24 17:16:33'),
(738, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-24 17:27:11'),
(739, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-24 17:27:11'),
(740, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-25 14:45:04'),
(741, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-25 14:45:05'),
(742, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 14:45:11'),
(743, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-25 14:45:21'),
(744, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 14:45:34'),
(745, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-25 14:45:36'),
(746, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-25 14:45:39'),
(747, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 14:45:43'),
(748, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-25 14:45:47'),
(749, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-25 14:45:51'),
(750, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-25 14:45:53'),
(751, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 14:45:59'),
(752, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-25 14:47:14'),
(753, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-25 15:03:11'),
(754, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-25 15:44:05'),
(755, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-25 15:44:05'),
(756, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 15:44:08'),
(757, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 15:44:10'),
(758, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 15:44:11'),
(759, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 15:44:12'),
(760, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 15:44:12'),
(761, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-25 15:44:15'),
(762, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-25 15:44:17'),
(763, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-26 07:03:03'),
(764, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:03:03'),
(765, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:03:12'),
(766, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:03:16'),
(767, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 07:04:26'),
(768, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 07:04:32'),
(769, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:04:38'),
(770, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:04:51'),
(771, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:04:56'),
(772, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:05:00'),
(773, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:06:00'),
(774, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:06:07'),
(775, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:06:40'),
(776, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:06:46'),
(777, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 07:06:47'),
(778, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 07:06:49'),
(779, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:06:59'),
(780, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:07:02'),
(781, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 07:07:04'),
(782, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 07:07:07'),
(783, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:07:11'),
(784, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:07:19'),
(785, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:07:28'),
(786, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 07:07:30'),
(787, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 07:07:32'),
(788, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:07:38'),
(789, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 07:07:40'),
(790, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:07:43'),
(791, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:18:02'),
(792, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 07:19:10'),
(793, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 07:19:14'),
(794, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 07:19:16'),
(795, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 07:19:17'),
(796, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 07:19:25'),
(797, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 07:19:29'),
(798, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 07:19:34'),
(799, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 07:19:36'),
(800, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 07:19:39'),
(801, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-26 10:09:35'),
(802, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 10:09:36'),
(803, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 10:09:41'),
(804, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 10:09:43'),
(805, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 10:09:45'),
(806, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:09:51'),
(807, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:10:12'),
(808, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:23:52'),
(809, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:23:52'),
(810, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:23:56'),
(811, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:24:01');
INSERT INTO `audit_logs` (`id`, `user_type`, `user_name`, `email`, `role`, `branch`, `action`, `details`, `module`, `created_at`) VALUES
(812, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:29:33'),
(813, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:29:33'),
(814, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:29:37'),
(815, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:32:42'),
(816, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:33:22'),
(817, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:33:24'),
(818, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:33:43'),
(819, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:37:36'),
(820, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:37:41'),
(821, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:38:12'),
(822, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:48:59'),
(823, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 10:49:24'),
(824, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 10:49:32'),
(825, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 10:49:37'),
(826, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-26 10:49:40'),
(827, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 10:53:44'),
(828, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 10:53:48'),
(829, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:54:21'),
(830, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 10:54:31'),
(831, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:54:35'),
(832, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:54:36'),
(833, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:56:56'),
(834, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 10:57:00'),
(835, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 10:57:02'),
(836, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 10:57:05'),
(837, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 10:57:09'),
(838, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-26 10:59:41'),
(839, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 11:01:26'),
(840, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:01:30'),
(841, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:01:41'),
(842, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:01:46'),
(843, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:12:04'),
(844, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-26 11:17:41'),
(845, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:17:41'),
(846, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:17:51'),
(847, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 11:17:54'),
(848, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:17:56'),
(849, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 11:18:00'),
(850, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 11:18:06'),
(851, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 11:18:31'),
(852, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-26 11:18:56'),
(853, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-26 11:18:58'),
(854, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-26 11:19:00'),
(855, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-26 11:19:09'),
(856, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-26 11:19:12'),
(857, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-26 11:19:15'),
(858, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 11:19:38'),
(859, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-26 11:25:32'),
(860, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-26 11:25:42'),
(861, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:25:50'),
(862, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 11:25:54'),
(863, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:25:56'),
(864, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 11:25:58'),
(865, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-26 11:26:27'),
(866, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-26 11:31:45'),
(867, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-26 11:31:56'),
(868, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:31:57'),
(869, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 11:32:12'),
(870, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:32:16'),
(871, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 11:32:19'),
(872, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-26 11:32:22'),
(873, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 11:32:28'),
(874, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:32:33'),
(875, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 11:32:35'),
(876, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 11:32:38'),
(877, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:35:37'),
(878, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-26 11:35:48'),
(879, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-26 11:35:50'),
(880, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-26 11:36:15'),
(881, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 07:13:55'),
(882, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 07:13:55'),
(883, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 07:13:58'),
(884, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 07:14:01'),
(885, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 07:14:06'),
(886, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 07:14:07'),
(887, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 07:14:07'),
(888, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 07:15:19'),
(889, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 07:15:21'),
(890, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 07:15:22'),
(891, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 07:31:02'),
(892, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 08:10:43'),
(893, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:10:43'),
(894, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:10:45'),
(895, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:10:47'),
(896, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:11:17'),
(897, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 08:27:02'),
(898, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 08:31:57'),
(899, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:31:57'),
(900, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:32:05'),
(901, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:32:06'),
(902, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:33:54'),
(903, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:34:01'),
(904, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:34:05'),
(905, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:34:07'),
(906, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:34:38'),
(907, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:35:12'),
(908, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:35:35'),
(909, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:35:37'),
(910, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Added Emergency Walk-in', 'System Administrator added an emergency patient to Queue E-001 at RHU I - Poblacion; service General Consultation; reason: Vomiting.', 'Queue Management', '2026-07-27 08:39:01'),
(911, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Added Walk-in', 'Added emergency patient Bogart', 'Queue', '2026-07-27 08:39:01'),
(912, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Called Specific Queue', 'Queue E-001 called at RHU I - Poblacion; service General Consultation.', 'Queue Management', '2026-07-27 08:39:09'),
(913, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:39:10'),
(914, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Completed Queue', 'Queue E-001 at RHU I - Poblacion changed to Done.', 'Queue Management', '2026-07-27 08:39:26'),
(915, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:39:26'),
(916, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:39:28'),
(917, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:39:40'),
(918, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:39:43'),
(919, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:39:49'),
(920, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 08:39:55'),
(921, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 08:39:57'),
(922, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 08:40:00'),
(923, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 08:40:03'),
(924, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 08:40:04'),
(925, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:40:17'),
(926, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Archived Patient Record', 'Patient ID 12', 'Patients', '2026-07-27 08:40:22'),
(927, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 08:40:23'),
(928, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 08:40:37'),
(929, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:40:39'),
(930, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 08:40:50'),
(931, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 08:40:51'),
(932, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 08:41:04'),
(933, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 08:41:11'),
(934, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 08:41:14'),
(935, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 08:41:16'),
(936, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:42:07'),
(937, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:42:11'),
(938, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 08:42:18'),
(939, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 08:42:24'),
(940, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Created Backup', 'Exported operational, privacy, caregiver, communication, and core system tables', 'Backup & Restore', '2026-07-27 08:42:26'),
(941, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:43:00'),
(942, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:43:51'),
(943, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:44:03'),
(944, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:44:04'),
(945, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:44:09'),
(946, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:44:16'),
(947, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:44:18'),
(948, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:44:20'),
(949, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Checked In Patient', 'APT-00008 checked in at RHU I - Poblacion; live queue A-002 created.', 'Appointments', '2026-07-27 08:44:23'),
(950, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Patient Arrived', 'A-001 - Ashley Marcelo checked in as A-002', 'Appointments', '2026-07-27 08:44:23'),
(951, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:44:26'),
(952, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Called Specific Queue', 'Queue A-002 called at RHU I - Poblacion; service Vaccination.', 'Queue Management', '2026-07-27 08:44:31'),
(953, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:44:31'),
(954, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Opened TV Display', 'Opened read-only queue display for RHU I - Poblacion', 'Queue', '2026-07-27 08:44:34'),
(955, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:45:58'),
(956, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Called Next Queue', 'Queue A-002 called at RHU I - Poblacion; service Vaccination.', 'Queue Management', '2026-07-27 08:46:01'),
(957, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:46:01'),
(958, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Completed Queue', 'Queue A-002 at RHU I - Poblacion changed to Done.', 'Queue Management', '2026-07-27 08:46:07'),
(959, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:46:07'),
(960, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:46:09'),
(961, 'admin', 'Patient Portal', '', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Appointment APT-00010 requested for July 28, 2026 at RHU I - Poblacion; awaiting RHU approval.', 'Appointments', '2026-07-27 08:46:33'),
(962, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:46:46'),
(963, 'admin', 'Patient Portal', '', 'Patient', 'RHU III - Tinejero', 'Booked Appointment', 'Appointment APT-00011 requested for July 28, 2026 at RHU III - Tinejero; awaiting RHU approval.', 'Appointments', '2026-07-27 08:48:06'),
(964, 'admin', 'Patient Portal', '', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Appointment APT-00012 requested for July 28, 2026 at RHU I - Poblacion; awaiting RHU approval.', 'Appointments', '2026-07-27 08:48:15'),
(965, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:48:16'),
(966, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:48:26'),
(967, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:48:45'),
(968, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:48:50'),
(969, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:49:12'),
(970, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:49:17'),
(971, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:49:27'),
(972, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:50:00'),
(973, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:50:10'),
(974, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:51:52'),
(975, 'admin', 'Patient Portal', '', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Appointment APT-00013 requested for July 28, 2026 at RHU I - Poblacion; awaiting RHU approval.', 'Appointments', '2026-07-27 08:53:00'),
(976, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 08:53:47'),
(977, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 08:53:56'),
(978, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 08:54:09'),
(979, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 08:54:26'),
(980, 'admin', 'Patient Portal', '', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Appointment APT-00014 requested for July 28, 2026 at RHU I - Poblacion; awaiting RHU approval.', 'Appointments', '2026-07-27 08:56:09'),
(981, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 09:00:00'),
(982, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 09:00:07'),
(983, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 09:00:11'),
(984, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 09:00:22'),
(985, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 09:00:25'),
(986, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 09:00:26'),
(987, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 09:00:27'),
(988, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 09:00:30'),
(989, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 09:00:32'),
(990, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 09:00:38'),
(991, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 09:01:00'),
(992, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 09:01:04'),
(993, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 09:01:05'),
(994, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 09:01:08'),
(995, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 09:01:11'),
(996, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 09:01:16'),
(997, 'admin', 'Ashley Marcelo', 'ashleyamira04@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Ashley Marcelo booked Appointment APT-00015 for Vaccination on July 28, 2026 at 08:30 AM in RHU I - Poblacion; awaiting RHU approval.', 'Appointments', '2026-07-27 09:10:48'),
(998, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 09:11:22'),
(999, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Approved Appointment', 'System Administrator approved Appointment APT-00015 for Ashley Marcelo on July 28, 2026 at RHU I - Poblacion (previous status: Pending).', 'Appointments', '2026-07-27 09:11:31'),
(1000, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 09:32:02'),
(1001, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 10:29:04'),
(1002, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 10:29:04'),
(1003, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 10:29:24'),
(1004, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 10:29:29'),
(1005, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 10:29:56'),
(1006, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 10:29:57'),
(1007, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Replied to Patient Inquiry', 'Patient ID 8; RHU I - Poblacion', 'Patient Inquiries', '2026-07-27 10:30:15'),
(1008, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 10:30:17'),
(1009, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 10:30:27'),
(1010, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 10:30:35'),
(1011, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 10:30:41'),
(1012, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 10:31:07'),
(1013, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 10:31:08'),
(1014, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 10:31:25'),
(1015, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 10:31:28'),
(1016, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 10:31:36'),
(1017, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 10:47:02'),
(1018, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 13:39:46'),
(1019, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:39:46'),
(1020, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 13:40:21'),
(1021, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 13:40:25'),
(1022, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 13:41:29'),
(1023, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 13:41:55'),
(1024, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:41:57'),
(1025, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:47:11'),
(1026, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:47:17'),
(1027, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:59:00'),
(1028, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:59:04'),
(1029, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:59:04'),
(1030, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:59:10'),
(1031, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 13:59:16'),
(1032, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 13:59:23'),
(1033, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:00:23'),
(1034, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:00:35'),
(1035, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:00:37'),
(1036, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 14:00:50'),
(1037, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 14:01:56'),
(1038, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 14:01:58'),
(1039, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 14:02:00'),
(1040, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 14:02:03'),
(1041, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 14:06:58'),
(1042, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 14:07:04'),
(1043, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 14:07:05'),
(1044, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 14:07:06'),
(1045, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 14:07:07'),
(1046, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:07:11'),
(1047, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:07:16'),
(1048, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:08:47'),
(1049, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:12:09'),
(1050, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 14:12:13'),
(1051, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 14:12:15'),
(1052, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 14:12:26'),
(1053, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:12:30'),
(1054, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:17:11'),
(1055, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:17:15'),
(1056, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 14:17:18'),
(1057, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 14:17:22'),
(1058, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:17:28'),
(1059, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:17:57'),
(1060, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:18:46'),
(1061, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 14:34:01'),
(1062, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 14:45:28'),
(1063, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:45:29'),
(1064, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:45:39'),
(1065, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:45:54');
INSERT INTO `audit_logs` (`id`, `user_type`, `user_name`, `email`, `role`, `branch`, `action`, `details`, `module`, `created_at`) VALUES
(1066, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 14:46:02'),
(1067, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 14:46:19'),
(1068, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 14:46:38'),
(1069, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:46:38'),
(1070, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:46:43'),
(1071, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:46:47'),
(1072, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 14:46:53'),
(1073, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 14:47:11'),
(1074, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:47:11'),
(1075, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:47:17'),
(1076, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:47:22'),
(1077, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 14:47:24'),
(1078, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 14:47:32'),
(1079, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 14:47:40'),
(1080, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:47:40'),
(1081, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:47:46'),
(1082, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:47:47'),
(1083, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 14:47:51'),
(1084, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 14:47:57'),
(1085, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 14:57:12'),
(1086, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 14:57:12'),
(1087, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 14:57:17'),
(1088, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 14:57:20'),
(1089, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 14:57:24'),
(1090, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 14:57:31'),
(1091, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 15:25:27'),
(1092, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 15:25:27'),
(1093, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 15:25:31'),
(1094, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 15:25:40'),
(1095, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 15:25:45'),
(1096, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 15:25:49'),
(1097, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 15:25:52'),
(1098, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 15:25:54'),
(1099, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 15:25:56'),
(1100, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 15:25:58'),
(1101, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 15:26:00'),
(1102, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 15:26:01'),
(1103, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 15:26:05'),
(1104, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 15:26:09'),
(1105, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 15:31:19'),
(1106, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 15:31:21'),
(1107, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 15:31:43'),
(1108, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 15:31:44'),
(1109, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 15:31:54'),
(1110, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 15:38:14'),
(1111, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 15:54:05'),
(1112, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 16:00:01'),
(1113, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 16:00:01'),
(1114, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 16:00:10'),
(1115, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 16:00:12'),
(1116, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 16:00:14'),
(1117, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 16:00:20'),
(1118, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 16:00:24'),
(1119, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 16:00:26'),
(1120, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 16:00:29'),
(1121, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 16:00:31'),
(1122, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 16:00:37'),
(1123, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 16:00:43'),
(1124, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 16:03:52'),
(1125, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 16:19:04'),
(1126, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 17:05:04'),
(1127, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:05:04'),
(1128, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 17:06:31'),
(1129, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 17:06:36'),
(1130, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 17:06:42'),
(1131, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:06:53'),
(1132, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 17:09:57'),
(1133, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 17:15:01'),
(1134, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:15:07'),
(1135, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:19:11'),
(1136, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:25:21'),
(1137, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:26:07'),
(1138, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 17:26:14'),
(1139, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:26:17'),
(1140, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 17:26:33'),
(1141, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:26:35'),
(1142, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 17:26:42'),
(1143, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 17:26:45'),
(1144, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:26:46'),
(1145, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 17:27:15'),
(1146, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:27:27'),
(1147, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:27:28'),
(1148, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 17:29:18'),
(1149, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 17:29:22'),
(1150, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:29:24'),
(1151, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 17:29:26'),
(1152, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Exported Logs', 'Exported 500 log entries', 'Audit Trail', '2026-07-27 17:29:29'),
(1153, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:29:32'),
(1154, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 17:29:35'),
(1155, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 17:32:19'),
(1156, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:32:22'),
(1157, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:32:23'),
(1158, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:32:29'),
(1159, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 17:32:38'),
(1160, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 17:32:41'),
(1161, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:32:42'),
(1162, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 17:32:44'),
(1163, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:32:47'),
(1164, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 17:32:54'),
(1165, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 17:32:59'),
(1166, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 17:33:02'),
(1167, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-27 17:33:11'),
(1168, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:33:15'),
(1169, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Recorded Disease Case', 'Dengue in Cutcot (2026-07-16)', 'Disease Trends', '2026-07-27 17:36:12'),
(1170, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:36:14'),
(1171, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:53:58'),
(1172, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:54:31'),
(1173, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-27 17:54:59'),
(1174, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 17:55:03'),
(1175, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:55:05'),
(1176, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Backup & Restore page', 'Backup & Restore', '2026-07-27 17:55:07'),
(1177, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-27 17:55:10'),
(1178, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-27 17:55:12'),
(1179, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 17:55:15'),
(1180, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 17:55:35'),
(1181, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:55:37'),
(1182, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 17:55:51'),
(1183, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 17:56:05'),
(1184, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:56:06'),
(1185, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 17:56:11'),
(1186, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 17:56:14'),
(1187, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 17:56:16'),
(1188, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 17:56:23'),
(1189, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 17:58:29'),
(1190, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 17:58:31'),
(1191, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 18:04:14'),
(1192, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:04:17'),
(1193, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:04:20'),
(1194, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:04:23'),
(1195, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:04:24'),
(1196, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:04:27'),
(1197, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:09:21'),
(1198, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:09:25'),
(1199, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:09:27'),
(1200, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:09:29'),
(1201, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:09:31'),
(1202, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:09:34'),
(1203, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:14:18'),
(1204, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:14:21'),
(1205, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:14:33'),
(1206, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:14:37'),
(1207, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:14:41'),
(1208, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 18:14:47'),
(1209, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 18:14:49'),
(1210, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 18:14:51'),
(1211, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:14:58'),
(1212, 'admin', 'RHU I Staff', 'rhu1@pulilan.gov.ph', 'RHU Staff', 'RHU I - Poblacion', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 18:14:59'),
(1213, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 18:15:10'),
(1214, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:15:10'),
(1215, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:15:13'),
(1216, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:15:15'),
(1217, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:15:22'),
(1218, 'admin', 'RHU II Staff', 'rhu2@pulilan.gov.ph', 'RHU Staff', 'RHU II - Cutcot', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 18:15:23'),
(1219, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 18:15:31'),
(1220, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:15:31'),
(1221, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:15:40'),
(1222, 'admin', 'RHU III Staff', 'rhu3@pulilan.gov.ph', 'RHU Staff', 'RHU III - Tinejero', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 18:15:43'),
(1223, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Staff Login', 'Successful RHU staff sign-in.', 'Authentication', '2026-07-27 18:15:50'),
(1224, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:15:50'),
(1225, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:15:53'),
(1226, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 18:15:54'),
(1227, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Opened TV Display', 'Opened read-only queue display for RHU IV - Tibag', 'Queue', '2026-07-27 18:15:57'),
(1228, 'admin', 'RHU IV Staff', 'rhu4@pulilan.gov.ph', 'RHU Staff', 'RHU IV - Tibag', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 18:16:00'),
(1229, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-27 18:16:29'),
(1230, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-27 18:16:29'),
(1231, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-27 18:16:34'),
(1232, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-27 18:16:36'),
(1233, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-27 18:16:37'),
(1234, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-27 18:16:41'),
(1235, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-27 18:16:44'),
(1236, 'admin', 'Esmeralda Fatima', 'ef6139789@gmail.com', 'Patient', 'RHU IV - Tibag', 'Booked Appointment', 'Esmeralda Fatima booked Appointment APT-00016 for Family Planning on July 30, 2026 at 09:30 AM in RHU IV - Tibag; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 05:50:46'),
(1237, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-28 05:53:15'),
(1238, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 05:53:16'),
(1239, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-28 05:53:21'),
(1240, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-28 06:12:13'),
(1241, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-28 06:28:40'),
(1242, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 06:28:40'),
(1243, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-28 06:28:44'),
(1244, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 06:28:47'),
(1245, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-28 06:28:50'),
(1246, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-28 06:29:05'),
(1247, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-28 06:29:10'),
(1248, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-28 06:29:14'),
(1249, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-28 06:29:16'),
(1250, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-28 06:29:19'),
(1251, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Updated Announcement', 'Announcement ID 1', 'Announcements', '2026-07-28 06:38:06'),
(1252, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Updated Announcement', 'Announcement ID 1', 'Announcements', '2026-07-28 06:51:46'),
(1253, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-28 07:09:01'),
(1254, 'admin', 'rencel marcelo', 'printingbuss@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'rencel marcelo booked Appointment APT-00017 for Vaccination on July 29, 2026 at 08:00 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 08:01:49'),
(1255, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-28 08:03:01'),
(1256, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 08:03:02'),
(1257, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 08:03:40'),
(1258, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 08:03:41'),
(1259, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-28 08:03:52'),
(1260, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 08:06:23'),
(1261, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-28 08:06:25'),
(1262, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 08:06:31'),
(1263, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-28 08:06:36'),
(1264, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-28 08:06:43'),
(1265, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Checked In Patient', 'Ashley Marcelo checked in for APT-00015 at RHU I - Poblacion; live queue A-001 created.', 'Appointments', '2026-07-28 08:06:51'),
(1266, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 08:06:53'),
(1267, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 08:06:54'),
(1268, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Called Next Queue', 'Queue A-001 for Ashley Marcelo called at RHU I - Poblacion; service Vaccination.', 'Queue Management', '2026-07-28 08:06:59'),
(1269, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 08:07:00'),
(1270, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Completed Queue', 'Queue A-001 for Ashley Marcelo at RHU I - Poblacion changed to Done.', 'Queue Management', '2026-07-28 08:08:13'),
(1271, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 08:08:13'),
(1272, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-28 08:08:36'),
(1273, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 08:08:38'),
(1274, 'admin', 'Ashley Marcelo', 'ashleyamira04@gmail.com', 'Patient', 'RHU III - Tinejero', 'Booked Appointment', 'Ashley Marcelo booked Appointment APT-00018 for Vaccination on July 29, 2026 at 08:00 AM in RHU III - Tinejero; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 08:09:25'),
(1275, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-28 12:11:06'),
(1276, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 12:11:06'),
(1277, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Archive page', 'Archive', '2026-07-28 12:11:10'),
(1278, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-28 12:11:11'),
(1279, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Heatmap & Analytics', 'Heatmap & Analytics', '2026-07-28 12:11:19'),
(1280, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened User Management page', 'User Management', '2026-07-28 12:11:27'),
(1281, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Audit Trail page', 'Audit Trail', '2026-07-28 12:11:28'),
(1282, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Patients page', 'Patients', '2026-07-28 12:11:33'),
(1283, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Appointments page', 'Appointments', '2026-07-28 12:11:37'),
(1284, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 12:11:39'),
(1285, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Login', 'Successful password and OTP sign-in.', 'Authentication', '2026-07-28 12:13:49'),
(1286, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Dashboard page', 'Dashboard', '2026-07-28 12:13:51'),
(1287, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Reports page', 'Reports', '2026-07-28 12:14:18'),
(1288, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Viewed Page', 'Opened Queue page', 'Queue', '2026-07-28 12:14:24'),
(1289, 'admin', 'System Administrator', 'pulilanhealthcenteradmin@gmail.com', 'System Administrator', 'All Branches', 'Admin Logout', 'Administrator signed out.', 'Authentication', '2026-07-28 12:27:54'),
(1290, 'admin', 'Nielyia Dela Cruz', '', 'Patient', 'RHU I - Poblacion', 'Patient Cancelled Appointment', 'Nielyia Dela Cruz cancelled Appointment APT-00010 for General Consultation at RHU I - Poblacion.', 'Appointments', '2026-07-28 12:37:21'),
(1291, 'admin', 'Dave Cruz', '', 'Patient', 'RHU I - Poblacion', 'Patient Cancelled Appointment', 'Dave Cruz cancelled Appointment APT-00012 for Vaccination at RHU I - Poblacion.', 'Appointments', '2026-07-28 12:37:21'),
(1292, 'admin', 'Dave Cruz', 'cruzdave465@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Dave Cruz booked Appointment APT-00019 for Vaccination on July 29, 2026 at 08:30 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:37:36'),
(1293, 'admin', 'Nielyia Dela Cruz', 'nielyiadelacruz@gmail.com', 'Patient', 'RHU II - Cutcot', 'Booked Appointment', 'Nielyia Dela Cruz booked Appointment APT-00020 for General Consultation on July 29, 2026 at 08:00 AM in RHU II - Cutcot; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:37:50'),
(1294, 'admin', 'Charish Artiaga', 'artiagacharish042304@gmail.com', 'Patient', 'RHU III - Tinejero', 'Booked Appointment', 'Charish Artiaga booked Appointment APT-00021 for Child Immunization on July 31, 2026 at 11:00 AM in RHU III - Tinejero; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:39:47'),
(1295, 'admin', 'Dino Usman', 'usmandinoaivan@gmail.com', 'Patient', 'RHU III - Tinejero', 'Booked Appointment', 'Dino Usman booked Appointment APT-00022 for General Consultation on July 29, 2026 at 10:30 AM in RHU III - Tinejero; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:39:54'),
(1296, 'admin', 'Nielyia Dela Cruz 2', '1ndonlyaelia@gmail.com', 'Patient', 'RHU II - Cutcot', 'Booked Appointment', 'Nielyia Dela Cruz 2 booked Appointment APT-00023 for Vaccination on July 29, 2026 at 08:30 AM in RHU II - Cutcot; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:41:06'),
(1297, 'admin', 'Dave Cruz', 'dvcrz0803@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Dave Cruz booked Appointment APT-00024 for General Consultation on July 29, 2026 at 09:00 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:41:09'),
(1298, 'admin', 'Neli 3', 'neligarciadc29@gmail.com', 'Patient', 'RHU II - Cutcot', 'Booked Appointment', 'Neli 3 booked Appointment APT-00025 for Child Immunization on July 29, 2026 at 09:00 AM in RHU II - Cutcot; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:42:51'),
(1299, 'admin', 'Rommel Marcelo', '', 'Patient', 'RHU I - Poblacion', 'Patient Cancelled Appointment', 'Rommel Marcelo cancelled Appointment APT-00014 for Vaccination at RHU I - Poblacion.', 'Appointments', '2026-07-28 12:44:08'),
(1300, 'admin', 'Dayniel Cruz', 'daynielcruz07@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Dayniel Cruz booked Appointment APT-00026 for Vaccination on July 29, 2026 at 09:30 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:44:15'),
(1301, 'admin', 'Shai Giban', 'shushameow@gmail.com', 'Patient', 'RHU II - Cutcot', 'Booked Appointment', 'Shai Giban booked Appointment APT-00027 for Vaccination on July 29, 2026 at 08:00 AM in RHU II - Cutcot; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:44:24'),
(1302, 'admin', 'Rommel Marcelo', 'rommelmarcelojr@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Rommel Marcelo booked Appointment APT-00028 for Vaccination on July 29, 2026 at 10:00 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 12:44:42'),
(1303, 'admin', 'Maro Delos Santos', 'rommelde07@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'Maro Delos Santos booked Appointment APT-00029 for Vaccination on July 29, 2026 at 10:30 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 13:01:39'),
(1304, 'admin', 'maro jr marcelo', 'maromarcelo431@gmail.com', 'Patient', 'RHU I - Poblacion', 'Booked Appointment', 'maro jr marcelo booked Appointment APT-00030 for Vaccination on July 29, 2026 at 09:30 AM in RHU I - Poblacion; automatically confirmed and added to the RHU schedule.', 'Appointments', '2026-07-28 13:14:03');

-- --------------------------------------------------------

--
-- Table structure for table `booking_slot_locks`
--

CREATE TABLE `booking_slot_locks` (
  `branch` varchar(120) NOT NULL,
  `service` varchar(120) NOT NULL,
  `appointment_date` date NOT NULL,
  `appointment_time` varchar(30) NOT NULL,
  `touched_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `booking_slot_locks`
--

INSERT INTO `booking_slot_locks` (`branch`, `service`, `appointment_date`, `appointment_time`, `touched_at`) VALUES
('RHU I - Poblacion', 'General Consultation', '2026-07-28', '04:30 PM', '2026-07-27 08:46:33'),
('RHU I - Poblacion', 'General Consultation', '2026-07-29', '09:00 AM', '2026-07-28 12:41:09'),
('RHU I - Poblacion', 'Prenatal Care', '2026-07-25', '08:00 AM', '2026-07-24 08:45:10'),
('RHU I - Poblacion', 'Prenatal Care', '2026-07-28', '04:30 PM', '2026-07-27 08:53:00'),
('RHU I - Poblacion', 'Vaccination', '2026-07-21', '09:30 AM', '2026-07-20 17:43:42'),
('RHU I - Poblacion', 'Vaccination', '2026-07-22', '08:00 AM', '2026-07-21 16:32:35'),
('RHU I - Poblacion', 'Vaccination', '2026-07-25', '08:00 AM', '2026-07-24 08:51:59'),
('RHU I - Poblacion', 'Vaccination', '2026-07-27', '08:30 AM', '2026-07-26 07:06:23'),
('RHU I - Poblacion', 'Vaccination', '2026-07-28', '04:30 PM', '2026-07-27 08:56:09'),
('RHU I - Poblacion', 'Vaccination', '2026-07-28', '08:30 AM', '2026-07-27 09:10:47'),
('RHU I - Poblacion', 'Vaccination', '2026-07-29', '08:00 AM', '2026-07-28 08:01:49'),
('RHU I - Poblacion', 'Vaccination', '2026-07-29', '08:30 AM', '2026-07-28 12:37:35'),
('RHU I - Poblacion', 'Vaccination', '2026-07-29', '09:30 AM', '2026-07-28 13:14:02'),
('RHU I - Poblacion', 'Vaccination', '2026-07-29', '10:00 AM', '2026-07-28 12:44:41'),
('RHU I - Poblacion', 'Vaccination', '2026-07-29', '10:30 AM', '2026-07-28 13:01:38'),
('RHU I - Poblacion', 'Vaccination', '2026-07-31', '10:00 AM', '2026-07-24 08:27:46'),
('RHU II - Cutcot', 'Child Immunization', '2026-07-29', '09:00 AM', '2026-07-28 12:42:50'),
('RHU II - Cutcot', 'General Consultation', '2026-07-29', '08:00 AM', '2026-07-28 12:37:49'),
('RHU II - Cutcot', 'Vaccination', '2026-07-29', '08:00 AM', '2026-07-28 12:44:23'),
('RHU II - Cutcot', 'Vaccination', '2026-07-29', '08:30 AM', '2026-07-28 12:41:05'),
('RHU III - Tinejero', 'Child Immunization', '2026-07-31', '11:00 AM', '2026-07-28 12:39:46'),
('RHU III - Tinejero', 'General Consultation', '2026-07-28', '04:30 PM', '2026-07-27 08:48:05'),
('RHU III - Tinejero', 'General Consultation', '2026-07-29', '10:30 AM', '2026-07-28 12:39:54'),
('RHU III - Tinejero', 'Vaccination', '2026-07-29', '08:00 AM', '2026-07-28 08:09:24'),
('RHU IV - Tibag', 'Family Planning', '2026-07-30', '09:30 AM', '2026-07-28 05:50:45');

-- --------------------------------------------------------

--
-- Table structure for table `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `admin_id` int(11) DEFAULT NULL,
  `sender_type` enum('patient','admin') NOT NULL,
  `message` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `is_automated` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `patient_id`, `admin_id`, `sender_type`, `message`, `is_read`, `is_automated`, `created_at`) VALUES
(1, 2, NULL, 'patient', 'dada', 1, 0, '2026-07-13 13:55:19'),
(2, 2, NULL, 'patient', 'ddadad', 1, 0, '2026-07-20 11:48:33'),
(3, 2, 1, 'admin', 'hi', 1, 0, '2026-07-20 11:49:55'),
(4, 2, NULL, 'patient', 'HI', 1, 0, '2026-07-20 17:28:28'),
(5, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: We received your message and routed it to the selected RHU. Please include the service, appointment date, and queue number when applicable. This is an automated acknowledgement; an authorized staff member can still reply in this same conversation.', 1, 1, '2026-07-20 17:28:28'),
(6, 2, NULL, 'patient', 'WHAT TIME IS IT', 1, 0, '2026-07-20 17:28:40'),
(7, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: We received your message and routed it to the selected RHU. Please include the service, appointment date, and queue number when applicable. This is an automated acknowledgement; an authorized staff member can still reply in this same conversation.', 1, 1, '2026-07-20 17:28:40'),
(8, 2, NULL, 'patient', 'HI', 1, 0, '2026-07-20 17:49:21'),
(9, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: We received your message and routed it to the selected RHU. Please include the service, appointment date, and queue number when applicable. This is an automated acknowledgement; an authorized staff member can still reply in this same conversation.', 1, 1, '2026-07-20 17:49:21'),
(10, 2, NULL, 'patient', 'MY SCHED', 1, 0, '2026-07-20 17:49:27'),
(11, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: We received your message and routed it to the selected RHU. Please include the service, appointment date, and queue number when applicable. This is an automated acknowledgement; an authorized staff member can still reply in this same conversation.', 1, 1, '2026-07-20 17:49:27'),
(12, 2, NULL, 'patient', 'SCHEDULE', 1, 0, '2026-07-20 17:49:37'),
(13, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: For appointments, open Book Appointment or My Appointments. Include the patient name, preferred date, service, and concern so RHU staff can assist. Changes are confirmed only when reflected in My Appointments.', 1, 1, '2026-07-20 17:49:37'),
(14, 2, NULL, 'patient', 'PREFFERED DATE', 1, 0, '2026-07-20 17:49:51'),
(15, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: We received your message and routed it to the selected RHU. Please include the service, appointment date, and queue number when applicable. This is an automated acknowledgement; an authorized staff member can still reply in this same conversation.', 1, 1, '2026-07-20 17:49:51'),
(16, 2, 1, 'admin', 'HI', 1, 0, '2026-07-20 17:50:23'),
(17, 2, NULL, 'patient', 'dad', 1, 0, '2026-07-20 18:29:09'),
(18, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-20 18:29:09'),
(19, 2, NULL, 'patient', 'PREPPERED TIME', 1, 0, '2026-07-20 18:29:20'),
(20, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-20 18:29:20'),
(21, 2, NULL, 'patient', 'dad', 1, 0, '2026-07-21 10:01:40'),
(22, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-21 10:01:40'),
(23, 2, NULL, 'patient', 'time', 1, 0, '2026-07-21 10:01:45'),
(24, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-21 10:01:45'),
(25, 2, NULL, 'patient', 'hi', 1, 0, '2026-07-21 10:01:57'),
(26, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.', 1, 1, '2026-07-21 10:01:57'),
(27, 2, NULL, 'patient', 'Preferred date”', 1, 0, '2026-07-21 10:02:23'),
(28, 2, NULL, 'admin', 'Automated available-date check for RHU II - Cutcot: The next clinic days are Wed, Jul 22 (8:00 AM–5:00 PM; break 12:00 PM–1:00 PM); Thu, Jul 23 (8:00 AM–5:00 PM; break 12:00 PM–1:00 PM); Fri, Jul 24 (8:00 AM–5:00 PM; break 12:00 PM–1:00 PM). Choose your service and one of these dates in Book Appointment to see the exact remaining time slots. Sending a preferred date in chat does not create a booking.', 1, 1, '2026-07-21 10:02:23'),
(29, 2, NULL, 'patient', 'Ano ang requirements?', 1, 0, '2026-07-21 10:27:45'),
(30, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: Please bring a valid ID and your appointment QR. Requirements can vary by service, so tell us which service you selected and RHU staff will confirm any additional records or documents.', 1, 1, '2026-07-21 10:27:45'),
(31, 2, NULL, 'patient', 'Kailan bukas ang RHU?', 1, 0, '2026-07-21 12:26:39'),
(32, 2, NULL, 'admin', 'Automated clinic hours for RHU II - Cutcot: Monday, Tuesday, Wednesday, Thursday, Friday: 8:00 AM–5:00 PM; break 12:00 PM–1:00 PM; Saturday: 8:00 AM–12:00 PM; Sunday: Closed. Service-specific available slots are shown live in Book Appointment.', 1, 1, '2026-07-21 12:26:39'),
(33, 2, NULL, 'patient', 'Kailan bukas ang RHU?', 1, 0, '2026-07-21 12:26:45'),
(34, 2, NULL, 'admin', 'Automated clinic hours for RHU II - Cutcot: Monday, Tuesday, Wednesday, Thursday, Friday: 8:00 AM–5:00 PM; break 12:00 PM–1:00 PM; Saturday: 8:00 AM–12:00 PM; Sunday: Closed. Service-specific available slots are shown live in Book Appointment.', 1, 1, '2026-07-21 12:26:45'),
(35, 2, NULL, 'patient', 'Ano ang queue status ko?', 1, 0, '2026-07-21 12:26:51'),
(36, 2, NULL, 'admin', 'Automated guidance for RHU II - Cutcot: Open Queue Status for the live queue number and estimated wait. If you are already at the RHU, present your QR to staff. You will also receive an alert when three or fewer patients are ahead.', 1, 1, '2026-07-21 12:26:51'),
(37, 2, NULL, 'patient', 'Kailan ang appointment ko?', 1, 0, '2026-07-21 12:41:10'),
(38, 2, NULL, 'admin', 'Automated appointment check: Your next appointment is Vaccination on Tuesday, July 21, 2026 at 9:30 AM, RHU I - Poblacion. Queue number: A-001. Status: Serving.', 1, 1, '2026-07-21 12:41:10'),
(39, 8, NULL, 'patient', 'Hello po. Testing', 1, 0, '2026-07-24 08:50:02'),
(40, 8, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.', 1, 1, '2026-07-24 08:50:02'),
(41, 8, NULL, 'patient', 'Kailan ang appointment ko?', 1, 0, '2026-07-24 08:50:33'),
(42, 8, NULL, 'admin', 'Automated appointment check: Your next appointment is Vaccination on Friday, July 31, 2026 at 10:00 AM, RHU I - Poblacion. Queue number: A-001. Status: Confirmed.', 1, 1, '2026-07-24 08:50:33'),
(43, 8, 1, 'admin', 'ewan q sayo', 1, 0, '2026-07-24 08:52:15'),
(44, 11, NULL, 'patient', 'hi', 1, 0, '2026-07-24 08:56:35'),
(45, 11, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.', 1, 1, '2026-07-24 08:56:35'),
(46, 11, NULL, 'patient', 'ako pa rin ba?', 1, 0, '2026-07-24 08:56:46'),
(47, 11, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-24 08:56:46'),
(48, 11, 1, 'admin', 'sino ka', 1, 0, '2026-07-24 08:56:50'),
(49, 11, NULL, 'patient', 'Ano ang queue status ko?', 1, 0, '2026-07-24 08:56:56'),
(50, 11, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: Open Queue Status for the live queue number and estimated wait. If you are already at the RHU, present your QR to staff. You will also receive an alert when three or fewer patients are ahead.', 1, 1, '2026-07-24 08:56:56'),
(51, 11, NULL, 'patient', 'buntis ako', 1, 0, '2026-07-24 08:57:37'),
(52, 11, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-24 08:57:37'),
(53, 11, NULL, 'patient', 'bye', 1, 0, '2026-07-24 08:57:57'),
(54, 11, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-24 08:57:57'),
(55, 11, NULL, 'patient', 'bye', 1, 0, '2026-07-24 08:58:01'),
(56, 11, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-24 08:58:01'),
(57, 8, 2, 'admin', 'hiiiiiiiiiiii', 1, 0, '2026-07-26 11:35:27'),
(58, 8, NULL, 'patient', 'Hello po', 1, 0, '2026-07-27 09:04:00'),
(59, 8, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.', 1, 1, '2026-07-27 09:04:00'),
(60, 8, 1, 'admin', 'tite', 1, 0, '2026-07-27 10:30:15'),
(61, 8, NULL, 'patient', 'hala kaaa', 1, 0, '2026-07-27 11:10:40'),
(62, 8, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-27 11:10:40'),
(63, 8, NULL, 'patient', 'good to be back to this acc :(( namiss ko patient acc na ito', 0, 0, '2026-07-28 12:42:19'),
(64, 8, NULL, 'admin', 'Automated guidance for RHU I - Poblacion: Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.', 1, 1, '2026-07-28 12:42:19'),
(65, 25, NULL, 'patient', 'Hello', 0, 0, '2026-07-28 12:46:20'),
(66, 25, NULL, 'admin', 'Automated guidance for RHU III - Tinejero: Hello! I can instantly check your appointment, queue number, clinic hours, and next open clinic dates. Try “Kailan schedule ko?”, “Kailan bukas ang RHU?”, “Preferred date”, or “Ano queue number ko?”.', 1, 1, '2026-07-28 12:46:20'),
(67, 25, NULL, 'patient', 'Mayproblem po sa account ko', 0, 0, '2026-07-28 13:57:54'),
(68, 25, NULL, 'admin', 'Automated guidance for RHU III - Tinejero: I could not identify a specific question yet. Ask about your appointment, queue number, clinic hours, next open dates, requirements, QR arrival, or vaccination. Your message was also routed to RHU staff.', 1, 1, '2026-07-28 13:57:54');

-- --------------------------------------------------------

--
-- Table structure for table `chat_thread_status`
--

CREATE TABLE `chat_thread_status` (
  `patient_id` int(11) NOT NULL,
  `status` enum('Open','Waiting for Patient','Resolved') NOT NULL DEFAULT 'Open',
  `rhu_branch` varchar(150) DEFAULT NULL,
  `assigned_admin_id` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `chat_thread_status`
--

INSERT INTO `chat_thread_status` (`patient_id`, `status`, `rhu_branch`, `assigned_admin_id`, `updated_at`) VALUES
(2, 'Open', 'RHU II - Cutcot', NULL, '2026-07-21 12:41:10'),
(8, 'Open', 'RHU I - Poblacion', NULL, '2026-07-28 12:42:19'),
(11, 'Open', 'RHU I - Poblacion', 2, '2026-07-26 11:35:09'),
(25, 'Open', 'RHU III - Tinejero', NULL, '2026-07-28 13:57:54');

-- --------------------------------------------------------

--
-- Table structure for table `clinic_capacity_rules`
--

CREATE TABLE `clinic_capacity_rules` (
  `id` int(11) NOT NULL,
  `branch` varchar(120) NOT NULL,
  `service` varchar(120) NOT NULL DEFAULT 'All Services',
  `capacity_per_slot` smallint(6) NOT NULL DEFAULT 25,
  `daily_capacity` smallint(6) NOT NULL DEFAULT 200,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clinic_capacity_rules`
--

INSERT INTO `clinic_capacity_rules` (`id`, `branch`, `service`, `capacity_per_slot`, `daily_capacity`, `updated_by`, `updated_at`) VALUES
(1, 'RHU I - Poblacion', 'All Services', 25, 200, NULL, '2026-07-20 15:07:14'),
(2, 'RHU II - Cutcot', 'All Services', 25, 200, NULL, '2026-07-20 15:07:14'),
(3, 'RHU III - Tinejero', 'All Services', 25, 200, NULL, '2026-07-20 15:07:14'),
(4, 'RHU IV - Tibag', 'All Services', 25, 200, NULL, '2026-07-20 15:07:14');

-- --------------------------------------------------------

--
-- Table structure for table `clinic_closures`
--

CREATE TABLE `clinic_closures` (
  `id` int(11) NOT NULL,
  `branch` varchar(120) NOT NULL DEFAULT 'All Branches',
  `service` varchar(120) NOT NULL DEFAULT 'All Services',
  `closure_date` date NOT NULL,
  `closure_type` enum('Holiday','Emergency','Maintenance','Special Event') NOT NULL DEFAULT 'Holiday',
  `title` varchar(160) NOT NULL,
  `details` text DEFAULT NULL,
  `closed_all_day` tinyint(1) NOT NULL DEFAULT 1,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `status` enum('Active','Cancelled') NOT NULL DEFAULT 'Active',
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `clinic_schedules`
--

CREATE TABLE `clinic_schedules` (
  `id` int(11) NOT NULL,
  `branch` varchar(120) NOT NULL,
  `day_of_week` tinyint(4) NOT NULL,
  `is_open` tinyint(1) NOT NULL DEFAULT 1,
  `open_time` time DEFAULT NULL,
  `close_time` time DEFAULT NULL,
  `break_start` time DEFAULT NULL,
  `break_end` time DEFAULT NULL,
  `slot_interval_minutes` smallint(6) NOT NULL DEFAULT 30,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `clinic_schedules`
--

INSERT INTO `clinic_schedules` (`id`, `branch`, `day_of_week`, `is_open`, `open_time`, `close_time`, `break_start`, `break_end`, `slot_interval_minutes`, `updated_by`, `updated_at`) VALUES
(1, 'RHU I - Poblacion', 0, 0, NULL, NULL, NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(2, 'RHU I - Poblacion', 1, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(3, 'RHU I - Poblacion', 2, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(4, 'RHU I - Poblacion', 3, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(5, 'RHU I - Poblacion', 4, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(6, 'RHU I - Poblacion', 5, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(7, 'RHU I - Poblacion', 6, 1, '08:00:00', '12:00:00', NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(8, 'RHU II - Cutcot', 0, 0, NULL, NULL, NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(9, 'RHU II - Cutcot', 1, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(10, 'RHU II - Cutcot', 2, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(11, 'RHU II - Cutcot', 3, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(12, 'RHU II - Cutcot', 4, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(13, 'RHU II - Cutcot', 5, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(14, 'RHU II - Cutcot', 6, 1, '08:00:00', '12:00:00', NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(15, 'RHU III - Tinejero', 0, 0, NULL, NULL, NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(16, 'RHU III - Tinejero', 1, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(17, 'RHU III - Tinejero', 2, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(18, 'RHU III - Tinejero', 3, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(19, 'RHU III - Tinejero', 4, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(20, 'RHU III - Tinejero', 5, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(21, 'RHU III - Tinejero', 6, 1, '08:00:00', '12:00:00', NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(22, 'RHU IV - Tibag', 0, 0, NULL, NULL, NULL, NULL, 30, NULL, '2026-07-20 15:07:14'),
(23, 'RHU IV - Tibag', 1, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(24, 'RHU IV - Tibag', 2, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(25, 'RHU IV - Tibag', 3, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(26, 'RHU IV - Tibag', 4, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(27, 'RHU IV - Tibag', 5, 1, '08:00:00', '17:00:00', '12:00:00', '13:00:00', 30, NULL, '2026-07-20 15:07:14'),
(28, 'RHU IV - Tibag', 6, 1, '08:00:00', '12:00:00', NULL, NULL, 30, NULL, '2026-07-20 15:07:14');

-- --------------------------------------------------------

--
-- Table structure for table `disease_cases`
--

CREATE TABLE `disease_cases` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `disease_category` varchar(150) NOT NULL,
  `diagnosis` varchar(255) DEFAULT NULL,
  `symptoms` text DEFAULT NULL,
  `barangay` varchar(120) NOT NULL,
  `rhu_branch` varchar(150) NOT NULL,
  `case_date` date NOT NULL,
  `onset_date` date DEFAULT NULL,
  `age_group` varchar(50) NOT NULL DEFAULT 'Unknown',
  `case_status` varchar(50) NOT NULL DEFAULT 'Recorded',
  `verification_status` enum('Verified','Pending','Rejected') NOT NULL DEFAULT 'Verified',
  `record_source` varchar(120) NOT NULL DEFAULT 'RHU Consultation',
  `recorded_by` int(11) DEFAULT NULL,
  `verified_by` int(11) DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `disease_cases`
--

INSERT INTO `disease_cases` (`id`, `patient_id`, `appointment_id`, `disease_category`, `diagnosis`, `symptoms`, `barangay`, `rhu_branch`, `case_date`, `onset_date`, `age_group`, `case_status`, `verification_status`, `record_source`, `recorded_by`, `verified_by`, `verified_at`, `created_at`) VALUES
(1, 1, NULL, 'Dengue', NULL, NULL, 'Cutcot', 'RHU I - Poblacion', '2026-07-16', '2026-07-15', '18-35', 'Under Monitoring', 'Verified', 'RHU Consultation', 1, 1, '2026-07-28 01:36:12', '2026-07-27 17:36:12');

-- --------------------------------------------------------

--
-- Table structure for table `email_logs`
--

CREATE TABLE `email_logs` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `recipient` varchar(190) NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `subject` varchar(190) NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending',
  `provider_message_id` varchar(190) DEFAULT NULL,
  `provider_response` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `email_logs`
--

INSERT INTO `email_logs` (`id`, `patient_id`, `appointment_id`, `recipient`, `event_type`, `subject`, `status`, `provider_message_id`, `provider_response`, `created_at`) VALUES
(1, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607131333.87602930636@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607131333.87602930636@smtp-relay.mailin.fr>\"}\n', '2026-07-13 13:33:45'),
(2, 2, 1, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607131335.34606978800@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607131335.34606978800@smtp-relay.mailin.fr>\"}\n', '2026-07-13 13:35:34'),
(3, NULL, NULL, 'rhu1@pulilan.gov.ph', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607131535.36424016473@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607131535.36424016473@smtp-relay.mailin.fr>\"}\n', '2026-07-13 15:35:19'),
(4, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607131545.85423337222@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607131545.85423337222@smtp-relay.mailin.fr>\"}\n', '2026-07-13 15:45:27'),
(5, 2, 1, 'ashleyamira04@gmail.com', 'serving', 'Pulilan Health Center - Your Queue Is Being Called', 'sent', '<202607131556.69326893519@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607131556.69326893519@smtp-relay.mailin.fr>\"}\n', '2026-07-13 15:56:33'),
(6, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607140946.40347870325@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607140946.40347870325@smtp-relay.mailin.fr>\"}\n', '2026-07-14 09:46:50'),
(7, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607141023.76026336265@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607141023.76026336265@smtp-relay.mailin.fr>\"}\n', '2026-07-14 10:23:32'),
(8, 2, 1, 'ashleyamira04@gmail.com', 'done', 'Pulilan Health Center - Appointment Completed', 'sent', '<202607141038.74695518222@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607141038.74695518222@smtp-relay.mailin.fr>\"}\n', '2026-07-14 10:38:14'),
(9, 2, 2, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607141209.34809084074@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607141209.34809084074@smtp-relay.mailin.fr>\"}\n', '2026-07-14 12:09:51'),
(10, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607141609.69743821417@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607141609.69743821417@smtp-relay.mailin.fr>\"}\n', '2026-07-14 16:09:39'),
(11, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607201149.77003835024@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607201149.77003835024@smtp-relay.mailin.fr>\"}\n', '2026-07-20 11:49:13'),
(12, 2, 2, 'ashleyamira04@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607201152.44150296665@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607201152.44150296665@smtp-relay.mailin.fr>\"}\n', '2026-07-20 11:51:51'),
(13, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607201722.39078410188@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607201722.39078410188@smtp-relay.mailin.fr>\"}\n', '2026-07-20 17:22:13'),
(14, 2, 3, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607201743.32806503918@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607201743.32806503918@smtp-relay.mailin.fr>\"}\n', '2026-07-20 17:43:42'),
(15, 2, 2, 'ashleyamira04@gmail.com', 'serving', 'Pulilan Health Center - Your Queue Is Being Called', 'sent', '<202607201802.66270206476@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607201802.66270206476@smtp-relay.mailin.fr>\"}\n', '2026-07-20 18:02:53'),
(16, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607210943.98586263285@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607210943.98586263285@smtp-relay.mailin.fr>\"}\n', '2026-07-21 09:43:53'),
(17, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607211256.52700085063@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607211256.52700085063@smtp-relay.mailin.fr>\"}\n', '2026-07-21 12:56:58'),
(18, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607211558.18320334700@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607211558.18320334700@smtp-relay.mailin.fr>\"}\n', '2026-07-21 15:58:01'),
(19, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607211559.58644764597@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607211559.58644764597@smtp-relay.mailin.fr>\"}\n', '2026-07-21 15:59:03'),
(20, 2, 3, 'ashleyamira04@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607211632.25112135914@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607211632.25112135914@smtp-relay.mailin.fr>\"}\n', '2026-07-21 16:32:13'),
(21, 2, 4, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607211632.77918826465@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607211632.77918826465@smtp-relay.mailin.fr>\"}\n', '2026-07-21 16:32:35'),
(22, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607211645.96370621897@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607211645.96370621897@smtp-relay.mailin.fr>\"}\n', '2026-07-21 16:45:08'),
(23, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607220055.26253772069@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607220055.26253772069@smtp-relay.mailin.fr>\"}\n', '2026-07-22 00:55:39'),
(24, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607220104.87031810089@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607220104.87031810089@smtp-relay.mailin.fr>\"}\n', '2026-07-22 01:04:40'),
(25, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607231306.19239255655@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607231306.19239255655@smtp-relay.mailin.fr>\"}\n', '2026-07-23 13:06:27'),
(26, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607240546.71276908658@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240546.71276908658@smtp-relay.mailin.fr>\"}\n', '2026-07-24 05:46:15'),
(27, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607240631.22526021880@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240631.22526021880@smtp-relay.mailin.fr>\"}\n', '2026-07-24 06:31:36'),
(28, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240633.84136111517@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240633.84136111517@smtp-relay.mailin.fr>\"}\n', '2026-07-24 06:33:35'),
(29, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240650.25099194689@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240650.25099194689@smtp-relay.mailin.fr>\"}\n', '2026-07-24 06:50:55'),
(30, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240651.44077658422@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240651.44077658422@smtp-relay.mailin.fr>\"}\n', '2026-07-24 06:51:50'),
(31, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240653.71487838177@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240653.71487838177@smtp-relay.mailin.fr>\"}\n', '2026-07-24 06:53:18'),
(32, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240653.27308726621@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240653.27308726621@smtp-relay.mailin.fr>\"}\n', '2026-07-24 06:53:51'),
(33, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240703.17221719164@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240703.17221719164@smtp-relay.mailin.fr>\"}\n', '2026-07-24 07:03:42'),
(34, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240716.97923073805@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240716.97923073805@smtp-relay.mailin.fr>\"}\n', '2026-07-24 07:16:05'),
(35, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240720.70479634819@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240720.70479634819@smtp-relay.mailin.fr>\"}\n', '2026-07-24 07:20:30'),
(36, NULL, NULL, 'ashleyamira04@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240727.70152181423@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240727.70152181423@smtp-relay.mailin.fr>\"}\n', '2026-07-24 07:26:59'),
(37, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607240736.65742552890@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240736.65742552890@smtp-relay.mailin.fr>\"}\n', '2026-07-24 07:36:34'),
(38, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607240823.70144638388@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240823.70144638388@smtp-relay.mailin.fr>\"}\n', '2026-07-24 08:23:47'),
(39, 8, 5, 'rommelmarcelojr@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607240827.22303026393@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240827.22303026393@smtp-relay.mailin.fr>\"}\n', '2026-07-24 08:27:46'),
(40, 11, 6, 'dizonangelalauren@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607240845.84264760938@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240845.84264760938@smtp-relay.mailin.fr>\"}\n', '2026-07-24 08:45:10'),
(41, 8, 5, 'rommelmarcelojr@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607240851.98169276918@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240851.98169276918@smtp-relay.mailin.fr>\"}\n', '2026-07-24 08:50:59'),
(42, 8, 7, 'rommelmarcelojr@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607240852.28561059426@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240852.28561059426@smtp-relay.mailin.fr>\"}\n', '2026-07-24 08:51:59'),
(43, NULL, NULL, 'rommelmarcelojr@gmail.com', 'patient_reset_otp', 'Pulilan Health Center password reset code', 'sent', '<202607240924.23135958039@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607240924.23135958039@smtp-relay.mailin.fr>\"}\n', '2026-07-24 09:24:17'),
(44, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607241710.13015661091@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607241710.13015661091@smtp-relay.mailin.fr>\"}\n', '2026-07-24 17:10:39'),
(45, 11, 6, 'dizonangelalauren@gmail.com', 'serving', 'Pulilan Health Center - Your Queue Is Being Called', 'sent', '<202607241713.20096747404@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607241713.20096747404@smtp-relay.mailin.fr>\"}\n', '2026-07-24 17:13:06'),
(46, 11, 6, 'dizonangelalauren@gmail.com', 'done', 'Pulilan Health Center - Appointment Completed', 'sent', '<202607241714.86237526023@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607241714.86237526023@smtp-relay.mailin.fr>\"}\n', '2026-07-24 17:14:29'),
(47, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607241727.33564081790@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607241727.33564081790@smtp-relay.mailin.fr>\"}\n', '2026-07-24 17:26:58'),
(48, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607251444.35262755964@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607251444.35262755964@smtp-relay.mailin.fr>\"}\n', '2026-07-25 14:44:39'),
(49, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607251543.72831587447@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607251543.72831587447@smtp-relay.mailin.fr>\"}\n', '2026-07-25 15:43:50'),
(50, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607260702.28003855471@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607260702.28003855471@smtp-relay.mailin.fr>\"}\n', '2026-07-26 07:02:36'),
(51, 2, 4, 'ashleyamira04@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607260703.13796476543@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607260703.13796476543@smtp-relay.mailin.fr>\"}\n', '2026-07-26 07:03:54'),
(52, 2, 8, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607260706.63271220139@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607260706.63271220139@smtp-relay.mailin.fr>\"}\n', '2026-07-26 07:06:23'),
(53, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607261009.53644672516@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607261009.53644672516@smtp-relay.mailin.fr>\"}\n', '2026-07-26 10:09:09'),
(54, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607261117.72914268785@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607261117.72914268785@smtp-relay.mailin.fr>\"}\n', '2026-07-26 11:17:17'),
(55, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607270713.88390741176@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270713.88390741176@smtp-relay.mailin.fr>\"}\n', '2026-07-27 07:13:20'),
(56, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607270810.68747265533@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270810.68747265533@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:10:24'),
(57, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607270831.19909876630@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270831.19909876630@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:31:40'),
(58, 12, 9, 'walkin+202607271639007eb8@local.healthcenter', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607270839.28982941400@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270839.28982941400@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:39:00'),
(59, 12, 9, 'walkin+202607271639007eb8@local.healthcenter', 'serving', 'Pulilan Health Center - Your Queue Is Being Called', 'sent', '<202607270839.31646219854@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270839.31646219854@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:39:09'),
(60, 12, 9, 'walkin+202607271639007eb8@local.healthcenter', 'done', 'Pulilan Health Center - Appointment Completed', 'sent', '<202607270839.94635646664@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270839.94635646664@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:39:25'),
(61, 2, 8, 'ashleyamira04@gmail.com', 'serving', 'Pulilan Health Center - Your Queue Is Being Called', 'sent', '<202607270844.44816800834@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270844.44816800834@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:44:30'),
(62, 2, 8, 'ashleyamira04@gmail.com', 'done', 'Pulilan Health Center - Appointment Completed', 'sent', '<202607270846.53192171691@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270846.53192171691@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:46:06'),
(63, 14, 10, 'nielyiadelacruz@gmail.com', 'pending', 'Pulilan Health Center - Appointment Update', 'sent', '<202607270846.89441625203@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270846.89441625203@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:46:33'),
(64, 9, 11, 'charishartiaga@gmail.com', 'pending', 'Pulilan Health Center - Appointment Update', 'sent', '<202607270848.69063943608@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270848.69063943608@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:48:05'),
(65, 13, 12, 'cruzdave465@gmail.com', 'pending', 'Pulilan Health Center - Appointment Update', 'sent', '<202607270848.49160583782@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270848.49160583782@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:48:15'),
(66, 15, 13, 'xeviermione@gmail.com', 'pending', 'Pulilan Health Center - Appointment Update', 'sent', '<202607270853.12354336002@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270853.12354336002@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:53:00'),
(67, 8, 7, 'rommelmarcelojr@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607270853.58716533496@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270853.58716533496@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:53:04'),
(68, 8, 14, 'rommelmarcelojr@gmail.com', 'pending', 'Pulilan Health Center - Appointment Update', 'sent', '<202607270856.27281686722@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270856.27281686722@smtp-relay.mailin.fr>\"}\n', '2026-07-27 08:56:09'),
(69, 2, 15, 'ashleyamira04@gmail.com', 'pending', 'Pulilan Health Center - Appointment Update', 'sent', '<202607270910.22723325423@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270910.22723325423@smtp-relay.mailin.fr>\"}\n', '2026-07-27 09:10:47'),
(70, 2, 15, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607270911.35454012587@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607270911.35454012587@smtp-relay.mailin.fr>\"}\n', '2026-07-27 09:11:30'),
(71, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271029.65817054155@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271029.65817054155@smtp-relay.mailin.fr>\"}\n', '2026-07-27 10:28:54'),
(72, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271339.74854467454@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271339.74854467454@smtp-relay.mailin.fr>\"}\n', '2026-07-27 13:39:20'),
(73, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271519.83018063187@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271519.83018063187@smtp-relay.mailin.fr>\"}\n', '2026-07-27 15:18:54'),
(74, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271525.36557820885@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271525.36557820885@smtp-relay.mailin.fr>\"}\n', '2026-07-27 15:25:00'),
(75, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271531.12888833595@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271531.12888833595@smtp-relay.mailin.fr>\"}\n', '2026-07-27 15:31:31'),
(76, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271559.97532689347@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271559.97532689347@smtp-relay.mailin.fr>\"}\n', '2026-07-27 15:59:35'),
(77, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271704.24676029717@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271704.24676029717@smtp-relay.mailin.fr>\"}\n', '2026-07-27 17:04:48'),
(78, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607271816.26333945186@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607271816.26333945186@smtp-relay.mailin.fr>\"}\n', '2026-07-27 18:16:12'),
(79, 17, 16, 'ef6139789@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607280550.70762333692@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280550.70762333692@smtp-relay.mailin.fr>\"}\n', '2026-07-28 05:50:45'),
(80, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607280553.52665088611@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280553.52665088611@smtp-relay.mailin.fr>\"}\n', '2026-07-28 05:53:00'),
(81, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607280628.85356895383@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280628.85356895383@smtp-relay.mailin.fr>\"}\n', '2026-07-28 06:28:22'),
(82, 18, 17, 'printingbuss@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607280801.60482148184@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280801.60482148184@smtp-relay.mailin.fr>\"}\n', '2026-07-28 08:01:49'),
(83, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607280802.54547861913@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280802.54547861913@smtp-relay.mailin.fr>\"}\n', '2026-07-28 08:02:38'),
(84, 2, 15, 'ashleyamira04@gmail.com', 'serving', 'Pulilan Health Center - Your Queue Is Being Called', 'sent', '<202607280806.92969563171@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280806.92969563171@smtp-relay.mailin.fr>\"}\n', '2026-07-28 08:06:59'),
(85, 2, 2, 'ashleyamira04@gmail.com', 'done', 'Pulilan Health Center - Appointment Completed', 'sent', '<202607280808.90900254095@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280808.90900254095@smtp-relay.mailin.fr>\"}\n', '2026-07-28 08:08:12'),
(86, 2, 18, 'ashleyamira04@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607280809.34975393554@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607280809.34975393554@smtp-relay.mailin.fr>\"}\n', '2026-07-28 08:09:24'),
(87, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607281210.16494187126@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281210.16494187126@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:10:48'),
(88, NULL, NULL, 'pulilanhealthcenteradmin@gmail.com', 'admin_otp', 'Pulilan Health Center administrator verification code', 'sent', '<202607281213.96284532858@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281213.96284532858@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:13:33'),
(89, 13, 12, 'cruzdave465@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607281237.58909848919@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281237.58909848919@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:37:20'),
(90, 13, 19, 'cruzdave465@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281237.59579881495@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281237.59579881495@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:37:35'),
(91, 14, 20, 'nielyiadelacruz@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281237.83167744724@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281237.83167744724@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:37:49'),
(92, 20, 21, 'artiagacharish042304@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281239.20169276667@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281239.20169276667@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:39:46'),
(93, 21, 23, '1ndonlyaelia@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281241.43974618905@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281241.43974618905@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:41:05'),
(94, 23, 25, 'neligarciadc29@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281242.60285297378@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281242.60285297378@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:42:50'),
(95, 8, 14, 'rommelmarcelojr@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', 'sent', '<202607281244.23230965289@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281244.23230965289@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:44:07'),
(96, 24, 26, 'daynielcruz07@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281244.82701406714@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281244.82701406714@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:44:15'),
(97, 25, 27, 'shushameow@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281244.98237689078@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281244.98237689078@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:44:23'),
(98, 8, 28, 'rommelmarcelojr@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281244.99916149386@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281244.99916149386@smtp-relay.mailin.fr>\"}\n', '2026-07-28 12:44:41'),
(99, 26, 29, 'rommelde07@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281301.13981681944@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281301.13981681944@smtp-relay.mailin.fr>\"}\n', '2026-07-28 13:01:38'),
(100, 27, 30, 'maromarcelo431@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', 'sent', '<202607281314.91804950684@smtp-relay.mailin.fr>', '{\"messageId\":\"<202607281314.91804950684@smtp-relay.mailin.fr>\"}\n', '2026-07-28 13:14:02');

-- --------------------------------------------------------

--
-- Table structure for table `family_care_links`
--

CREATE TABLE `family_care_links` (
  `id` int(11) NOT NULL,
  `caregiver_patient_id` int(11) NOT NULL,
  `dependent_patient_id` int(11) NOT NULL,
  `relationship` varchar(40) NOT NULL,
  `verification_required` tinyint(1) NOT NULL DEFAULT 0,
  `verification_status` enum('Not Required','Pending','Verified','Rejected') NOT NULL DEFAULT 'Not Required',
  `verification_method` varchar(80) DEFAULT NULL,
  `verification_notes` text DEFAULT NULL,
  `verification_path` varchar(255) DEFAULT NULL,
  `verification_name` varchar(255) DEFAULT NULL,
  `verification_mime` varchar(100) DEFAULT NULL,
  `verified_by_admin_id` int(11) DEFAULT NULL,
  `verified_at` datetime DEFAULT NULL,
  `consent_scope` varchar(120) NOT NULL DEFAULT 'appointments_only',
  `status` enum('Pending','Approved','Rejected') NOT NULL DEFAULT 'Pending',
  `requested_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `responded_at` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `family_care_links`
--

INSERT INTO `family_care_links` (`id`, `caregiver_patient_id`, `dependent_patient_id`, `relationship`, `verification_required`, `verification_status`, `verification_method`, `verification_notes`, `verification_path`, `verification_name`, `verification_mime`, `verified_by_admin_id`, `verified_at`, `consent_scope`, `status`, `requested_at`, `responded_at`) VALUES
(2, 25, 15, 'Sibling', 1, 'Pending', 'Birth Certificate', NULL, 'uploads/caregiver/0e4b4dc34db6b56c4247739db9191d1b22853d07242b1102.pdf', 'Confirmation.pdf', 'application/pdf', NULL, NULL, 'appointments_only', 'Pending', '2026-07-28 13:59:06', NULL);

-- --------------------------------------------------------

--
-- Table structure for table `login_attempts`
--

CREATE TABLE `login_attempts` (
  `id` bigint(20) NOT NULL,
  `scope` varchar(40) NOT NULL,
  `identity_hash` char(64) NOT NULL,
  `ip_hash` char(64) NOT NULL,
  `failed_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `last_attempt_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `type` varchar(40) NOT NULL DEFAULT 'info',
  `title` varchar(150) NOT NULL,
  `message` text NOT NULL,
  `link` varchar(255) DEFAULT NULL,
  `dedupe_key` varchar(190) DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`id`, `patient_id`, `appointment_id`, `type`, `title`, `message`, `link`, `dedupe_key`, `is_read`, `created_at`) VALUES
(1, 2, 1, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-17 08:30 AM has been confirmed. Queue number: A-001.', 'appointments.html', NULL, 0, '2026-07-13 13:35:34'),
(2, 2, 1, 'queue', 'Your Queue Is Being Called', 'Queue A-001 is now being served. Please proceed to the assigned service area.', 'queue.html', NULL, 0, '2026-07-13 15:56:33'),
(3, 1, NULL, 'info', 'New Health Center Announcement', 'gggg: fsfs', 'dashboard.html', NULL, 0, '2026-07-13 16:07:50'),
(4, 2, NULL, 'info', 'New Health Center Announcement', 'gggg: fsfs', 'dashboard.html', NULL, 1, '2026-07-13 16:07:50'),
(5, 2, 1, 'success', 'Appointment Completed', 'Your Vaccination appointment has been marked completed.', 'appointments.html', NULL, 0, '2026-07-14 10:38:14'),
(6, 2, 2, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-15 08:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', NULL, 0, '2026-07-14 12:09:51'),
(7, 2, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', NULL, 0, '2026-07-20 11:49:55'),
(8, 2, 2, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-15 08:00 AM was cancelled.', 'appointments.html', NULL, 0, '2026-07-20 11:51:51'),
(9, 2, 3, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-21 09:30 AM has been confirmed. Queue number: A-001.', 'appointments.html', NULL, 0, '2026-07-20 17:43:42'),
(10, 2, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', NULL, 1, '2026-07-20 17:50:23'),
(11, 2, 3, 'queue', 'Arrival Confirmed', 'You have been marked arrived. Queue A-001 is now waiting to be called.', 'queue.html', NULL, 0, '2026-07-20 18:02:42'),
(12, 2, 2, 'queue', 'Your Queue Is Being Called', 'Queue A-001 is now being served. Please proceed to the assigned service area.', 'queue.html', NULL, 0, '2026-07-20 18:02:53'),
(13, 2, 3, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-21 09:30 AM was cancelled.', 'appointments.html', NULL, 0, '2026-07-21 16:32:13'),
(14, 2, 4, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-22 08:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', NULL, 1, '2026-07-21 16:32:35'),
(15, 8, 5, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-31 10:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', NULL, 1, '2026-07-24 08:27:46'),
(16, 11, 6, 'success', 'Appointment Confirmed', 'Your Prenatal Care appointment on 2026-07-25 08:00 AM has been confirmed. Queue number: P-001.', 'appointments.html', NULL, 0, '2026-07-24 08:45:10'),
(17, 8, 5, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-31 10:00 AM was cancelled.', 'appointments.html', NULL, 1, '2026-07-24 08:50:59'),
(18, 8, 7, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-25 08:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', NULL, 1, '2026-07-24 08:51:59'),
(19, 8, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', NULL, 1, '2026-07-24 08:52:15'),
(20, 11, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', NULL, 0, '2026-07-24 08:56:50'),
(21, 11, 6, 'queue', 'Arrival Confirmed', 'You have been marked arrived. Queue P-001 is now waiting to be called.', 'queue.html', NULL, 0, '2026-07-24 17:12:55'),
(22, 11, 6, 'queue', 'Your Queue Is Being Called', 'Queue P-001 is now being served. Please proceed to the assigned service area.', 'queue.html', NULL, 0, '2026-07-24 17:13:06'),
(23, 11, 6, 'success', 'Appointment Completed', 'Your Prenatal Care appointment has been marked completed.', 'appointments.html', NULL, 0, '2026-07-24 17:14:29'),
(24, 2, 4, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-22 08:00 AM was cancelled.', 'appointments.html?appointment=4', NULL, 0, '2026-07-26 07:03:54'),
(25, 2, 8, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-27 08:30 AM has been confirmed. Queue number: A-001.', 'appointments.html?appointment=8', NULL, 1, '2026-07-26 07:06:23'),
(26, 12, 9, 'success', 'Appointment Approved', 'Your General Consultation appointment on 2026-07-27 16:39 has been approved. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=9', 'appointment:9:appointment-approved:2026-07-27', 0, '2026-07-27 08:39:00'),
(27, 12, 9, 'queue', 'Your Turn Is Getting Close', 'You are next in line at RHU I - Poblacion. Please stay near the service area.', 'queue.html', 'appointment:9:your-turn-is-getting-close:2026-07-27', 0, '2026-07-27 08:39:01'),
(28, 12, 9, 'queue', 'Your Queue Is Being Called', 'Queue E-001 is now being served. Please proceed to the assigned service area.', 'queue.html', 'appointment:9:your-queue-is-being-called:2026-07-27', 0, '2026-07-27 08:39:09'),
(29, 12, 9, 'success', 'Appointment Completed', 'Your General Consultation appointment has been marked completed.', 'appointments.html', 'appointment:9:appointment-completed:2026-07-27', 0, '2026-07-27 08:39:25'),
(30, 2, 8, 'queue', 'Arrival Confirmed', 'Check-in complete. Your live queue number is A-002. Please wait for your number to be called.', 'queue.html', 'appointment:8:arrival-confirmed:2026-07-27', 0, '2026-07-27 08:44:23'),
(31, 2, 8, 'queue', 'Your Turn Is Getting Close', 'You are next in line at RHU I - Poblacion. Please stay near the service area.', 'queue.html', 'appointment:8:your-turn-is-getting-close:2026-07-27', 0, '2026-07-27 08:44:23'),
(32, 2, 8, 'queue', 'Your Queue Is Being Called', 'Queue A-002 is now being served. Please proceed to the assigned service area.', 'queue.html', 'appointment:8:your-queue-is-being-called:2026-07-27', 0, '2026-07-27 08:44:30'),
(33, 2, 8, 'success', 'Appointment Completed', 'Your Vaccination appointment has been marked completed.', 'appointments.html', 'appointment:8:appointment-completed:2026-07-27', 0, '2026-07-27 08:46:06'),
(34, 14, 10, 'info', 'Appointment Pending', 'Your General Consultation appointment request is pending review.', 'appointments.html?appointment=10', 'appointment:10:appointment-pending:2026-07-27', 0, '2026-07-27 08:46:33'),
(35, 9, 11, 'info', 'Appointment Pending', 'Your General Consultation appointment request is pending review.', 'appointments.html?appointment=11', 'appointment:11:appointment-pending:2026-07-27', 0, '2026-07-27 08:48:05'),
(36, 13, 12, 'info', 'Appointment Pending', 'Your Vaccination appointment request is pending review.', 'appointments.html?appointment=12', 'appointment:12:appointment-pending:2026-07-27', 1, '2026-07-27 08:48:15'),
(37, 15, 13, 'info', 'Appointment Pending', 'Your Prenatal Care appointment request is pending review.', 'appointments.html?appointment=13', 'appointment:13:appointment-pending:2026-07-27', 0, '2026-07-27 08:53:00'),
(38, 8, 7, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-25 08:00 AM was cancelled.', 'appointments.html?appointment=7', 'appointment:7:appointment-cancelled:2026-07-27', 1, '2026-07-27 08:53:04'),
(39, 8, 14, 'info', 'Appointment Pending', 'Your Vaccination appointment request is pending review.', 'appointments.html?appointment=14', 'appointment:14:appointment-pending:2026-07-27', 1, '2026-07-27 08:56:09'),
(40, 2, 15, 'info', 'Appointment Pending', 'Your Vaccination appointment request is pending review.', 'appointments.html?appointment=15', 'appointment:15:appointment-pending:2026-07-27', 0, '2026-07-27 09:10:47'),
(41, 2, 15, 'success', 'Appointment Approved', 'Your Vaccination appointment on 2026-07-28 08:30 AM has been approved. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=15', 'appointment:15:appointment-approved:2026-07-27', 0, '2026-07-27 09:11:30'),
(42, 8, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'messages.html?from=notification&conversation=8', 'inquiry-reply:60', 1, '2026-07-27 10:30:15'),
(43, 14, 10, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=10', 'auto-confirm:10', 1, '2026-07-27 13:37:47'),
(44, 9, 11, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=11', 'auto-confirm:11', 0, '2026-07-27 13:37:47'),
(45, 13, 12, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=12', 'auto-confirm:12', 1, '2026-07-27 13:37:47'),
(46, 15, 13, 'success', 'Appointment Confirmed', 'Your Prenatal Care appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=13', 'auto-confirm:13', 0, '2026-07-27 13:37:47'),
(47, 8, 14, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=14', 'auto-confirm:14', 1, '2026-07-27 13:37:47'),
(48, 17, 16, 'success', 'Appointment Confirmed', 'Your Family Planning appointment on 2026-07-30 09:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=16', 'appointment:16:appointment-confirmed:2026-07-28', 0, '2026-07-28 05:50:45'),
(49, 18, 17, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=17', 'appointment:17:appointment-confirmed:2026-07-28', 0, '2026-07-28 08:01:49'),
(50, 2, 15, 'queue', 'Arrival Confirmed', 'Check-in complete. Your live queue number is A-001. Please wait for your number to be called.', 'queue.html', 'appointment:15:arrival-confirmed:2026-07-28', 0, '2026-07-28 08:06:51'),
(51, 2, 15, 'queue', 'Your Turn Is Getting Close', 'You are next in line at RHU I - Poblacion. Please stay near the service area.', 'queue.html', 'appointment:15:your-turn-is-getting-close:2026-07-28', 0, '2026-07-28 08:06:51'),
(52, 2, 15, 'queue', 'Your Queue Is Being Called', 'Queue A-001 is now being served. Please proceed to the assigned service area.', 'queue.html', 'appointment:15:your-queue-is-being-called:2026-07-28', 0, '2026-07-28 08:06:58'),
(53, 2, 2, 'success', 'Appointment Completed', 'Your Vaccination appointment has been marked completed.', 'appointments.html', 'appointment:2:appointment-completed:2026-07-28', 0, '2026-07-28 08:08:12'),
(54, 2, 18, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=18', 'appointment:18:appointment-confirmed:2026-07-28', 0, '2026-07-28 08:09:24'),
(55, 13, 12, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-28 04:30 PM was cancelled.', 'appointments.html?appointment=12', 'appointment:12:appointment-cancelled:2026-07-28', 0, '2026-07-28 12:37:20'),
(56, 14, 10, 'danger', 'Appointment Cancelled', 'Your General Consultation appointment on 2026-07-28 04:30 PM was cancelled.', 'appointments.html?appointment=10', 'appointment:10:appointment-cancelled:2026-07-28', 0, '2026-07-28 12:37:21'),
(57, 13, 19, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=19', 'appointment:19:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:37:35'),
(58, 14, 20, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=20', 'appointment:20:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:37:49'),
(59, 20, 21, 'success', 'Appointment Confirmed', 'Your Child Immunization appointment on 2026-07-31 11:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=21', 'appointment:21:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:39:46'),
(60, 19, 22, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-29 10:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=22', 'appointment:22:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:39:54'),
(61, 21, 23, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=23', 'appointment:23:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:41:05'),
(62, 22, 24, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-29 09:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=24', 'appointment:24:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:41:09'),
(63, 23, 25, 'success', 'Appointment Confirmed', 'Your Child Immunization appointment on 2026-07-29 09:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=25', 'appointment:25:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:42:50'),
(64, 8, 14, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-28 04:30 PM was cancelled.', 'appointments.html?appointment=14', 'appointment:14:appointment-cancelled:2026-07-28', 1, '2026-07-28 12:44:07'),
(65, 24, 26, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 09:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=26', 'appointment:26:appointment-confirmed:2026-07-28', 0, '2026-07-28 12:44:15'),
(66, 25, 27, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=27', 'appointment:27:appointment-confirmed:2026-07-28', 1, '2026-07-28 12:44:23'),
(67, 8, 28, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 10:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=28', 'appointment:28:appointment-confirmed:2026-07-28', 1, '2026-07-28 12:44:41'),
(68, 26, 29, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 10:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=29', 'appointment:29:appointment-confirmed:2026-07-28', 0, '2026-07-28 13:01:38'),
(69, 27, 30, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 09:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=30', 'appointment:30:appointment-confirmed:2026-07-28', 0, '2026-07-28 13:14:02'),
(70, 15, NULL, 'info', 'Family Care Request', 'Shai Giban requested caregiver access. Review and approve it from Family Care.', 'family.html', NULL, 0, '2026-07-28 13:58:36'),
(71, 15, NULL, 'info', 'Family Care Request', 'Shai Giban requested caregiver access. Review and approve it from Family Care.', 'family.html', NULL, 0, '2026-07-28 13:59:06');

-- --------------------------------------------------------

--
-- Table structure for table `notification_delivery_logs`
--

CREATE TABLE `notification_delivery_logs` (
  `id` bigint(20) NOT NULL,
  `channel` enum('in_app','browser','email','sms') NOT NULL DEFAULT 'in_app',
  `patient_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `recipient` varchar(190) DEFAULT NULL,
  `event_type` varchar(60) NOT NULL DEFAULT 'notification',
  `title` varchar(190) NOT NULL,
  `message` text DEFAULT NULL,
  `link` varchar(255) DEFAULT NULL,
  `status` enum('delivered','failed','skipped') NOT NULL,
  `provider_record_id` varchar(190) DEFAULT NULL,
  `error_message` text DEFAULT NULL,
  `attempts` smallint(6) NOT NULL DEFAULT 1,
  `last_attempt_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `notification_delivery_logs`
--

INSERT INTO `notification_delivery_logs` (`id`, `channel`, `patient_id`, `appointment_id`, `recipient`, `event_type`, `title`, `message`, `link`, `status`, `provider_record_id`, `error_message`, `attempts`, `last_attempt_at`, `created_at`) VALUES
(1, 'in_app', 2, 3, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-21 09:30 AM has been confirmed. Queue number: A-001.', 'appointments.html', 'delivered', '9', NULL, 1, '2026-07-21 01:43:42', '2026-07-20 17:43:42'),
(2, 'in_app', 2, NULL, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', 'delivered', '10', NULL, 1, '2026-07-21 01:50:23', '2026-07-20 17:50:23'),
(3, 'in_app', 2, 3, NULL, 'queue', 'Arrival Confirmed', 'You have been marked arrived. Queue A-001 is now waiting to be called.', 'queue.html', 'delivered', '11', NULL, 1, '2026-07-21 02:02:42', '2026-07-20 18:02:42'),
(4, 'in_app', 2, 2, NULL, 'queue', 'Your Queue Is Being Called', 'Queue A-001 is now being served. Please proceed to the assigned service area.', 'queue.html', 'delivered', '12', NULL, 1, '2026-07-21 02:02:53', '2026-07-20 18:02:53'),
(5, 'in_app', 2, 3, NULL, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-21 09:30 AM was cancelled.', 'appointments.html', 'delivered', '13', NULL, 1, '2026-07-22 00:32:13', '2026-07-21 16:32:13'),
(6, 'in_app', 2, 4, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-22 08:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', 'delivered', '14', NULL, 1, '2026-07-22 00:32:35', '2026-07-21 16:32:35'),
(7, 'in_app', 8, 5, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-31 10:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', 'delivered', '15', NULL, 1, '2026-07-24 16:27:46', '2026-07-24 08:27:46'),
(8, 'in_app', 11, 6, NULL, 'success', 'Appointment Confirmed', 'Your Prenatal Care appointment on 2026-07-25 08:00 AM has been confirmed. Queue number: P-001.', 'appointments.html', 'delivered', '16', NULL, 1, '2026-07-24 16:45:10', '2026-07-24 08:45:10'),
(9, 'in_app', 8, 5, NULL, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-31 10:00 AM was cancelled.', 'appointments.html', 'delivered', '17', NULL, 1, '2026-07-24 16:50:59', '2026-07-24 08:50:59'),
(10, 'in_app', 8, 7, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-25 08:00 AM has been confirmed. Queue number: A-001.', 'appointments.html', 'delivered', '18', NULL, 1, '2026-07-24 16:51:59', '2026-07-24 08:51:59'),
(11, 'in_app', 8, NULL, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', 'delivered', '19', NULL, 1, '2026-07-24 16:52:15', '2026-07-24 08:52:15'),
(12, 'in_app', 11, NULL, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'dashboard.html', 'delivered', '20', NULL, 1, '2026-07-24 16:56:50', '2026-07-24 08:56:50'),
(13, 'in_app', 11, 6, NULL, 'queue', 'Arrival Confirmed', 'You have been marked arrived. Queue P-001 is now waiting to be called.', 'queue.html', 'delivered', '21', NULL, 1, '2026-07-25 01:12:55', '2026-07-24 17:12:55'),
(14, 'in_app', 11, 6, NULL, 'queue', 'Your Queue Is Being Called', 'Queue P-001 is now being served. Please proceed to the assigned service area.', 'queue.html', 'delivered', '22', NULL, 1, '2026-07-25 01:13:06', '2026-07-24 17:13:06'),
(15, 'in_app', 11, 6, NULL, 'success', 'Appointment Completed', 'Your Prenatal Care appointment has been marked completed.', 'appointments.html', 'delivered', '23', NULL, 1, '2026-07-25 01:14:29', '2026-07-24 17:14:29'),
(16, 'in_app', 2, 4, NULL, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-22 08:00 AM was cancelled.', 'appointments.html?appointment=4', 'delivered', '24', NULL, 1, '2026-07-26 15:03:54', '2026-07-26 07:03:54'),
(17, 'in_app', 2, 8, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-27 08:30 AM has been confirmed. Queue number: A-001.', 'appointments.html?appointment=8', 'delivered', '25', NULL, 1, '2026-07-26 15:06:23', '2026-07-26 07:06:23'),
(18, 'in_app', 12, 9, NULL, 'success', 'Appointment Approved', 'Your General Consultation appointment on 2026-07-27 16:39 has been approved. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=9', 'delivered', '26', NULL, 1, '2026-07-27 16:39:00', '2026-07-27 08:39:00'),
(19, 'in_app', 12, 9, NULL, 'queue', 'Your Turn Is Getting Close', 'You are next in line at RHU I - Poblacion. Please stay near the service area.', 'queue.html', 'delivered', '27', NULL, 1, '2026-07-27 16:39:01', '2026-07-27 08:39:01'),
(20, 'in_app', 12, 9, NULL, 'queue', 'Your Queue Is Being Called', 'Queue E-001 is now being served. Please proceed to the assigned service area.', 'queue.html', 'delivered', '28', NULL, 1, '2026-07-27 16:39:09', '2026-07-27 08:39:09'),
(21, 'in_app', 12, 9, NULL, 'success', 'Appointment Completed', 'Your General Consultation appointment has been marked completed.', 'appointments.html', 'delivered', '29', NULL, 1, '2026-07-27 16:39:25', '2026-07-27 08:39:25'),
(22, 'in_app', 2, 8, NULL, 'queue', 'Arrival Confirmed', 'Check-in complete. Your live queue number is A-002. Please wait for your number to be called.', 'queue.html', 'delivered', '30', NULL, 1, '2026-07-27 16:44:23', '2026-07-27 08:44:23'),
(23, 'in_app', 2, 8, NULL, 'queue', 'Your Turn Is Getting Close', 'You are next in line at RHU I - Poblacion. Please stay near the service area.', 'queue.html', 'delivered', '31', NULL, 1, '2026-07-27 16:44:23', '2026-07-27 08:44:23'),
(24, 'in_app', 2, 8, NULL, 'queue', 'Your Queue Is Being Called', 'Queue A-002 is now being served. Please proceed to the assigned service area.', 'queue.html', 'delivered', '32', NULL, 1, '2026-07-27 16:44:30', '2026-07-27 08:44:30'),
(25, 'in_app', 2, 8, NULL, 'success', 'Appointment Completed', 'Your Vaccination appointment has been marked completed.', 'appointments.html', 'delivered', '33', NULL, 1, '2026-07-27 16:46:06', '2026-07-27 08:46:06'),
(26, 'in_app', 14, 10, NULL, 'info', 'Appointment Pending', 'Your General Consultation appointment request is pending review.', 'appointments.html?appointment=10', 'delivered', '34', NULL, 1, '2026-07-27 16:46:33', '2026-07-27 08:46:33'),
(27, 'in_app', 9, 11, NULL, 'info', 'Appointment Pending', 'Your General Consultation appointment request is pending review.', 'appointments.html?appointment=11', 'delivered', '35', NULL, 1, '2026-07-27 16:48:05', '2026-07-27 08:48:05'),
(28, 'in_app', 13, 12, NULL, 'info', 'Appointment Pending', 'Your Vaccination appointment request is pending review.', 'appointments.html?appointment=12', 'delivered', '36', NULL, 1, '2026-07-27 16:48:15', '2026-07-27 08:48:15'),
(29, 'in_app', 15, 13, NULL, 'info', 'Appointment Pending', 'Your Prenatal Care appointment request is pending review.', 'appointments.html?appointment=13', 'delivered', '37', NULL, 1, '2026-07-27 16:53:00', '2026-07-27 08:53:00'),
(30, 'in_app', 8, 7, NULL, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-25 08:00 AM was cancelled.', 'appointments.html?appointment=7', 'delivered', '38', NULL, 1, '2026-07-27 16:53:04', '2026-07-27 08:53:04'),
(31, 'in_app', 8, 14, NULL, 'info', 'Appointment Pending', 'Your Vaccination appointment request is pending review.', 'appointments.html?appointment=14', 'delivered', '39', NULL, 1, '2026-07-27 16:56:09', '2026-07-27 08:56:09'),
(32, 'in_app', 2, 15, NULL, 'info', 'Appointment Pending', 'Your Vaccination appointment request is pending review.', 'appointments.html?appointment=15', 'delivered', '40', NULL, 1, '2026-07-27 17:10:47', '2026-07-27 09:10:47'),
(33, 'in_app', 2, 15, NULL, 'success', 'Appointment Approved', 'Your Vaccination appointment on 2026-07-28 08:30 AM has been approved. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=15', 'delivered', '41', NULL, 1, '2026-07-27 17:11:30', '2026-07-27 09:11:30'),
(34, 'in_app', 8, NULL, NULL, 'info', 'New Reply to Your Inquiry', 'Pulilan Health Center staff replied to your message.', 'messages.html?from=notification&conversation=8', 'delivered', '42', NULL, 1, '2026-07-27 18:30:15', '2026-07-27 10:30:15'),
(35, 'in_app', 14, 10, NULL, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=10', 'delivered', '43', NULL, 1, '2026-07-27 21:37:47', '2026-07-27 13:37:47'),
(36, 'in_app', 9, 11, NULL, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=11', 'delivered', '44', NULL, 1, '2026-07-27 21:37:47', '2026-07-27 13:37:47'),
(37, 'in_app', 13, 12, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=12', 'delivered', '45', NULL, 1, '2026-07-27 21:37:47', '2026-07-27 13:37:47'),
(38, 'in_app', 15, 13, NULL, 'success', 'Appointment Confirmed', 'Your Prenatal Care appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=13', 'delivered', '46', NULL, 1, '2026-07-27 21:37:47', '2026-07-27 13:37:47'),
(39, 'in_app', 8, 14, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-28 04:30 PM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=14', 'delivered', '47', NULL, 1, '2026-07-27 21:37:47', '2026-07-27 13:37:47'),
(40, 'in_app', 17, 16, NULL, 'success', 'Appointment Confirmed', 'Your Family Planning appointment on 2026-07-30 09:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=16', 'delivered', '48', NULL, 1, '2026-07-28 13:50:45', '2026-07-28 05:50:45'),
(41, 'in_app', 18, 17, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=17', 'delivered', '49', NULL, 1, '2026-07-28 16:01:49', '2026-07-28 08:01:49'),
(42, 'in_app', 2, 15, NULL, 'queue', 'Arrival Confirmed', 'Check-in complete. Your live queue number is A-001. Please wait for your number to be called.', 'queue.html', 'delivered', '50', NULL, 1, '2026-07-28 16:06:51', '2026-07-28 08:06:51'),
(43, 'in_app', 2, 15, NULL, 'queue', 'Your Turn Is Getting Close', 'You are next in line at RHU I - Poblacion. Please stay near the service area.', 'queue.html', 'delivered', '51', NULL, 1, '2026-07-28 16:06:51', '2026-07-28 08:06:51'),
(44, 'in_app', 2, 15, NULL, 'queue', 'Your Queue Is Being Called', 'Queue A-001 is now being served. Please proceed to the assigned service area.', 'queue.html', 'delivered', '52', NULL, 1, '2026-07-28 16:06:59', '2026-07-28 08:06:59'),
(45, 'in_app', 2, 2, NULL, 'success', 'Appointment Completed', 'Your Vaccination appointment has been marked completed.', 'appointments.html', 'delivered', '53', NULL, 1, '2026-07-28 16:08:12', '2026-07-28 08:08:12'),
(46, 'in_app', 2, 18, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=18', 'delivered', '54', NULL, 1, '2026-07-28 16:09:24', '2026-07-28 08:09:24'),
(47, 'in_app', 13, 12, NULL, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-28 04:30 PM was cancelled.', 'appointments.html?appointment=12', 'delivered', '55', NULL, 1, '2026-07-28 20:37:20', '2026-07-28 12:37:20'),
(48, 'in_app', 14, 10, NULL, 'danger', 'Appointment Cancelled', 'Your General Consultation appointment on 2026-07-28 04:30 PM was cancelled.', 'appointments.html?appointment=10', 'delivered', '56', NULL, 1, '2026-07-28 20:37:21', '2026-07-28 12:37:21'),
(49, 'email', 14, 10, 'nielyiadelacruz@gmail.com', 'cancelled', 'Pulilan Health Center - Appointment Cancelled', NULL, NULL, 'skipped', NULL, 'Brevo email is not configured.', 1, '2026-07-28 20:37:21', '2026-07-28 12:37:21'),
(50, 'in_app', 13, 19, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=19', 'delivered', '57', NULL, 1, '2026-07-28 20:37:35', '2026-07-28 12:37:35'),
(51, 'in_app', 14, 20, NULL, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=20', 'delivered', '58', NULL, 1, '2026-07-28 20:37:49', '2026-07-28 12:37:49'),
(52, 'in_app', 20, 21, NULL, 'success', 'Appointment Confirmed', 'Your Child Immunization appointment on 2026-07-31 11:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=21', 'delivered', '59', NULL, 1, '2026-07-28 20:39:46', '2026-07-28 12:39:46'),
(53, 'in_app', 19, 22, NULL, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-29 10:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=22', 'delivered', '60', NULL, 1, '2026-07-28 20:39:54', '2026-07-28 12:39:54'),
(54, 'email', 19, 22, 'usmandinoaivan@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', NULL, NULL, 'skipped', NULL, 'Brevo email is not configured.', 1, '2026-07-28 20:39:54', '2026-07-28 12:39:54'),
(55, 'in_app', 21, 23, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=23', 'delivered', '61', NULL, 1, '2026-07-28 20:41:05', '2026-07-28 12:41:05'),
(56, 'in_app', 22, 24, NULL, 'success', 'Appointment Confirmed', 'Your General Consultation appointment on 2026-07-29 09:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=24', 'delivered', '62', NULL, 1, '2026-07-28 20:41:09', '2026-07-28 12:41:09'),
(57, 'email', 22, 24, 'dvcrz0803@gmail.com', 'confirmed', 'Pulilan Health Center - Appointment Confirmed', NULL, NULL, 'skipped', NULL, 'Brevo email is not configured.', 1, '2026-07-28 20:41:09', '2026-07-28 12:41:09'),
(58, 'in_app', 23, 25, NULL, 'success', 'Appointment Confirmed', 'Your Child Immunization appointment on 2026-07-29 09:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=25', 'delivered', '63', NULL, 1, '2026-07-28 20:42:50', '2026-07-28 12:42:50'),
(59, 'in_app', 8, 14, NULL, 'danger', 'Appointment Cancelled', 'Your Vaccination appointment on 2026-07-28 04:30 PM was cancelled.', 'appointments.html?appointment=14', 'delivered', '64', NULL, 1, '2026-07-28 20:44:07', '2026-07-28 12:44:07'),
(60, 'in_app', 24, 26, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 09:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=26', 'delivered', '65', NULL, 1, '2026-07-28 20:44:15', '2026-07-28 12:44:15'),
(61, 'in_app', 25, 27, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 08:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=27', 'delivered', '66', NULL, 1, '2026-07-28 20:44:23', '2026-07-28 12:44:23'),
(62, 'in_app', 8, 28, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 10:00 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=28', 'delivered', '67', NULL, 1, '2026-07-28 20:44:41', '2026-07-28 12:44:41'),
(63, 'in_app', 26, 29, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 10:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=29', 'delivered', '68', NULL, 1, '2026-07-28 21:01:38', '2026-07-28 13:01:38'),
(64, 'in_app', 27, 30, NULL, 'success', 'Appointment Confirmed', 'Your Vaccination appointment on 2026-07-29 09:30 AM is confirmed. Your live queue number will be assigned when you check in.', 'appointments.html?appointment=30', 'delivered', '69', NULL, 1, '2026-07-28 21:14:02', '2026-07-28 13:14:02'),
(65, 'in_app', 15, NULL, NULL, 'info', 'Family Care Request', 'Shai Giban requested caregiver access. Review and approve it from Family Care.', 'family.html', 'delivered', '70', NULL, 1, '2026-07-28 21:58:36', '2026-07-28 13:58:36'),
(66, 'in_app', 15, NULL, NULL, 'info', 'Family Care Request', 'Shai Giban requested caregiver access. Review and approve it from Family Care.', 'family.html', 'delivered', '71', NULL, 1, '2026-07-28 21:59:06', '2026-07-28 13:59:06');

-- --------------------------------------------------------

--
-- Table structure for table `password_resets`
--

CREATE TABLE `password_resets` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `email` varchar(150) NOT NULL,
  `otp_hash` varchar(255) NOT NULL,
  `attempts` int(11) NOT NULL DEFAULT 0,
  `token_hash` varchar(255) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `password_resets`
--

INSERT INTO `password_resets` (`id`, `patient_id`, `email`, `otp_hash`, `attempts`, `token_hash`, `expires_at`, `used_at`, `created_at`) VALUES
(1, 2, 'ashleyamira04@gmail.com', '', 0, '4c40025242e054288491ce0327796e8a8779ac25b58771313c7737aec4a89b49', '2026-07-24 15:27:19', '2026-07-24 14:29:41', '2026-07-24 06:27:19'),
(2, 2, 'ashleyamira04@gmail.com', '', 0, '5b94d6afd40a11a619429f92c2b565df872a251cf9f9b2fcbeaa44ad5d2dae89', '2026-07-24 15:29:41', '2026-07-24 14:33:35', '2026-07-24 06:29:41'),
(3, 2, 'ashleyamira04@gmail.com', '$2y$10$71SEQVe/nEBF2YZNMIc1QuQIyJAUhGEy4Ne8oMmhvbefQ7UiRxl26', 0, '', '2026-07-24 14:43:35', '2026-07-24 14:50:55', '2026-07-24 06:33:35'),
(4, 2, 'ashleyamira04@gmail.com', '$2y$10$B7o.eiVCw81rKJDgJOvK1.YYYWjxtFJSS3Flpd56S26cWoS.6DdC6', 0, '', '2026-07-24 15:00:55', '2026-07-24 14:51:50', '2026-07-24 06:50:55'),
(5, 2, 'ashleyamira04@gmail.com', '$2y$10$X/ezkuY995ANtxKm1cV9Text1AV9jyjBLsvlhyvYp9d8WEe5CgSCC', 0, '', '2026-07-24 15:01:50', '2026-07-24 14:53:18', '2026-07-24 06:51:50'),
(6, 2, 'ashleyamira04@gmail.com', '$2y$10$viA0u7mamB26LCuXSGSTWeJUAC/.swmVrqGKsE7m883Se1VnOtEp6', 0, '', '2026-07-24 15:03:18', '2026-07-24 14:53:51', '2026-07-24 06:53:18'),
(7, 2, 'ashleyamira04@gmail.com', '$2y$10$Uw.5BjLF4pS2RTbdSdbMDeofimClNLFyGi0unAB.HtMLO132NFiti', 0, '', '2026-07-24 15:03:51', '2026-07-24 15:03:42', '2026-07-24 06:53:51'),
(8, 2, 'ashleyamira04@gmail.com', '$2y$10$LPG224ZQRbNwI/073nIx5OsInPKxRztxfYYwOjo3Mkd5aTdFNffS6', 0, '', '2026-07-24 15:13:42', '2026-07-24 15:16:05', '2026-07-24 07:03:42'),
(9, 2, 'ashleyamira04@gmail.com', '$2y$10$yKup9Jk87WjmiZmycj7vY.U837622L0BTjXsAL0rwOZDEHXu2ivNW', 0, '', '2026-07-24 15:26:05', '2026-07-24 15:20:30', '2026-07-24 07:16:05'),
(10, 2, 'ashleyamira04@gmail.com', '$2y$10$cPzQamthMCoBJR4MIcOydOBYQuKEJ2iqXDvL8JK46AJKQP/F9YKGy', 0, '', '2026-07-24 15:30:30', '2026-07-24 15:26:59', '2026-07-24 07:20:30'),
(11, 2, 'ashleyamira04@gmail.com', '$2y$10$Zx1EuGNEKIJxoXP.5WVQxOnXBeijS85HZJMQVSf6CiIOCy27VH8SO', 0, '', '2026-07-24 15:36:59', NULL, '2026-07-24 07:26:59'),
(12, 8, 'rommelmarcelojr@gmail.com', '$2y$10$2bEN8oy2BxxlpeQKHpCCpOrHCKj7WLuEIhnysMhdIT/YzXleZi1w.', 0, '', '2026-07-24 17:34:17', '2026-07-24 17:24:55', '2026-07-24 09:24:17');

-- --------------------------------------------------------

--
-- Table structure for table `patients`
--

CREATE TABLE `patients` (
  `id` int(11) NOT NULL,
  `patient_code` varchar(20) DEFAULT NULL,
  `first_name` varchar(100) NOT NULL,
  `last_name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `phone` varchar(30) DEFAULT NULL,
  `birthdate` date DEFAULT NULL,
  `gender` varchar(30) DEFAULT NULL,
  `address` text DEFAULT NULL,
  `barangay` varchar(100) DEFAULT NULL,
  `philhealth_no` varchar(80) DEFAULT NULL,
  `is_senior` tinyint(1) DEFAULT 0,
  `is_pwd` tinyint(1) DEFAULT 0,
  `is_4ps` tinyint(1) DEFAULT 0,
  `preferred_rhu` varchar(150) DEFAULT NULL,
  `account_status` enum('Active','Archived') NOT NULL DEFAULT 'Active',
  `archived_at` datetime DEFAULT NULL,
  `profile_json` longtext DEFAULT NULL,
  `failed_login_attempts` int(11) NOT NULL DEFAULT 0,
  `locked_until` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `patients`
--

INSERT INTO `patients` (`id`, `patient_code`, `first_name`, `last_name`, `email`, `password_hash`, `phone`, `birthdate`, `gender`, `address`, `barangay`, `philhealth_no`, `is_senior`, `is_pwd`, `is_4ps`, `preferred_rhu`, `account_status`, `archived_at`, `profile_json`, `failed_login_attempts`, `locked_until`, `created_at`) VALUES
(1, 'USR-001', 'Ashley', 'Amira', 'ashley@gmail.com', '$2y$12$zSGc37Xr77jYyRE..VNmg.JvrX4xdRdBuycphNelrS/azufOgucdS', '09171234567', '2000-01-01', 'Female', NULL, 'Cutcot', NULL, 0, 0, 0, NULL, 'Active', NULL, NULL, 0, NULL, '2026-07-13 13:32:15'),
(2, 'USR-002', 'Ashley', 'Marcelo', 'ashleyamira04@gmail.com', '$2y$10$leQA4w0BICaLosJ0Ai/7ke2dwFRoAQv5SNSzvO64r5dlP9q5xenVa', '09585845848', '2005-10-04', 'Female', 'adadad', 'Cutcot', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Ashley\",\"lastName\":\"Marcelo\",\"middleName\":\"\",\"suffix\":\"\",\"dob\":\"2005-10-04\",\"sex\":\"Female\",\"civilStatus\":\"\",\"nationality\":\"\",\"religion\":\"\",\"occupation\":\"\",\"mobile\":\"09585845848\",\"email\":\"ashleyamira04@gmail.com\",\"barangay\":\"Cutcot\",\"street\":\"adadad\",\"zip\":\"3005\",\"bloodType\":\"\",\"height\":\"\",\"weight\":\"\",\"allergies\":\"\",\"conditions\":\"\",\"medications\":\"\",\"smoking\":\"\",\"alcohol\":\"\",\"vaccination\":\"\",\"obgyn\":\"\",\"preferredRhu\":\"\",\"preferredTime\":\"\",\"philhealthFile\":\"\",\"philhealthCardImage\":\"\",\"philhealthNum\":\"\",\"philhealthType\":\"\",\"philhealthStatus\":\"\",\"philhealthEmployer\":\"\",\"philhealthDependents\":\"\",\"seniorFile\":\"\",\"seniorCardImage\":\"\",\"pwdFile\":\"\",\"pwdCardImage\":\"\",\"fourPsFile\":\"\",\"fourPsCardImage\":\"\",\"soloParentFile\":\"\",\"soloParentCardImage\":\"\",\"isSenior\":false,\"scId\":\"\",\"isPwd\":false,\"pwdType\":\"\",\"pwdId\":\"\",\"toggle4ps\":false,\"fourPsNum\":\"\",\"toggleNhts\":false,\"toggleMalasakit\":false,\"toggleSoloParent\":false,\"soloParentId\":\"\",\"ecName\":\"\",\"ecRelationship\":\"\",\"ecMobile\":\"\",\"ecAlt\":\"\",\"ecAddress\":\"\",\"accountEmail\":\"ashleyamira04@gmail.com\",\"phone\":\"09585845848\",\"birthdate\":\"2005-10-04\",\"gender\":\"Female\",\"address\":\"adadad\",\"philhealthNo\":\"\",\"is4ps\":false,\"id\":\"USR-002\",\"dbId\":2,\"name\":\"Ashley Marcelo\",\"accountStatus\":\"Active\",\"archivedAt\":null,\"createdAt\":\"2026-07-13 21:34:32\",\"profilePhoto\":\"\",\"profile_picture\":\"\"}', 0, NULL, '2026-07-13 13:34:32'),
(8, 'USR-008', 'Rommel', 'Marcelo', 'rommelmarcelojr@gmail.com', '$2y$10$7WhJa1YPhyyavzxnBtvwbuhTVO4ggMUid7sERovDETfvXVwfK36uy', '09050469726', '2001-12-24', 'Male', '1576 Banga II Plaridel Bulacan', 'Lumbac', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Rommel\",\"lastName\":\"Marcelo\",\"middleName\":\"\",\"suffix\":\"\",\"dob\":\"2001-12-24\",\"sex\":\"Male\",\"civilStatus\":\"\",\"nationality\":\"\",\"religion\":\"\",\"occupation\":\"\",\"mobile\":\"09050469726\",\"email\":\"rommelmarcelojr@gmail.com\",\"barangay\":\"Lumbac\",\"street\":\"1576 Banga II Plaridel Bulacan\",\"zip\":\"3005\",\"bloodType\":\"\",\"height\":\"170\",\"weight\":\"67\",\"allergies\":\"Shrimp\",\"conditions\":\"Asthma\",\"medications\":\"\",\"smoking\":\"Non-smoker\",\"alcohol\":\"None\",\"vaccination\":\"COVID-19 Vaccinated\",\"obgyn\":\"\",\"preferredRhu\":\"\",\"preferredTime\":\"\",\"philhealthFile\":\"\",\"philhealthCardImage\":\"\",\"philhealthNum\":\"\",\"philhealthType\":\"\",\"philhealthStatus\":\"\",\"philhealthEmployer\":\"\",\"philhealthDependents\":\"\",\"seniorFile\":\"\",\"seniorCardImage\":\"\",\"pwdFile\":\"\",\"pwdCardImage\":\"\",\"fourPsFile\":\"\",\"fourPsCardImage\":\"\",\"soloParentFile\":\"\",\"soloParentCardImage\":\"\",\"isSenior\":false,\"scId\":\"\",\"isPwd\":false,\"pwdType\":\"\",\"pwdId\":\"\",\"toggle4ps\":false,\"fourPsNum\":\"\",\"toggleNhts\":false,\"toggleMalasakit\":false,\"toggleSoloParent\":false,\"soloParentId\":\"\",\"ecName\":\"\",\"ecRelationship\":\"\",\"ecMobile\":\"\",\"ecAlt\":\"\",\"ecAddress\":\"\",\"accountEmail\":\"rommelmarcelojr@gmail.com\",\"phone\":\"09050469726\",\"birthdate\":\"2001-12-24\",\"gender\":\"Male\",\"address\":\"1576 Banga II Plaridel Bulacan\",\"philhealthNo\":\"\"}', 0, NULL, '2026-07-24 08:24:16'),
(9, 'USR-009', 'Charish', 'Artiaga', 'charishartiaga@gmail.com', '$2y$10$QLoBJczLtz8d712aRXR2tOhMzNExx1Y5rG6mwpy1Sv4jg.BJfyWMm', '09081314740', '2004-04-23', 'Female', '08 A tenejero pulilan,bulacan', 'Tinejero', '', 0, 1, 0, NULL, 'Active', NULL, '{\"firstName\":\"Charish\",\"lastName\":\"Artiaga\",\"phone\":\"09081314740\",\"dob\":\"2004-04-23\",\"sex\":\"Female\",\"barangay\":\"Tinejero\",\"address\":\"08 A tenejero pulilan,bulacan\",\"isSenior\":false,\"isPwd\":true,\"is4ps\":false}', 0, NULL, '2026-07-24 08:24:39'),
(10, 'USR-010', 'Lea Jane', 'Reyes', 'leajanereyes2@gmail.com', '$2y$10$hD1qqJ9c7A2Cvw4iuU.eIenx8pYFO/YnKrn0v2PlPtJDfTv2/XZkO', '09617427603', NULL, NULL, '1203,Poblacion, Pulilan, Bulacan', NULL, NULL, 0, 0, 0, NULL, 'Active', NULL, NULL, 0, NULL, '2026-07-24 08:26:30'),
(11, 'USR-011', 'Angela', 'Lauren', 'dizonangelalauren@gmail.com', '$2y$10$Lw0EUvQxYC9mvYGj0nVXdO7yYKs2SqWp22dJZzl6iyyxAv.fhwE7q', '09223198408', '2005-06-04', 'Female', 'Olympia Subd. Poblacion Pulilan Bulacan', 'Poblacion', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Angela\",\"lastName\":\"Lauren\",\"phone\":\"09223198408\",\"dob\":\"2005-06-04\",\"sex\":\"Female\",\"barangay\":\"Poblacion\",\"address\":\"Olympia Subd. Poblacion Pulilan Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-24 08:40:57'),
(12, 'USR-012', 'Bogart', 'Patient', 'walkin+202607271639007eb8@local.healthcenter', '$2y$10$kRAPKKl.jUKYz8emRJ7rEe8PuUEJCuytMVxsfqjyppI6ibFRXZliC', '0974959782', NULL, NULL, NULL, NULL, NULL, 0, 0, 0, 'RHU I - Poblacion', 'Archived', '2026-07-27 16:59:58', NULL, 0, NULL, '2026-07-27 08:39:00'),
(13, 'USR-013', 'Dave', 'Cruz', 'cruzdave465@gmail.com', '$2y$10$IA5mH9o4.slRptsWkJ6wXu172yvbuEt9IqyTZLUEJoeVPtMeJaCJG', '09100534538', '2004-08-03', 'Male', '112, SAN.FRANCISCO STREET LUMBAC PULILAN,BULACAN', 'Lumbac', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Dave\",\"lastName\":\"Cruz\",\"phone\":\"09100534538\",\"dob\":\"2004-08-03\",\"sex\":\"Male\",\"barangay\":\"Lumbac\",\"address\":\"112, SAN.FRANCISCO STREET LUMBAC PULILAN,BULACAN\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-27 08:40:01'),
(14, 'USR-014', 'Nielyia Dela', 'Cruz', 'nielyiadelacruz@gmail.com', '$2y$10$QJrf/7axXLYsObtzMlM8DeZE14fkyWhPD0F/ZykKWSl1JG0kWh/tW', '09815441210', '2026-03-29', 'Female', '329 Cutcot Pulilan Bulacan', 'Cutcot', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Nielyia Dela\",\"lastName\":\"Cruz\",\"phone\":\"09815441210\",\"dob\":\"2026-03-29\",\"sex\":\"Female\",\"barangay\":\"Cutcot\",\"address\":\"329 Cutcot Pulilan Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-27 08:40:33'),
(15, 'USR-015', 'Eurika', 'Indita', 'xeviermione@gmail.com', '$2y$10$FnlJR6SZFf.ap8epZ3TsmOd.lkBUKMgqrjyPZme2iWbDdda2wQDUW', '09196256739', '2005-02-08', 'Female', 'Malolos, Bulacan', 'Dampol I', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Eurika\",\"lastName\":\"Indita\",\"phone\":\"09196256739\",\"dob\":\"2005-02-08\",\"sex\":\"Female\",\"barangay\":\"Dampol I\",\"address\":\"Malolos, Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-27 08:50:18'),
(16, 'USR-016', 'Maricel', 'Marcelo', 'maricelmarcelo9494@gmail.com', '$2y$10$Uw2omjpC6YeXdstu2w0nJu9SnYy6QeyXGFAJXebOmpXs3Xn.Lfaze', NULL, NULL, NULL, NULL, NULL, NULL, 0, 0, 0, NULL, 'Active', NULL, '{\"auth_provider\":\"google\",\"google_id\":\"109678540455805603820\",\"google_payload\":{\"sub\":\"109678540455805603820\",\"name\":\"Maricel Marcelo\",\"given_name\":\"Maricel\",\"family_name\":\"Marcelo\",\"picture\":\"https:\\/\\/lh3.googleusercontent.com\\/a\\/ACg8ocLcm9MOmrWQkO7aSRDpIXIHhS2uGJDaDaZCu6gE8JxeuhsP3A=s96-c\",\"email\":\"maricelmarcelo9494@gmail.com\",\"email_verified\":true,\"aud\":\"701320665083-q9o0vpr2delb6o3l9cstq6omhu8fd3de.apps.googleusercontent.com\"}}', 0, NULL, '2026-07-28 05:04:29'),
(17, 'USR-017', 'Esmeralda', 'Fatima', 'ef6139789@gmail.com', '$2y$10$UZax.E7sdTHOZmVYoU5B.uF9HZ1YNXNiVyKxqDq7vZCqMWwidg9qS', '09706663765', '1990-12-31', 'Female', '5102 longos bulacan bulacan', 'Longos', '', 0, 1, 0, NULL, 'Active', NULL, '{\"firstName\":\"Esmeralda\",\"lastName\":\"Fatima\",\"phone\":\"09706663765\",\"dob\":\"1990-12-31\",\"sex\":\"Female\",\"barangay\":\"Longos\",\"address\":\"5102 longos bulacan bulacan\",\"isSenior\":false,\"isPwd\":true,\"is4ps\":false}', 0, NULL, '2026-07-28 05:27:12'),
(18, 'USR-018', 'rencel', 'marcelo', 'printingbuss@gmail.com', '$2y$10$SUNr6CC0gpB7HNOvm.OcLOovNESMUI9zDie/mXBzTNjBP6h8QQqIW', '9120222757', '2003-06-04', 'Female', '118 Daang Baka', 'Inaon', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"rencel\",\"lastName\":\"marcelo\",\"phone\":\"9120222757\",\"dob\":\"2003-06-04\",\"sex\":\"Female\",\"barangay\":\"Inaon\",\"address\":\"118 Daang Baka\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 08:00:06'),
(19, 'USR-019', 'Dino', 'Usman', 'usmandinoaivan@gmail.com', '$2y$10$iivJVhBkIUB7UN.kHCD99.tni5f6ZBz/Mjun0tBjnSJurbirnowvG', '09269868699', '2003-03-20', 'Male', 'Tinejero, Pulilan', 'Tinejero', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Dino\",\"lastName\":\"Usman\",\"phone\":\"09269868699\",\"dob\":\"2003-03-20\",\"sex\":\"Male\",\"barangay\":\"Tinejero\",\"address\":\"Tinejero, Pulilan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:36:03'),
(20, 'USR-020', 'Charish', 'Artiaga', 'artiagacharish042304@gmail.com', '$2y$10$lcH8UaPTLhhOUyyvSVjdTO4DhN.QTrcXK7i.NmMyQrdWPnC2iLsre', '09874563154', '2004-04-23', 'Female', 'dwadas', 'Santa Peregrina', '', 1, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Charish\",\"lastName\":\"Artiaga\",\"phone\":\"09874563154\",\"dob\":\"2004-04-23\",\"sex\":\"Female\",\"barangay\":\"Santa Peregrina\",\"address\":\"dwadas\",\"isSenior\":true,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:37:24'),
(21, 'USR-021', 'Nielyia Dela Cruz', '2', '1ndonlyaelia@gmail.com', '$2y$10$apxnG61cx9fUCj/2aDud5O0vc6Meb58qtNrMDX6YX2.bDm8mLedBq', '09815441210', '2026-02-18', 'Female', '329 Cutcot Pulilan Bulacan', 'Cutcot', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Nielyia Dela Cruz\",\"lastName\":\"2\",\"phone\":\"09815441210\",\"dob\":\"2026-02-18\",\"sex\":\"Female\",\"barangay\":\"Cutcot\",\"address\":\"329 Cutcot Pulilan Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:39:04'),
(22, 'USR-022', 'Dave', 'Cruz', 'dvcrz0803@gmail.com', '$2y$10$9yjIzs0sKjOYjPpa/zN2iekGZbmJKvR7KTTp7qMEO/yTsNRdu9.uu', '09123456789', '2004-08-03', 'Male', '112, lumbac pulilan bulacan', 'Lumbac', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Dave\",\"lastName\":\"Cruz\",\"phone\":\"09123456789\",\"dob\":\"2004-08-03\",\"sex\":\"Male\",\"barangay\":\"Lumbac\",\"address\":\"112, lumbac pulilan bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:39:34'),
(23, 'USR-023', 'Neli', '3', 'neligarciadc29@gmail.com', '$2y$10$dFVk8cgYDrFba.LXUor41eM8cfFrV.DNkeTvDO3RZ4vrtr0GhPr0O', '09815441210', '2026-01-01', 'Female', '123 Tiejero Pulilan Bulacan', 'Tinejero', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Neli\",\"lastName\":\"3\",\"phone\":\"09815441210\",\"dob\":\"2026-01-01\",\"sex\":\"Female\",\"barangay\":\"Tinejero\",\"address\":\"123 Tiejero Pulilan Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:41:24'),
(24, 'USR-024', 'Dayniel', 'Cruz', 'daynielcruz07@gmail.com', '$2y$10$H4CKk6mpBOCKG5yL29Aajuh5G3h2kSiMWtsYd7S5MxfSCqnTdiSxy', '09987654321', '2006-12-21', 'Male', '112. Lumbac, Pulilan, Bulacan', 'Lumbac', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Dayniel\",\"lastName\":\"Cruz\",\"phone\":\"09987654321\",\"dob\":\"2006-12-21\",\"sex\":\"Male\",\"barangay\":\"Lumbac\",\"address\":\"112. Lumbac, Pulilan, Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:42:27'),
(25, 'USR-025', 'Shai', 'Giban', 'shushameow@gmail.com', '$2y$10$c4Nn1QuuLTFhQx58ljdLXO1nrp6B1uB9jZy.5gtmQB4hw46p.2NPy', '09766375385', '2003-02-06', 'Female', 'Cutcot,Pulilan', 'Cutcot', '', 0, 1, 0, NULL, 'Active', NULL, '{\"firstName\":\"Shai\",\"lastName\":\"Giban\",\"middleName\":\"E.\",\"suffix\":\"\",\"dob\":\"2003-02-06\",\"sex\":\"Female\",\"civilStatus\":\"Single\",\"nationality\":\"Filipino\",\"religion\":\"Born-Again\",\"occupation\":\"N\\/A\",\"mobile\":\"09766375385\",\"email\":\"shushameow@gmail.com\",\"barangay\":\"Cutcot\",\"street\":\"Cutcot,Pulilan\",\"zip\":\"3005\",\"bloodType\":\"O+\",\"height\":\"167\",\"weight\":\"51\",\"allergies\":\"N\\/A\",\"conditions\":\"Asthma\",\"medications\":\"\",\"smoking\":\"Non-smoker\",\"alcohol\":\"None\",\"vaccination\":\"Complete (basic)\",\"obgyn\":\"\",\"preferredRhu\":\"\",\"preferredTime\":\"\",\"philhealthFile\":\"\",\"philhealthCardImage\":\"\",\"philhealthNum\":\"\",\"philhealthType\":\"\",\"philhealthStatus\":\"\",\"philhealthEmployer\":\"\",\"philhealthDependents\":\"\",\"seniorFile\":\"\",\"seniorCardImage\":\"\",\"pwdFile\":\"\",\"pwdCardImage\":\"\",\"fourPsFile\":\"\",\"fourPsCardImage\":\"\",\"soloParentFile\":\"\",\"soloParentCardImage\":\"\",\"isSenior\":false,\"scId\":\"\",\"isPwd\":true,\"pwdType\":\"\",\"pwdId\":\"\",\"toggle4ps\":false,\"fourPsNum\":\"\",\"toggleNhts\":false,\"toggleMalasakit\":false,\"toggleSoloParent\":false,\"soloParentId\":\"\",\"ecName\":\"Xevier Mione\",\"ecRelationship\":\"\",\"ecMobile\":\"09196256739\",\"ecAlt\":\"-\",\"ecAddress\":\"Sumapang Matanda\",\"accountEmail\":\"shushameow@gmail.com\",\"phone\":\"09766375385\",\"birthdate\":\"2003-02-06\",\"gender\":\"Female\",\"address\":\"Cutcot,Pulilan\",\"philhealthNo\":\"\"}', 0, NULL, '2026-07-28 12:42:55'),
(26, 'USR-026', 'Maro Delos', 'Santos', 'rommelde07@gmail.com', '$2y$10$IO8st9pTEqUagjL9BLVtou2WKrV8l/aNJMyJKvpdoPRMdHdqBD8R.', '09050469726', '2001-12-28', 'Male', '1576 Banga II Plaridel Bulacan', 'Longos', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"Maro Delos\",\"lastName\":\"Santos\",\"phone\":\"09050469726\",\"dob\":\"2001-12-28\",\"sex\":\"Male\",\"barangay\":\"Longos\",\"address\":\"1576 Banga II Plaridel Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 12:58:44'),
(27, 'USR-027', 'maro jr', 'marcelo', 'maromarcelo431@gmail.com', '$2y$10$jQm.C51w2.j9eDYhIW9fX.XUiEJJQ2n0cqbIdSrOTp8fBirDLhiF6', '09050469726', '2001-11-28', 'Male', 'Banga II Plaridel Bulacan', 'Dampol I', '', 0, 0, 0, NULL, 'Active', NULL, '{\"firstName\":\"maro jr\",\"lastName\":\"marcelo\",\"phone\":\"09050469726\",\"dob\":\"2001-11-28\",\"sex\":\"Male\",\"barangay\":\"Dampol I\",\"address\":\"Banga II Plaridel Bulacan\",\"isSenior\":false,\"isPwd\":false,\"is4ps\":false}', 0, NULL, '2026-07-28 13:03:34');

-- --------------------------------------------------------

--
-- Table structure for table `patient_access_history`
--

CREATE TABLE `patient_access_history` (
  `id` bigint(20) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `actor_type` enum('patient','admin','caregiver','system') NOT NULL,
  `actor_id` int(11) DEFAULT NULL,
  `actor_name` varchar(160) NOT NULL,
  `action` varchar(100) NOT NULL,
  `resource` varchar(100) NOT NULL,
  `purpose` varchar(190) NOT NULL,
  `branch` varchar(120) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient_access_history`
--

INSERT INTO `patient_access_history` (`id`, `patient_id`, `actor_type`, `actor_id`, `actor_name`, `action`, `resource`, `purpose`, `branch`, `created_at`) VALUES
(1, 2, 'patient', 2, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-20 17:16:17'),
(2, 2, 'patient', 2, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-20 17:20:39'),
(3, 8, 'patient', 8, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-24 08:24:16'),
(4, 10, 'patient', 10, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-24 08:26:30'),
(5, 10, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-24 08:30:04'),
(6, 10, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-24 08:37:14'),
(7, 10, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-24 08:37:20'),
(8, 11, 'patient', 11, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-24 08:44:22'),
(9, 11, 'patient', 11, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-24 08:44:28'),
(10, 2, 'admin', 2, 'RHU I Staff', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'RHU I - Poblacion', '2026-07-26 11:32:42'),
(11, 8, 'admin', 2, 'RHU I Staff', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'RHU I - Poblacion', '2026-07-26 11:32:50'),
(12, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 07:14:02'),
(13, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 07:14:11'),
(14, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 07:15:17'),
(15, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 08:10:49'),
(16, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 08:32:08'),
(17, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 08:33:56'),
(18, 12, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 08:40:44'),
(19, 14, 'patient', 14, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:46:23'),
(20, 14, 'patient', 14, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:46:26'),
(21, 9, 'patient', 9, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:47:33'),
(22, 13, 'patient', 13, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:47:54'),
(23, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:50:18'),
(24, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:51:42'),
(25, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:51:44'),
(26, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:51:46'),
(27, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:51:47'),
(28, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:51:47'),
(29, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:51:47'),
(30, 15, 'patient', 15, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-27 08:52:09'),
(31, 8, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 10:30:49'),
(32, 15, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 10:31:39'),
(33, 8, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 10:31:44'),
(34, 15, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 13:40:26'),
(35, 8, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 13:40:35'),
(36, 15, 'admin', 2, 'RHU I Staff', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'RHU I - Poblacion', '2026-07-27 14:46:05'),
(37, 15, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:06:45'),
(38, 15, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:09:59'),
(39, 14, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:10:03'),
(40, 13, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:10:06'),
(41, 12, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:10:08'),
(42, 11, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:10:11'),
(43, 10, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:10:14'),
(44, 9, 'admin', 1, 'System Administrator', 'Viewed patient record', 'Patient profile', 'Appointment or patient-service administration', 'All Branches', '2026-07-27 17:10:17'),
(45, 17, 'patient', 17, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 05:44:05'),
(46, 18, 'patient', 18, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 08:00:06'),
(47, 19, 'patient', 19, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:36:03'),
(48, 20, 'patient', 20, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:38:45'),
(49, 20, 'patient', 20, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:38:46'),
(50, 20, 'patient', 20, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:38:47'),
(51, 21, 'patient', 21, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:39:13'),
(52, 22, 'patient', 22, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:40:54'),
(53, 23, 'patient', 23, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:41:32'),
(54, 24, 'patient', 24, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:42:32'),
(55, 25, 'patient', 25, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:42:55'),
(56, 26, 'patient', 26, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:59:00'),
(57, 26, 'patient', 26, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 12:59:05'),
(58, 27, 'patient', 27, 'Patient', 'Accepted privacy policy', 'Privacy consent', 'Patient authorized portal processing under policy 1.0', NULL, '2026-07-28 13:13:55');

-- --------------------------------------------------------

--
-- Table structure for table `patient_consents`
--

CREATE TABLE `patient_consents` (
  `id` bigint(20) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `policy_id` int(11) NOT NULL,
  `status` enum('Accepted','Withdrawn') NOT NULL DEFAULT 'Accepted',
  `source` varchar(40) NOT NULL DEFAULT 'patient_portal',
  `accepted_at` datetime DEFAULT NULL,
  `withdrawn_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `patient_consents`
--

INSERT INTO `patient_consents` (`id`, `patient_id`, `policy_id`, `status`, `source`, `accepted_at`, `withdrawn_at`, `created_at`) VALUES
(1, 2, 1, 'Accepted', 'patient_portal', '2026-07-21 01:20:39', NULL, '2026-07-20 17:16:17'),
(3, 8, 1, 'Accepted', 'registration', '2026-07-24 16:24:16', NULL, '2026-07-24 08:24:16'),
(4, 10, 1, 'Accepted', 'registration', '2026-07-24 16:26:30', NULL, '2026-07-24 08:26:30'),
(5, 11, 1, 'Accepted', 'patient_portal', '2026-07-24 16:44:28', NULL, '2026-07-24 08:44:22'),
(7, 14, 1, 'Accepted', 'patient_portal', '2026-07-27 16:46:26', NULL, '2026-07-27 08:46:23'),
(9, 9, 1, 'Accepted', 'patient_portal', '2026-07-27 16:47:33', NULL, '2026-07-27 08:47:33'),
(10, 13, 1, 'Accepted', 'patient_portal', '2026-07-27 16:47:54', NULL, '2026-07-27 08:47:54'),
(11, 15, 1, 'Accepted', 'patient_portal', '2026-07-27 16:52:09', NULL, '2026-07-27 08:50:18'),
(19, 17, 1, 'Accepted', 'patient_portal', '2026-07-28 13:44:05', NULL, '2026-07-28 05:44:05'),
(20, 18, 1, 'Accepted', 'registration', '2026-07-28 16:00:06', NULL, '2026-07-28 08:00:06'),
(21, 19, 1, 'Accepted', 'registration', '2026-07-28 20:36:03', NULL, '2026-07-28 12:36:03'),
(22, 20, 1, 'Accepted', 'patient_portal', '2026-07-28 20:38:47', NULL, '2026-07-28 12:38:45'),
(25, 21, 1, 'Accepted', 'patient_portal', '2026-07-28 20:39:13', NULL, '2026-07-28 12:39:13'),
(26, 22, 1, 'Accepted', 'patient_portal', '2026-07-28 20:40:54', NULL, '2026-07-28 12:40:54'),
(27, 23, 1, 'Accepted', 'patient_portal', '2026-07-28 20:41:32', NULL, '2026-07-28 12:41:32'),
(28, 24, 1, 'Accepted', 'patient_portal', '2026-07-28 20:42:32', NULL, '2026-07-28 12:42:32'),
(29, 25, 1, 'Accepted', 'registration', '2026-07-28 20:42:55', NULL, '2026-07-28 12:42:55'),
(30, 26, 1, 'Accepted', 'patient_portal', '2026-07-28 20:59:05', NULL, '2026-07-28 12:59:00'),
(32, 27, 1, 'Accepted', 'patient_portal', '2026-07-28 21:13:55', NULL, '2026-07-28 13:13:55');

-- --------------------------------------------------------

--
-- Table structure for table `privacy_policy_versions`
--

CREATE TABLE `privacy_policy_versions` (
  `id` int(11) NOT NULL,
  `version_label` varchar(40) NOT NULL,
  `title` varchar(160) NOT NULL,
  `content` mediumtext NOT NULL,
  `retention_days` int(11) NOT NULL DEFAULT 1825,
  `status` enum('Draft','Published','Archived') NOT NULL DEFAULT 'Draft',
  `effective_at` datetime DEFAULT NULL,
  `created_by` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `privacy_policy_versions`
--

INSERT INTO `privacy_policy_versions` (`id`, `version_label`, `title`, `content`, `retention_days`, `status`, `effective_at`, `created_by`, `created_at`, `updated_at`) VALUES
(1, '1.0', 'Patient Privacy and Data Retention Policy', 'Pulilan Health Center collects identity, contact, appointment, queue, caregiver, and relevant health-classification information to provide RHU services, communicate schedule and queue updates, protect patient safety, and meet lawful public-health reporting duties. Access is limited to authorized personnel and approved caregivers for a stated purpose. Records are retained according to the published retention period, then reviewed for secure archival or lawful disposal. Patients may review their consent and access history, correct inaccurate profile information, withdraw optional portal consent, and contact the health center about privacy concerns. Withdrawal does not require deletion of records that must be kept for care, safety, audit, or legal obligations.', 1825, 'Published', '2026-07-20 23:07:14', NULL, '2026-07-20 15:07:14', '2026-07-20 15:07:14');

-- --------------------------------------------------------

--
-- Table structure for table `qr_arrival_tokens`
--

CREATE TABLE `qr_arrival_tokens` (
  `id` bigint(20) NOT NULL,
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `used_at` datetime DEFAULT NULL,
  `used_by_admin_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `qr_arrival_tokens`
--

INSERT INTO `qr_arrival_tokens` (`id`, `appointment_id`, `patient_id`, `token_hash`, `expires_at`, `used_at`, `used_by_admin_id`, `created_at`) VALUES
(8, 3, 2, 'e4612975c3f0f1366a83068d0c43312aa02176b5cdb26f13c8961c952d2c7ed0', '2026-07-21 23:59:59', NULL, NULL, '2026-07-21 15:43:17'),
(14, 4, 2, '9a4505e102f73abe8eed9fa8ce22b1b5d1a038cbcdda928c026da905588cbc76', '2026-07-22 23:59:59', NULL, NULL, '2026-07-22 02:05:58'),
(15, 5, 8, 'f7318cbad5c39f05f6a514fdf1029cd442b4e4c183605dd142f7c46c7e9da16d', '2026-07-31 23:59:59', NULL, NULL, '2026-07-24 08:30:27'),
(37, 15, 2, 'e0b4a5387154e9968d252d1e1274db12e5446bedf0daf1ed5631dda48feb613f', '2026-07-28 23:59:59', NULL, NULL, '2026-07-28 06:21:29'),
(40, 22, 19, '7dbbf89ed052c707f57fee22ac5c8e2151c68fec14fd099965a70816bf8abb25', '2026-07-29 23:59:59', NULL, NULL, '2026-07-28 12:40:12'),
(54, 27, 25, 'a650952f3664ae5f489254d004041d15fac8aa026f3a6c5d3a523a40a41b214f', '2026-07-29 23:59:59', NULL, NULL, '2026-07-28 15:11:03'),
(65, 18, 2, 'e86bda1ea65df503dc2710b89d397916351472d568fc72c24fdf8284ee2f3053', '2026-07-29 23:59:59', NULL, NULL, '2026-07-28 16:49:27');

-- --------------------------------------------------------

--
-- Table structure for table `queue_proximity_alerts`
--

CREATE TABLE `queue_proximity_alerts` (
  `appointment_id` int(11) NOT NULL,
  `patient_id` int(11) NOT NULL,
  `people_ahead` int(11) NOT NULL,
  `notified_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `queue_proximity_alerts`
--

INSERT INTO `queue_proximity_alerts` (`appointment_id`, `patient_id`, `people_ahead`, `notified_at`) VALUES
(8, 2, 0, '2026-07-27 08:44:23'),
(9, 12, 0, '2026-07-27 08:39:01'),
(15, 2, 0, '2026-07-28 08:06:51');

-- --------------------------------------------------------

--
-- Table structure for table `sms_logs`
--

CREATE TABLE `sms_logs` (
  `id` int(11) NOT NULL,
  `patient_id` int(11) DEFAULT NULL,
  `appointment_id` int(11) DEFAULT NULL,
  `recipient` varchar(30) NOT NULL,
  `event_type` varchar(50) NOT NULL,
  `message` text NOT NULL,
  `status` varchar(30) NOT NULL DEFAULT 'pending',
  `provider_message_id` varchar(150) DEFAULT NULL,
  `provider_response` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `system_settings`
--

CREATE TABLE `system_settings` (
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_by` int(11) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admins`
--
ALTER TABLE `admins`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `announcements`
--
ALTER TABLE `announcements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_announcements_branch_status` (`branch`,`status`,`created_at`);

--
-- Indexes for table `announcement_reads`
--
ALTER TABLE `announcement_reads`
  ADD PRIMARY KEY (`announcement_id`,`patient_id`),
  ADD KEY `idx_announcement_reads_patient` (`patient_id`,`read_at`);

--
-- Indexes for table `appointments`
--
ALTER TABLE `appointments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `appointment_queue_sequences`
--
ALTER TABLE `appointment_queue_sequences`
  ADD PRIMARY KEY (`branch`,`appointment_date`,`prefix`);

--
-- Indexes for table `appointment_waitlist`
--
ALTER TABLE `appointment_waitlist`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_active_waitlist` (`patient_id`,`center`,`service`,`appointment_date`,`appointment_time`),
  ADD KEY `idx_waitlist_match` (`center`,`service`,`appointment_date`,`appointment_time`,`status`,`created_at`);

--
-- Indexes for table `audit_events`
--
ALTER TABLE `audit_events`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_audit_created` (`created_at`),
  ADD KEY `idx_audit_role` (`role`),
  ADD KEY `idx_audit_module` (`module`);

--
-- Indexes for table `audit_logs`
--
ALTER TABLE `audit_logs`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `booking_slot_locks`
--
ALTER TABLE `booking_slot_locks`
  ADD PRIMARY KEY (`branch`,`service`,`appointment_date`,`appointment_time`);

--
-- Indexes for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_chat_patient` (`patient_id`,`id`);

--
-- Indexes for table `chat_thread_status`
--
ALTER TABLE `chat_thread_status`
  ADD PRIMARY KEY (`patient_id`),
  ADD KEY `idx_chat_thread_status` (`status`,`updated_at`);

--
-- Indexes for table `clinic_capacity_rules`
--
ALTER TABLE `clinic_capacity_rules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_capacity_rule` (`branch`,`service`);

--
-- Indexes for table `clinic_closures`
--
ALTER TABLE `clinic_closures`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_clinic_closure_lookup` (`closure_date`,`status`,`branch`,`service`);

--
-- Indexes for table `clinic_schedules`
--
ALTER TABLE `clinic_schedules`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_clinic_schedule` (`branch`,`day_of_week`);

--
-- Indexes for table `disease_cases`
--
ALTER TABLE `disease_cases`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_disease_appointment_date` (`appointment_id`,`disease_category`,`case_date`),
  ADD KEY `idx_disease_date` (`case_date`),
  ADD KEY `idx_disease_category` (`disease_category`),
  ADD KEY `idx_disease_barangay` (`barangay`),
  ADD KEY `idx_disease_rhu` (`rhu_branch`);

--
-- Indexes for table `email_logs`
--
ALTER TABLE `email_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_email_patient` (`patient_id`,`created_at`),
  ADD KEY `idx_email_appointment` (`appointment_id`,`created_at`);

--
-- Indexes for table `family_care_links`
--
ALTER TABLE `family_care_links`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_family_pair` (`caregiver_patient_id`,`dependent_patient_id`),
  ADD KEY `idx_family_dependent_status` (`dependent_patient_id`,`status`);

--
-- Indexes for table `login_attempts`
--
ALTER TABLE `login_attempts`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_login_scope_identity_ip` (`scope`,`identity_hash`,`ip_hash`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_notification_dedupe` (`patient_id`,`dedupe_key`),
  ADD KEY `idx_notifications_patient` (`patient_id`,`is_read`,`created_at`);

--
-- Indexes for table `notification_delivery_logs`
--
ALTER TABLE `notification_delivery_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_delivery_health` (`status`,`channel`,`created_at`),
  ADD KEY `idx_delivery_patient` (`patient_id`,`created_at`);

--
-- Indexes for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_token_hash` (`token_hash`),
  ADD KEY `idx_email` (`email`),
  ADD KEY `patient_id` (`patient_id`);

--
-- Indexes for table `patients`
--
ALTER TABLE `patients`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`),
  ADD UNIQUE KEY `patient_code` (`patient_code`);

--
-- Indexes for table `patient_access_history`
--
ALTER TABLE `patient_access_history`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_access_patient` (`patient_id`,`created_at`),
  ADD KEY `idx_access_actor` (`actor_type`,`actor_id`,`created_at`);

--
-- Indexes for table `patient_consents`
--
ALTER TABLE `patient_consents`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uniq_patient_policy_consent` (`patient_id`,`policy_id`),
  ADD KEY `idx_consent_current` (`patient_id`,`status`,`accepted_at`);

--
-- Indexes for table `privacy_policy_versions`
--
ALTER TABLE `privacy_policy_versions`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `version_label` (`version_label`),
  ADD KEY `idx_privacy_current` (`status`,`effective_at`);

--
-- Indexes for table `qr_arrival_tokens`
--
ALTER TABLE `qr_arrival_tokens`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `idx_qr_appointment` (`appointment_id`,`used_at`),
  ADD KEY `idx_qr_recent` (`used_at`,`used_by_admin_id`);

--
-- Indexes for table `queue_proximity_alerts`
--
ALTER TABLE `queue_proximity_alerts`
  ADD PRIMARY KEY (`appointment_id`),
  ADD KEY `idx_queue_proximity_patient` (`patient_id`,`notified_at`);

--
-- Indexes for table `sms_logs`
--
ALTER TABLE `sms_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_sms_patient` (`patient_id`,`created_at`),
  ADD KEY `idx_sms_appointment` (`appointment_id`,`created_at`);

--
-- Indexes for table `system_settings`
--
ALTER TABLE `system_settings`
  ADD PRIMARY KEY (`setting_key`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admins`
--
ALTER TABLE `admins`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95762;

--
-- AUTO_INCREMENT for table `announcements`
--
ALTER TABLE `announcements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `appointments`
--
ALTER TABLE `appointments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT for table `appointment_waitlist`
--
ALTER TABLE `appointment_waitlist`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `audit_events`
--
ALTER TABLE `audit_events`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `audit_logs`
--
ALTER TABLE `audit_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1305;

--
-- AUTO_INCREMENT for table `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=69;

--
-- AUTO_INCREMENT for table `clinic_capacity_rules`
--
ALTER TABLE `clinic_capacity_rules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7793;

--
-- AUTO_INCREMENT for table `clinic_closures`
--
ALTER TABLE `clinic_closures`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `clinic_schedules`
--
ALTER TABLE `clinic_schedules`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=54545;

--
-- AUTO_INCREMENT for table `disease_cases`
--
ALTER TABLE `disease_cases`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `email_logs`
--
ALTER TABLE `email_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=101;

--
-- AUTO_INCREMENT for table `family_care_links`
--
ALTER TABLE `family_care_links`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `login_attempts`
--
ALTER TABLE `login_attempts`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=72;

--
-- AUTO_INCREMENT for table `notification_delivery_logs`
--
ALTER TABLE `notification_delivery_logs`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=67;

--
-- AUTO_INCREMENT for table `password_resets`
--
ALTER TABLE `password_resets`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT for table `patients`
--
ALTER TABLE `patients`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `patient_access_history`
--
ALTER TABLE `patient_access_history`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=59;

--
-- AUTO_INCREMENT for table `patient_consents`
--
ALTER TABLE `patient_consents`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `privacy_policy_versions`
--
ALTER TABLE `privacy_policy_versions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `qr_arrival_tokens`
--
ALTER TABLE `qr_arrival_tokens`
  MODIFY `id` bigint(20) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=66;

--
-- AUTO_INCREMENT for table `sms_logs`
--
ALTER TABLE `sms_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `appointments`
--
ALTER TABLE `appointments`
  ADD CONSTRAINT `appointments_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `fk_chat_patient` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `password_resets`
--
ALTER TABLE `password_resets`
  ADD CONSTRAINT `password_resets_ibfk_1` FOREIGN KEY (`patient_id`) REFERENCES `patients` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

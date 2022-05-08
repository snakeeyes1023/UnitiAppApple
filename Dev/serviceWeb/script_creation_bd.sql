-- phpMyAdmin SQL Dump
-- version 4.9.7
-- https://www.phpmyadmin.net/
--
-- Hôte : localhost:3306
-- Généré le : Dim 08 mai 2022 à 16:04
-- Version du serveur :  10.3.34-MariaDB-cll-lve
-- Version de PHP : 7.3.33

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `jonath37_unitiMobile`
--
CREATE DATABASE IF NOT EXISTS `jonath37_unitiMobile` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `jonath37_unitiMobile`;

-- --------------------------------------------------------

--
-- Structure de la table `loyers`
--

CREATE TABLE `loyers` (
  `id` int(11) NOT NULL,
  `nom` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `grandeur` double NOT NULL,
  `longitude` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lattitude` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `prix` double NOT NULL,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dispo` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Déchargement des données de la table `loyers`
--

INSERT INTO `loyers` (`id`, `nom`, `grandeur`, `longitude`, `lattitude`, `prix`, `uuid`, `dispo`) VALUES
(6, 'Avenue Forand', 4.5, '-71.76659442028657', '46.22509765625', 250, '532E6CF5-C013-4EF9-9D7D-6FB473EEC321', 0),
(9, 'Ajout ', 4.5, '-71.7666706021542', '46.22509765625', 100, '98362890-E80B-4E3F-AF0F-D45B557EDAC9', 1),
(11, 'Test 45', 7, '-71.76662632583933', '46.225128173828125', 250, '1AF7D772-4601-4A7F-BBF8-3AFA12A98040', 0);

--
-- Index pour les tables déchargées
--

--
-- Index pour la table `loyers`
--
ALTER TABLE `loyers`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT pour les tables déchargées
--

--
-- AUTO_INCREMENT pour la table `loyers`
--
ALTER TABLE `loyers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

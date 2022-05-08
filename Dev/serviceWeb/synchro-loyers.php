<?php

/**
 * Synchronisation à sens unique des données locales vers MySQL.
 *
 * L'application qui consomme ce service Web doit fournir des données par POST au format :
 * [
 *     {"id": 99, "uuid": "...", "prenom": "...", "nomfamille": "..."},
 *     {"id": 99, "uuid": "...", "prenom": "...", "nomfamille": "..."}
 * ]
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 * @return String chaîne JSON au format :
 * {
 *     "erreurs" : [
 *         {"code" : 99, "message" : "..."},
 *         {"code" : 99, "uuid" : "...", "message" : "..."}
 *     ],
 *     "ajouts" : {"UUID1", "UUID2", ...},
 *     "modifications" :{"UUID3", "UUID4", ...},
 *     "suppressions" :{"UUID5", "UUID6", ...}
 * }
 *
 * Codes d'erreurs : 1 : Accès refusé.
 *                   2 : Échec lors de la connexion à la base de données.
 *                   3 : Aucune donnée locale à synchroniser n'a été reçue.
 *                   4 : Il n'est pas possible de synchroniser les ajouts et les modifications.
 *                   5 : Il n'est pas possible de vérifier s'il y a des enregistrements à supprimer dans la base de données distante.
 *                   6 : L'ajout d'un enregistrement a échoué.
 *                   7 : La mise à jour d'un enregistrement a échoué.
 *                   8 : La suppression d'un enregistrement a échoué.
 */

// Configurations
// *****************************************************************

//BD model
//INSERT INTO `loyers` (`id`, `nom`, `grandeur`, `longitude`, `lattitude`, `prix`, `uuid`, `dispo`) VALUES ('', '', '', '', '', '', '', '')

$serveurBD='70.32.23.53';
$usagerBD = 'jonath37_unitiMobile';
$motDePasseBD = '2$5(5_S(-8%K';
$nomBD = 'jonath37_unitiMobile';


// *** Fin configurations ******************************************


// Le dossier du fichier journal (log) doit exister au même niveau que le dossier du service Web.
$dossierRacineServeur = dirname(__FILE__, 2);
define('LOG_FILE', $dossierRacineServeur . DIRECTORY_SEPARATOR . 'log' . DIRECTORY_SEPARATOR . 'apifactures.log');


$messageAccesRefuse = "Accès refusé.";
$codeAccesRefuse = 1;

$messageErreurConnexion = "Échec lors de la connexion à la base de données.";
$codeErreurConnexion = 2;


$messageErreurPost = "Aucune donnée locale à synchroniser n'a été reçue.";
$codeErreurPost = 3;


$messageErreurSynchroAjout = "Il n'est pas possible de synchroniser les ajouts et les modifications.";
$codeErreurSynchroAjout = 4;


$messageErreurSynchroSuppression = "Il n'est pas possible de vérifier s'il y a des enregistrements à supprimer dans la base de données distante.";
$codeErreurSynchroSuppression = 5;


$messageErreurAjout = "L'ajout d'un enregistrement a échoué.";
$codeErreurAjout = 6;

$messageErreurMiseAJour = "La mise à jour d'un enregistrement a échoué.";
$codeErreurMiseAJour = 7;


$messageErreurSuppression = "La suppression d'un enregistrement a échoué.";
$codeErreurSuppression = 8;


$retour = [];


// Vérification des droits
// *****************************************************************
// ...

// Branchement à la base de données (PHP 7.x)
// *****************************************************************
@$mysqli = new mysqli($serveurBD, $usagerBD, $motDePasseBD, $nomBD);


if ($mysqli->connect_errno) {
    log_error($messageErreurConnexion);
    $retour['erreurs'][] = ['code' => $codeErreurConnexion,'message' => $messageErreurConnexion];
}
else {
    $mysqli->set_charset("utf8");


    // Récupération des données envoyées par l'application mobile
    // *****************************************************************
    $json = file_get_contents('php://input'); // $_POST ne fonctionne que pour les Content-Type application/x-www-form-urlencoded ou multipart/form-data


    if ($json == null) {
         log_error($messageErreurPost);
         $retour['erreurs'][] = ['code' => $codeErreurPost, 'message' => $messageErreurPost];
    }
    else {
        $clientsSqlite = json_decode($json);

        //log_info("Données reçues :");
        //log_info($clientsSqlite);


        // Recherche des enregistrements à supprimer
        // *****************************************************************
        $requete = "SELECT uuid, nom FROM loyers";
        $resultat = $mysqli->query($requete);

        if (!$resultat) {
            log_error("$messageErreurSynchroSuppression - $mysqli->error");
            $retour['erreurs'][] = ['code' => $codeErreurSynchroSuppression, 'message' => $messageErreurSynchroSuppression];
        }
        else {
            if ($mysqli->affected_rows > 0) {

                while ($enreg = $resultat->fetch_row()) {
                    // L'enregistrement n'est pas dans SQLite : on le supprime.
                    // *****************************************************************
                    if (!presentDansTableauDObjets($enreg[0], $clientsSqlite, 'uuid')) {
                        if (suppressionLoyer($enreg[0], $enreg[1])) {
                            $retour['suppressions'][] = $enreg[0];
                        }
                    }
                }
            }

            $resultat->free();
        }

 

        // Recherche des enregistrements à ajouter ou à modifier
        // *****************************************************************
        $requete = "SELECT nom, grandeur, longitude, lattitude, prix, uuid, dispo FROM loyers WHERE uuid = ?";
        $stmt = $mysqli->prepare($requete);

        if (!$stmt) {
             log_error("$messageErreurSynchroAjout - $mysqli->error");
             $retour['erreurs'][] = ['code' => $codeErreurSynchroAjout, 'message' => $messageErreurSynchroAjout];
        }
        else {

            foreach($clientsSqlite as $clientSqlite) {
                 $stmt->bind_param('s', $clientSqlite->uuid);
                 $stmt->execute();
                 $stmt->store_result();


                if ($stmt->errno != 0) {
                     log_error("$messageErreurSynchroAjout - uuid: $clientSqlite->uuid - nom: $clientSqlite->nom - stmt->error");
                     $retour['erreurs'][] = ['code' => $codeErreurSynchroAjout, 'uuid' => $clientSqlite->uuid, 'message' => $messageErreurSynchroAjout];
                 }
                 else {
                     // L'enregistrement existait dans la BD distante.
                     // *****************************************************************
                     if ($stmt->num_rows > 0) {
                         $stmt->bind_result($nom, $grandeur, $longitude, $lattitude, $prix, $uuid, $dispo);

                         $stmt->fetch();

                         // L'enregistrement est différent : on fait la mise à jour.
                         // *****************************************************************
                         if ($clientSqlite->nom != $nom || $clientSqlite->grandeur != $grandeur || $clientSqlite->longitude != $longitude || $clientSqlite->lattitude != $lattitude || $clientSqlite->prix != $prix || $clientSqlite->dispo != $dispo) {
                             if (miseAjourLoyer($clientSqlite->uuid, $clientSqlite->nom, $clientSqlite->grandeur, $clientSqlite->longitude, $clientSqlite->lattitude, $clientSqlite->prix, $clientSqlite->dispo)) {
                                 $retour['modifications'][] = $clientSqlite->uuid;
                             }
                         }
                     }
                     else {
                         // L'enregistrement n'existait pas : on l'ajoute.
                         // *****************************************************************
                         if (ajoutLoyer($clientSqlite->uuid, $clientSqlite->nom, $clientSqlite->grandeur, $clientSqlite->longitude, $clientSqlite->lattitude, $clientSqlite->prix, $clientSqlite->dispo)) {
                             $retour['ajouts'][] = $clientSqlite->uuid;
                         }
                     }
                 }
            }

            $stmt->close();
        }
    }
}

//log_info("Informations retournées :");
//log_info($retour);

 

// Retour des informations à l'application mobile
// *****************************************************************
// Remarquez que les paramètres JSON_PRETTY_PRINT, JSON_UNESCAPED_UNICODE et JSON_UNESCAPED_SLASHES assurent les caractères spéciaux seront correctement encodés.
echo json_encode($retour, JSON_PRETTY_PRINT | JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);


/**
 * Met à jour le client dans la BD distante selon son UUID.
 *
 * @param String $uuid       Identifiant unique universel du client.
 * @param String $prenom     Prénom à enregistrer.
 * @param String $nomfamille Nom de famille à enregistrer.
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 * @return bool True si l'opération a réussi.
 *
 */
function miseAjourLoyer($uuid, $nom, $grandeur, $longitude, $lattitude, $prix, $dispo) {
    global $mysqli;
    global $messageErreurMiseAJour;
    global $codeErreurMiseAJour;
    $retour = false;

    $requete = "UPDATE loyers SET nom = ?, grandeur = ?, longitude = ?, lattitude = ?, prix = ?, dispo = ? WHERE uuid = ?";
    $stmt = $mysqli->prepare($requete);

    if ($stmt) {

        $stmt->bind_param('sdssdis', $nom, $grandeur, $longitude, $lattitude, $prix, $dispo, $uuid);
        $stmt->execute();

        if (0 == $stmt->errno) {
            $retour = true;
        }
        else {
            log_error("$messageErreurMiseAJour - uuid: $uuid - nom: $nom - grandeur: $grandeur - longitude: $longitude - lattitude: $lattitude - prix: $prix - dispo: $dispo - $stmt->error");
            $retour['erreurs'][] = ['code' => $codeErreurMiseAJour, 'uuid' => $uuid, 'message' => $messageErreurMiseAJour];

            $retour = false;
        }

        $stmt->close();
    }
    else {
        log_error("$messageErreurMiseAJour - uuid: $uuid - nom: $nom - grandeur: $grandeur - longitude: $longitude - lattitude: $lattitude - prix: $prix - dispo: $dispo");
        $retour['erreurs'][] = ['code' => $codeErreurMiseAJour, 'uuid' => $uuid, 'message' => $messageErreurMiseAJour];

        $retour = false;
    }

    return $retour;
}


/**
 * Ajoute un client dans la BD distante.
 *
 * @param String $uuid       Identifiant unique universel à enregistrer.
 * @param String $prenom     Prénom à enregistrer.
 * @param String $nomfamille Nom de famille à enregistrer.
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 * @return bool True si l'opération a réussi.
 *
 */
function ajoutLoyer($uuid, $nom, $grandeur, $longitude, $lattitude, $prix, $dispo) {
    global $mysqli;
    global $messageErreurAjout;
    global $codeErreurAjout;
    $retour = false;

    $requete = "INSERT INTO loyers (uuid, nom, grandeur, longitude, lattitude, prix, dispo) VALUES (?, ?, ?, ?, ?, ?, ?)";
    $stmt = $mysqli->prepare($requete);

    if ($stmt) {

        $stmt->bind_param('ssdssdi', $uuid, $nom, $grandeur, $longitude, $lattitude, $prix, $dispo);
        $stmt->execute();

        if (0 == $stmt->errno) {
            $retour = true;
        }
        else {
            log_error("$messageErreurAjout - uuid: $uuid - nom: $nom - grandeur: $grandeur - longitude: $longitude - lattitude: $lattitude - prix: $prix - dispo: $dispo - $stmt->error");
            $retour['erreurs'][] = ['code' => $codeErreurAjout, 'uuid' => $uuid, 'message' => $messageErreurAjout];

            $retour = false;
        }

        $stmt->close();
    }
    else {
        log_error("$messageErreurAjout - uuid: $uuid - nom: $nom - grandeur: $grandeur - longitude: $longitude - lattitude: $lattitude - prix: $prix - dispo: $dispo - $mysqli->error");
        $retour['erreurs'][] = ['code' => $codeErreurAjout, 'uuid' => $uuid, 'message' => $messageErreurAjout];

        $retour = false;
    }

    return $retour;
}


/**
 * Supprime un client de la BD distante selon son UUID.
 *
 * @param String $uuid       Identifiant unique universel du client.
 * @param String $nomfamille Nom de famille du client.
 * @param String $prenom     Prénom du client.
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 * @return bool True si l'opération a réussi.
 *
 */
function suppressionLoyer($uuid, $nom) {
    global $mysqli;
    global $messageErreurSuppression;
    global $codeErreurSuppression;
    $retour = false;

    $requete = "DELETE FROM loyers WHERE uuid = ?";
    $stmt = $mysqli->prepare($requete);

    if ($stmt) {

        $stmt->bind_param('s', $uuid);
        $stmt->execute();

        if (0 == $stmt->errno) {
            $retour = true;
        }
        else {
            log_error("$messageErreurSuppression - uuid: $uuid - nom: $nom - $stmt->error");
            $retour['erreurs'][] = ['code' => $codeErreurSuppression, 'uuid' => $uuid, 'message' => $messageErreurSuppression];

            $retour = false;
        }

        $stmt->close();
    }
    else {
        log_error("$messageErreurSuppression - uuid: $uuid - nom: $nom - $mysqli->error");
        $retour['erreurs'][] = ['code' => $codeErreurSuppression, 'uuid' => $uuid, 'message' => $messageErreurSuppression];

        $retour = false;
    }

    return $retour;
}


/**
 * Recherche une valeur dans un tableau d'objets.
 *
 * @param mixed $valeur Valeur recherchée.
 * @param array $tableau Tableau d'objets dans lequel on effectue la recherche.
 * @param string $champ Nom du champ dans lequel on recherche la valeur.
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 * @return bool True si la valeur a été trouvée.
 *
 */
function presentDansTableauDObjets($valeur, $tableau, $champ) {
    $retour = false;


    foreach($tableau as $objet) {
        if ($objet->$champ == $valeur) {
            $retour = true;
            break;
        }
    }


    return $retour;
}

 

/**
 * Enregistre la date suivie d'un message d'information dans le fichier journal.
 *
 * Suppositions critiques : Le chemin complet du fichier dont le nom et le chemin sont dans la constante LOG_FILE doit exister (le fichier sera créé s'il n'existe pas).
 * Les droits sur ce fichier et/ou son dossier doivent permettre au serveur Web de lire et d'écrire dans ce fichier.
 *
 * @param String $message Message à inscrire dans le journal.
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 */
function log_info($message) {
    if (is_array($message) || is_object($message)) {
        $message = print_r($message, true);
    }


    if (defined('LOG_FILE')) {
        error_log(date("F j, Y, g:i a") . " - Information: $message" . PHP_EOL, 3, LOG_FILE);
    }
    else {
        error_log(date("F j, Y, g:i a") . " - Information: $message". PHP_EOL);
    }
}


/**
 * Enregistre la date suivie d'un message d'erreur dans le fichier journal.
 *
 * Suppositions critiques : Le chemin complet du fichier dont le nom et le chemin sont dans la constante LOG_FILE doit exister (le fichier sera créé s'il n'existe pas).
 * Les droits sur ce fichier et/ou son dossier doivent permettre au serveur Web de lire et d'écrire dans ce fichier.
 *
 * @param String $message Message à inscrire dans le journal.
 *
 * @author Christiane Lagacé <christianelagace.com>
 *
 */
function log_error($message) {
    if (is_array($message) || is_object($message)) {
        $message = print_r($message, true);
    }


    if (defined('LOG_FILE')) {
        error_log(date("F j, Y, g:i a") . " - Erreur: $message" . PHP_EOL, 3, LOG_FILE);
    }
    else {
        error_log(date("F j, Y, g:i a") . " - Erreur: $message". PHP_EOL);
    }
}

?>
//
//  GestionBD.swift
//  GestionObjetConnecte
//
//  Code des note de cours BD apical
//

import Foundation
import SQLite3
import SwiftUI

/// Gestion d'une base de données SQLite.
/// Code des notes de cours BD apical
class GestionBD {
  var nomBD: String = ""
  var pointeurBD: OpaquePointer? = nil

  /**
   Constructeur.

   - Parameters:
     - nomBD: nom de la base de données
  */
  init(nomBD: String) {
    self.nomBD = nomBD
  }

   /**
    Ouvre la base de données et initialise la propriété pointeurBD.
   */
  func ouvrirBD() {
    var reussi: Bool = false

    do {
      let fileManager = FileManager.default

      let urlApplicationSupport = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        .appendingPathComponent(nomBD)
      // print(urlApplicationSupport)

      // ouvre la base de données mais ne la crée pas si elle n'existe pas
      var codeRetour = sqlite3_open_v2(urlApplicationSupport.path, &pointeurBD, SQLITE_OPEN_READWRITE, nil)

      // si la base de données n'est pas trouvée, va chercher la version originale dans le paquet de l'application
      if codeRetour == SQLITE_CANTOPEN {
        print("Tentative de retrouver la base de données dans le paquet.")

        if let urlPaquet = Bundle.main.url(forResource: nomBD, withExtension: "") { // ici, l'extension fait déjà partie du nom de la BD
          // print(urlPaquet)

          try fileManager.copyItem(at: urlPaquet, to: urlApplicationSupport)
          codeRetour = sqlite3_open_v2(urlApplicationSupport.path, &pointeurBD, SQLITE_OPEN_READWRITE, nil)
        } else {
          print("Erreur : la base de données ne fait pas partie du paquet.")
        }
      }

      if codeRetour == SQLITE_OK {
        reussi = true;
      } else {
        print("La connexion à la base de données a échoué : \(codeRetour)")
      }

    } catch {
      print("Erreur inattendue : \(error)")
    }

    if (!reussi) {
      // Selon la doc officielle : Whether or not an error occurs when it is opened, resources associated with the database connection handle should be released by passing it to sqlite3_close() when it is no longer required (source : https://www.sqlite.org/c3ref/open.html).
      sqlite3_close(pointeurBD)
      pointeurBD = nil
    }
  }
    

/**
  Retrouve la liste des loyers dans la base de données en ordre de nom.

 - Returns: Liste des loyers.
*/
func listeLoyers() -> [Loyer] {
  let requete: String = "SELECT id, nom, grandeur, prix, uuid, dispo, longitude, lattitude FROM loyers ORDER BY nom"
  var loyers: [Loyer] = []
  var preparation: OpaquePointer? = nil

  // prépare la requête
  if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

    // exécute la requête
    while sqlite3_step(preparation) == SQLITE_ROW {

      let id = Int(sqlite3_column_int(preparation, 0))
      let nom = String(cString: sqlite3_column_text(preparation, 1))
      let grandeur = Double(sqlite3_column_double(preparation, 2))
      let prix = Double(sqlite3_column_double(preparation, 3))
      let uuid = String(cString: sqlite3_column_text(preparation, 4))
      let dispo = Int(sqlite3_column_int(preparation, 5)) == 1
      let longitude = String(cString: sqlite3_column_text(preparation, 5))
      let lattitude = String(cString: sqlite3_column_text(preparation, 6))

      loyers.append(Loyer(id: id, nom: nom, grandeur: grandeur, longitude: longitude, lattitude: lattitude, prix: prix, uuid: uuid, dispo: dispo))
    }
  } else {
    let erreur = String(cString: sqlite3_errmsg(pointeurBD))
    print("\nLa requête n'a pas pu être préparée : \(erreur)")
  }

  // libération de la mémoire
  sqlite3_finalize(preparation)

  return loyers
}

/**
  Ajouter un loyer dans la base de données.

 - Returns: True si l'ajout a réussi, False sinon.
*/
func ajouterLoyer(nom: String, grandeur: Double, prix: Double, longitude: String, lattitude: String) -> Bool {
  var reussi: Bool = false
  //generer uuid
  let uuid = UUID().uuidString

  let requete: String = "INSERT INTO loyers (nom, grandeur, prix, uuid, dispo, longitude, lattitude) VALUES (?, ?, ?, ?, ?, ?, ?)"
  var preparation: OpaquePointer? = nil

  // prépare la requête
  if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

    // ajoute les paramètres
    sqlite3_bind_text(preparation, 0, nom, -1, nil)
    sqlite3_bind_double(preparation, 1, grandeur)
    sqlite3_bind_double(preparation, 2, prix)
    sqlite3_bind_text(preparation, 3, uuid, -1, nil)
    sqlite3_bind_int(preparation, 4, 1)
    sqlite3_bind_text(preparation, 5, longitude, -1, nil)
    sqlite3_bind_text(preparation, 6, lattitude, -1, nil)


    // exécute la requête
    if sqlite3_step(preparation) == SQLITE_DONE {
      reussi = true
    } else {
      let erreur = String(cString: sqlite3_errmsg(pointeurBD))
      print("\nLa requête n'a pas pu être exécutée : \(erreur)")
    }
  } else {
    let erreur = String(cString: sqlite3_errmsg(pointeurBD))
    print("\nLa requête n'a pas pu être préparée : \(erreur)")
  }

  // libération de la mémoire
  sqlite3_finalize(preparation)

  return reussi
}

/*
  Supprimer un loyer dans la base de données.

 - Returns: True si la modification a réussi, False sinon.
*/
func supprimerLoyer(id : Int) -> Bool
{
  let requete: String = "DELETE FROM loyers WHERE id = ?"
  var preparation: OpaquePointer? = nil
  var resultat: Bool = false
  // prépare la requête
  if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

    // ajoute les paramètres
    sqlite3_bind_int(preparation, 1, Int32(id))

    // exécute la requête
    if sqlite3_step(preparation) == SQLITE_DONE {
      print("Loyer supprimé")
      resultat = true
    } else {
      let erreur = String(cString: sqlite3_errmsg(pointeurBD))
      print("\nLa requête n'a pas pu être exécutée : \(erreur)")
    }
  } else {
    let erreur = String(cString: sqlite3_errmsg(pointeurBD))
    print("\nLa requête n'a pas pu être préparée : \(erreur)")
  }

  // libération de la mémoire
  sqlite3_finalize(preparation)

  return resultat
}

func modifierLoyer(id: Int, nom: String, prix: Double, grandeur: Double, longitude: String, lattitude: String) -> Bool
{
  let requete: String = "UPDATE loyers SET nom = ?, prix = ?, grandeur = ? WHERE id = ?"
  var preparation: OpaquePointer? = nil
  var resultat: Bool = false
  // prépare la requête
  if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

    // ajoute les paramètres
    sqlite3_bind_text(preparation, 0, nom, -1, nil)
    sqlite3_bind_double(preparation, 1, prix)
    sqlite3_bind_double(preparation, 2, grandeur)
    sqlite3_bind_int(preparation, 3, Int32(id))
    sqlite3_bind_text(preparation, 4, longitude, -1, nil)
    sqlite3_bind_text(preparation, 5, lattitude, -1, nil)

    // exécute la requête
    if sqlite3_step(preparation) == SQLITE_DONE {
      print("Loyer modifié")
      resultat = true
    } else {
      let erreur = String(cString: sqlite3_errmsg(pointeurBD))
      print("\nLa requête n'a pas pu être exécutée : \(erreur)")
    }
  } else {
    let erreur = String(cString: sqlite3_errmsg(pointeurBD))
    print("\nLa requête n'a pas pu être préparée : \(erreur)")
  }

  // libération de la mémoire
  sqlite3_finalize(preparation)
  return resultat

}
}

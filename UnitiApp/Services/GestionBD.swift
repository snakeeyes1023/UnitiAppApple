//
//  GestionBD.swift
//  Jonathan Côté
//
//  Code grandement inspiré des notes de cours BD apical
//

import Foundation
import SQLite3
import SwiftUI

/// Gestion d'une base de données SQLite.
/// Code grandement inspiré des notes de cours BD apical
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

      let urlApplicationSupport = try fileManager.url(
        for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true
      )
      .appendingPathComponent(nomBD)
      // print(urlApplicationSupport)

      // ouvre la base de données mais ne la crée pas si elle n'existe pas
      var codeRetour = sqlite3_open_v2(
        urlApplicationSupport.path, &pointeurBD, SQLITE_OPEN_READWRITE, nil)

      // si la base de données n'est pas trouvée, va chercher la version originale dans le paquet de l'application
      if codeRetour == SQLITE_CANTOPEN {
        print("Tentative de retrouver la base de données dans le paquet.")

        if let urlPaquet = Bundle.main.url(forResource: nomBD, withExtension: "") {  // ici, l'extension fait déjà partie du nom de la BD
          // print(urlPaquet)

          try fileManager.copyItem(at: urlPaquet, to: urlApplicationSupport)
          codeRetour = sqlite3_open_v2(
            urlApplicationSupport.path, &pointeurBD, SQLITE_OPEN_READWRITE, nil)
        } else {
          print("Erreur : la base de données ne fait pas partie du paquet.")
        }
      }

      if codeRetour == SQLITE_OK {
        reussi = true
      } else {
        print("La connexion à la base de données a échoué : \(codeRetour)")
      }

    } catch {
      print("Erreur inattendue : \(error)")
    }

    if !reussi {
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
    let requete: String =
      "SELECT id, nom, grandeur, prix, uuid, dispo, longitude, lattitude FROM loyers ORDER BY nom"
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
        let longitude = String(cString: sqlite3_column_text(preparation, 6))
        let lattitude = String(cString: sqlite3_column_text(preparation, 7))

        loyers.append(
          Loyer(
            id: id, nom: nom, grandeur: grandeur, longitude: longitude, lattitude: lattitude,
            prix: prix, uuid: uuid, dispo: dispo))
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
  func ajouterLoyer(
    nom: String, grandeur: Double, prix: Double, longitude: String, lattitude: String
  ) -> Bool {
    var reussi: Bool = false
    //generer uuid
    let uuid = UUID().uuidString

    let requete: String =
      "INSERT INTO loyers (nom, grandeur, prix, uuid, dispo, longitude, lattitude) VALUES (?, ?, ?, ?, ?, ?, ?)"
    var preparation: OpaquePointer? = nil

    // prépare la requête
    if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

      // ajoute les paramètres
      sqlite3_bind_text(preparation, 1, NSString(string: nom).utf8String, -1, nil)
      sqlite3_bind_double(preparation, 2, grandeur)
      sqlite3_bind_double(preparation, 3, prix)
      sqlite3_bind_text(preparation, 4, NSString(string: uuid).utf8String, -1, nil)
      sqlite3_bind_int(preparation, 5, 1)
      sqlite3_bind_text(preparation, 6, NSString(string: longitude).utf8String, -1, nil)
      sqlite3_bind_text(preparation, 7, NSString(string: lattitude).utf8String, -1, nil)


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
  func supprimerLoyer(id: Int) -> Bool {
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

  /**
  Modifier un loyer dans la base de données.

 - Returns: True si la modification a réussi, False sinon.
*/
  func modifierLoyer(
    id: Int, nom: String, prix: Double, grandeur: Double, longitude: String, lattitude: String
  ) -> Bool {
    let requete: String =
      "UPDATE loyers SET nom = ?, prix = ?, grandeur = ?, longitude = ?, lattitude = ? WHERE id = ?"
    var preparation: OpaquePointer? = nil
    var resultat: Bool = false
    // prépare la requête
    if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

      // ajoute les paramètres
      sqlite3_bind_text(preparation, 1, NSString(string: nom).utf8String, -1, nil)

      sqlite3_bind_double(preparation, 2, prix)
      sqlite3_bind_double(preparation, 3, grandeur)
      sqlite3_bind_text(preparation, 4, NSString(string: longitude).utf8String, -1, nil)
      sqlite3_bind_text(preparation, 5, NSString(string: lattitude).utf8String, -1, nil)
      sqlite3_bind_int(preparation, 6, Int32(id))

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

  /*
  Toggle disponibilité d'un loyer dans la base de données.

  - Returns: True si la modification a réussi, False sinon.
  */
  func toggleDispo(id: Int, nVal: Bool) -> Bool {
    let requete: String = "UPDATE loyers SET dispo = ? WHERE id = ?"
    var preparation: OpaquePointer? = nil
    var resultat: Bool = false
    // prépare la requête
    if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

      // ajoute les paramètres
      sqlite3_bind_int(preparation, 1, Int32(nVal ? 1 : 0))
      sqlite3_bind_int(preparation, 2, Int32(id))

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

  /*
  Obtenir un loyer par sont Id.

  - Returns: Un loyer.
  */
  func obtenirLoyer(id: Int) -> Loyer? {
    let requete: String =
      "SELECT id, nom, grandeur, prix, uuid, dispo, longitude, lattitude FROM loyers WHERE id = ?"
    var preparation: OpaquePointer? = nil
    var resultat: Loyer? = nil
    // prépare la requête
    if sqlite3_prepare_v2(pointeurBD, requete, -1, &preparation, nil) == SQLITE_OK {

      // ajoute les paramètres
      sqlite3_bind_int(preparation, 1, Int32(id))

      // exécute la requête
      if sqlite3_step(preparation) == SQLITE_ROW {
        let id = Int(sqlite3_column_int(preparation, 0))
        let nom = String(cString: sqlite3_column_text(preparation, 1))
        let grandeur = Double(sqlite3_column_double(preparation, 2))
        let prix = Double(sqlite3_column_double(preparation, 3))
        let uuid = String(cString: sqlite3_column_text(preparation, 4))
        let dispo = Int(sqlite3_column_int(preparation, 5)) == 1
        let longitude = String(cString: sqlite3_column_text(preparation, 6))
        let lattitude = String(cString: sqlite3_column_text(preparation, 7))

        resultat = Loyer(
          id: id, nom: nom, grandeur: grandeur, longitude: longitude, lattitude: lattitude,
          prix: prix, uuid: uuid, dispo: dispo)
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

  /**
   Syncronise les loyers avec la base de données du service web.
  */
  func synchroniserLoyers() async {

    do {
          
        let donneesJSON = try JSONEncoder().encode(listeLoyers())

        let chaineURL = "https://unitiMobile.jonathancote.ca/synchro-loyers.php"

        guard let url = URL(string: chaineURL) else {
            print("URL invalide : \(chaineURL)")
            return
        }

        // configure la requête HTTP
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpMethod = "POST"
        request.httpBody = donneesJSON

        // lance la requête HTTP
        let (data, response) = try await URLSession.shared.data(for: request)
      
        // affiche les données reçues
        if let donnees = String(data: data, encoding: .utf8) {
            print(donnees)
            print(response)
        }
      } catch {
          print("Aucune connexion établie")
      }
  }
}

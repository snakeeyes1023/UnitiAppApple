import CoreLocation
import CoreLocationUI
//
//  LoyerDetailView.swift
//
import SwiftUI

struct LoyerCreationView: View {

  @Binding var gestionBD: GestionBD

  @Environment(\.dismiss) private var dismiss
  let generator = UINotificationFeedbackGenerator()

  var id: Int = -1

  @State var nom: String = ""
  @State var prix: Double = 0
  @State var grandeur: Double = 3.5
  @State var longitude: String = ""
  @State var lattitude: String = ""
  @State private var afficherAlerte = false

  var body: some View {
    VStack {

      if gestionBD.pointeurBD == nil {
        Text("Un problème empêche l'ouverture de la base de données.")
      } else {

        Form {

          Section(header: Text("Général")) {
            TextField("Nom", text: $nom)
            TextField("Prix", value: $prix, format: .number)
          }

          Section(header: Text("Grandeur")) {
            Stepper(value: $grandeur, in: 1...10, step: 0.5) {
              Text("Grandeur : \(grandeur, specifier: "%.2f")")
            }
          }

          Section(header: Text("Position")) {
            LocationButton {
              longitude = CLLocationManager().location?.coordinate.longitude.description ?? ""
              lattitude = CLLocationManager().location?.coordinate.latitude.description ?? ""
            }
            .frame(height: 44)

            TextField("Longitude", text: $longitude)
            TextField("Lattitude", text: $lattitude)
          }

          Section {
            Button(action: {
              var result: Bool = false

              // Création d'un nouveau loyer si le id n'est pas défini
              if self.id == -1 {
                result = self.gestionBD.ajouterLoyer(
                  nom: self.nom, grandeur: self.grandeur, prix: self.prix,
                  longitude: self.longitude, lattitude: self.lattitude)
              } else {
                result = self.gestionBD.modifierLoyer(
                  id: self.id, nom: self.nom, prix: self.prix, grandeur: self.grandeur,
                  longitude: self.longitude, lattitude: self.lattitude)
              }

              // Si la création a réussi, on affiche un message de confirmation
              if result {
                Task {
                  await gestionBD.synchroniserLoyers()
                }
                dismiss()
                self.generator.notificationOccurred(.success)
              } else {
                self.generator.notificationOccurred(.error)
                afficherAlerte = true
              }

            }) {
              Text(id == -1 ? "Ajouter le loyer" : "Modifier le loyer")
            }.disabled(
              !(nom != "" && grandeur != 0.0 && prix != 0.0 && longitude != "" && lattitude != ""))

          }
        }
        .alert("Erreur", isPresented: $afficherAlerte) {
          Text(
            id == -1 ? "Impossible de créer le loyer" : "Impossible d'appliquer les modifications.")
        }

      }

    }
    .navigationBarBackButtonHidden(true)
    .toolbar(content: {
      ToolbarItem(
        placement: .navigationBarLeading,
        content: {
          Button(action: {
            dismiss()
          }) {
            HStack {
              Image(systemName: "arrow.uturn.backward")
              Text("Retour")
            }
          }
        })

      ToolbarItem(
        placement: .principal,
        content: {
          Text(id == -1 ? "Créer un loyer" : "Modifier un loyer")

        })
    })
  }
}
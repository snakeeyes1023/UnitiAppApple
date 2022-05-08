//
//  ContentView.swift
//  Jonathan Côté
//

import SwiftUI

struct ContentView: View {

  // Données personnelles
  @AppStorage("hauteurItem") var hauteurItem: Double = 55
  @State private var afficherAlerte = false

  // Services
  @ObservedObject var authentification: Authentification = Authentification()
  @State var gestionBD: GestionBD = GestionBD(nomBD: "gestionloyer.db")
  let generator = UINotificationFeedbackGenerator()


  @State var initialDonnees: Bool = false
  @State var loyers: [Loyer] = [Loyer]()
  @State private var action: Int? = 0

    
    @State var modifEnCours = false

  init() {
    gestionBD.ouvrirBD()
  }

  var body: some View {
    if authentification.statut == .nonAuthentifie {
      Text("Vous devez être authentifié pour accéder à cette application.")
        .padding()
    } else {

      NavigationView {
        VStack {
          //Destination lorsque clique sur un item de la liste
          NavigationLink(
            destination: LoyerCreationView(gestionBD: $gestionBD), tag: 1, selection: $action
          ) {
            EmptyView()
          }

          if gestionBD.pointeurBD == nil {
            Text("Un problème empêche l'ouverture de la base de données.")
          } else {

            List {
              ForEach(loyers) { loyer in
                NavigationLink(
                  destination: LoyerDetailView(loyerId: loyer.id, gestionBD: $gestionBD)
                ) {

                  //Contenue d'un item
                  HStack {
                    if loyer.dispo {
                      Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    } else {
                      Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.red)
                    }

                    Text("-")

                    Text(loyer.nom)
                      .foregroundColor(.primary)

                  }.frame(height: hauteurItem)
                }
              }
              .onDelete(perform: supprimerLoyer)
            }
            .environment(\.defaultMinListRowHeight, hauteurItem)
            .environment(\.editMode, .constant(self.modifEnCours ? EditMode.active : EditMode.inactive))
                                  
              
            .alert("Erreur", isPresented: $afficherAlerte) {
               Text("Une erreur est survenue.")
            }
          }


        }
        .toolbar(content: {
          ToolbarItem(
            placement: .navigationBarLeading,
            content: {
                Button(action: {
                    self.modifEnCours.toggle()
                }) {
                    Text(modifEnCours ? "Terminer" : "Modifier")
                        
                }
            })

          ToolbarItem(
            placement: .principal,
            content: {
              Text("Jonathan Côté")
            })

          ToolbarItem(
            placement: .navigationBarTrailing,
            content: {
              Button(action: {
                self.action = 1
              }) {
                HStack {
                  Image(systemName: "plus")
                }
              }
            })
          // Préférence de taille de l'item de la liste
          ToolbarItem(
            placement: .bottomBar,
            content: {

              HStack {
                ZStack {
                  Rectangle()
                    .fill(Color.gray)
                    .opacity(0.09)
                    .cornerRadius(10)

                  HStack {
                    Button(action: {
                      hauteurItem = hauteurItem - 1
                    }) {
                      HStack {
                        Image(systemName: "minus")
                      }
                    }.padding(5)

                    Spacer()

                    Button(action: {
                      hauteurItem = hauteurItem + 1

                    }) {
                      HStack {
                        Image(systemName: "plus")
                      }
                    }.padding(5)
                  }
                }.padding()

              }
            })
        })
        .onAppear {
          loyers = gestionBD.listeLoyers()
          //Si première connexion, on synchronise les données
          if !initialDonnees {
            initialDonnees = true
            Task {
              await gestionBD.synchroniserLoyers()
            }
          }

        }
      }
    }
  }

  /*
    * Fonction qui permet de supprimer un loyer
    */
  func supprimerLoyer(at offsets: IndexSet) {
    var errorAppend: Bool = false
    for index in offsets {
      if !gestionBD.supprimerLoyer(id: loyers[index].id) {
        print("Erreur lors de la suppression du loyer")
        errorAppend = true
      }
    }

    if !errorAppend {
      generator.notificationOccurred(.success)
    } else {
      generator.notificationOccurred(.error)
      afficherAlerte = true
    }

    loyers = gestionBD.listeLoyers()

    Task {
      await gestionBD.synchroniserLoyers()
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

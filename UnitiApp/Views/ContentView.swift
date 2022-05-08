//
//  ContentView.swift
//  UnitiApp
//
//  Created by Élève 1 on 2022-04-25.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("hauteurItem") var hauteurItem: Double = 0.0

    @ObservedObject var authentification: Authentification = Authentification()

    @State var gestionBD: GestionBD = GestionBD(nomBD: "gestionloyer.db")
    
    @State var initialDonnees : Bool = false
    
    @State var loyers : [Loyer] = [Loyer]()
    
    @State private var action: Int? = 0

    init() {
        gestionBD.ouvrirBD()
    }
    
    var body: some View {
        if (authentification.statut == .nonAuthentifie) {
            Text("Vous devez être authentifié pour accéder à cette application.")
                .padding()
        }
        else {
            
    
        NavigationView{
            VStack{
                NavigationLink(destination: LoyerCreationView(gestionBD: $gestionBD), tag: 1, selection: $action) {
                    EmptyView()
                }
                     if gestionBD.pointeurBD == nil {
                        Text("Un problème empêche l'ouverture de la base de données.")
                    } else {
                        
                        List {
                            ForEach(loyers) { loyer in
                                NavigationLink(destination: LoyerDetailView(loyerId: loyer.id, gestionBD: $gestionBD)) {
                                    HStack {
                                        //satus color
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
                                    }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, hauteurItem: , alignment: .topLeading)

                                }
                        }
                        .onDelete(perform: deleteLoyer)
                        }
                    }
                
        }
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading, content: {
                    EditButton()
                })
                
                ToolbarItem(placement: .principal, content: {
                    Text("Jonathan Côté")
                })
                
                ToolbarItem(placement: .navigationBarTrailing, content: {
                    Button(action: {
                    self.action = 1
                }) {
                  HStack {
                    Image(systemName: "plus.app.fill")
                    Text("Ajouter")
                  }
                }

                ToolbarItem(placement: .bottomBar) {
                    Button("-") {
                        hauteurItem = hauteurItem - 1
                    }

                    Spacer()

                    Button("+") {
                        hauteurItem = hauteurItem + 1
                    }
                }
              })
            })
        .onAppear {
            loyers = gestionBD.listeLoyers();

        }
    }
    }
    }
    
    /*
    * Fonction qui permet de supprimer un loyer
    */
    func deleteLoyer(at offsets: IndexSet) {
        for index in offsets {
            _ = gestionBD.supprimerLoyer(id: loyers[index].id);
        }
        loyers = gestionBD.listeLoyers();
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

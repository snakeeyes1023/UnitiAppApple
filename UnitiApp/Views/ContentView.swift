//
//  ContentView.swift
//  UnitiApp
//
//  Created by Élève 1 on 2022-04-25.
//

import SwiftUI

struct ContentView: View {
    
    @AppStorage("hauteurItem") var hauteurItem: Double = 55

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
                        .onDelete(perform: deleteLoyer)
                        }.environment(\.defaultMinListRowHeight, hauteurItem)
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
                    Image(systemName: "plus")
                  }
                }
                })
                
                ToolbarItem(placement: .bottomBar, content: {
                    
                    HStack{
                        ZStack(){
                            Rectangle()
                                .fill(Color.gray)
                                .opacity(0.09)
                                .cornerRadius(10)
                            
                        HStack{
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
                        }}.padding()
                        
                    }
                })
              })
        .onAppear {
            loyers = gestionBD.listeLoyers();
            
            if(!initialDonnees)
            {
                initialDonnees = true
                Task{
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
    func deleteLoyer(at offsets: IndexSet) {
        for index in offsets {
            _ = gestionBD.supprimerLoyer(id: loyers[index].id);
        }
        loyers = gestionBD.listeLoyers();
        
        Task{
            await gestionBD.synchroniserLoyers()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

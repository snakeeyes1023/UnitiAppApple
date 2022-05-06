//
//  ContentView.swift
//  UnitiApp
//
//  Created by Élève 1 on 2022-04-25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authentification: Authentification = Authentification()

    @State var gestionBD: GestionBD = GestionBD(nomBD: "gestionloyer.db")
    
    @State var initialDonnees : Bool = false
    
    @State var loyers : [Loyer] = [Loyer]()
    
    @State private var action: Int? = 0

    init() {
        gestionBD.ouvrirBD()
    }
    
    var body: some View {
        if (authentification.statut == .authentifie) {
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
                                NavigationLink(destination: LoyerDetailView(loyer: loyer, gestionBD: $gestionBD)) {
                                    HStack {
                                      Image(systemName: "house")
                                      Text("-")
                                      Text(loyer.nom)
                                            .foregroundColor(.primary)
                                    }
                                }
                        }
                        .onDelete(perform: deleteLoyer)
                        }
                    }
                
        }
        .navigationBarItems(leading: EditButton(), trailing: Text("Ajouter").foregroundColor(.blue)
        .onTapGesture {
            self.action = 1
        })
            
        .navigationBarTitle("Jonathan Côté", displayMode: .inline)
        .padding()
        .onAppear {
            if(!initialDonnees){
                initialDonnees = true
                loyers = gestionBD.listeLoyers();
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
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

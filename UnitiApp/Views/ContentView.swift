//
//  ContentView.swift
//  UnitiApp
//
//  Created by Élève 1 on 2022-04-25.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var authentification: Authentification = Authentification()

    @State var gestionBD: GestionBD = GestionBD(nomBD: "gestionloyer.db");
    
    @State var initialDonnees : Bool = false;
    
    @Binding var loyers : [Loyer]
    
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
                ScrollView{
                     if gestionBD.pointeurBD == nil {
                        Text("Un problème empêche l'ouverture de la base de données.")
                    } else {

                        ForEach($loyers) { $loyer in
                            //naviation link
                            NavigationLink(destination: LoyerDetailView(loyer: loyer, gestionBD: $gestionBD)) {
                                TextField("Nom", text: $loyer.nom)
                            }
                        }
                        .onDelete(perform: deleteLoyer)
                    }
                }
        }
        .navigationBarItems(leading: EditButton(), trailing: boutonAjouter)
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

    /*
    *  Bouton ajouter un loyer
    */
    var boutonAjouter: some View {
        switch editMode {
        case .inactive:
            return AnyView(Button(action: {}) { 
                NavigationLink(destination: LoyerCreationView(gestionBD: $gestionBD)) {
                    Image(systemName: "plus") 	
                }
         })
        default:
            return AnyView(EmptyView())
        }
    }
    
    /*
    * Fonction qui permet de supprimer un loyer
    */
    func deleteLoyer(at offsets: IndexSet) {
        for index in offsets {
            gestionBD.supprimerLoyer(loyers[index].id);
        }
        loyers = gestionBD.listeLoyers();
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().preferredColorScheme(.light)
    }
}
}

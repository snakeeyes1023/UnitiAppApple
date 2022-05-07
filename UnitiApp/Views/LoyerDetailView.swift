//
//  LoyerDetailView.swift
//  GestionObjetConnecte
//
//
import SwiftUI


struct LoyerDetailView: View {
        
    @State var loyer: Loyer;
    @Binding var gestionBD: GestionBD;
    @State private var action: Int? = 0
    @Environment(\.dismiss) private var dismiss

    var body: some View {
   
        VStack{

            ZStack(){
                NavigationLink(destination: LoyerCreationView(
                    gestionBD: $gestionBD,
                    id: loyer.id,
                    nom: loyer.nom,
                    prix : loyer.prix,
                    grandeur: loyer.grandeur,
                    longitude: loyer.longitude,
                    lattitude: loyer.lattitude
                ), tag: 1, selection: $action) {

                    EmptyView()
                    
                }
                Rectangle()
                    .fill(Color.gray)
                    .opacity(0.09)
                    .cornerRadius(10)
                
                VStack(){
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1604251806132-6b149e8e6730?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80.png")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 255 , height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 25))                    
                                           
                    VStack(alignment: .leading, spacing: 6) {      
                        Text("nom : " + loyer.nom)
                    }
                    
                    Spacer()

                    VStack(){
                        Text("grandeur : " + String(loyer.grandeur))
                    }

                    Spacer()                                                                              
                }
            }.padding(10)             
            
        }
        .navigationBarBackButtonHidden(true)
        .toolbar(content: {
        ToolbarItem(placement: .navigationBarLeading, content: {
            Button(action: {
            dismiss()
        }) {
          HStack {
            Image(systemName: "arrow.uturn.backward")
            Text("Retour")
          }
        }
      })
            
        ToolbarItem(placement: .principal, content: {
                Text("Mon loyer")
          })

          ToolbarItem(placement: .navigationBarTrailing, content: {
            Menu {
    Button(action: {
        gestionBD.toggleDispo(id: loyer.id, nVal: !loyer.dispo)
        self.loyer.dispo = !self.loyer.dispo
    }) {
        Label(loyer.dispo ? "Mettre non disponnible" : "Mettre disponnible", systemImage: loyer.dispo ? "plus.app" : "plus.app.fill")
    }
                
    Button(action: {
       self.action = 1
        }) {
            Label("Modifier", systemImage: "pencil.tip")
    }
              
} label: {
    Image(systemName: "text.justify")
    .foregroundColor(.primary)
}


        })
    }) 
    }
        
    }

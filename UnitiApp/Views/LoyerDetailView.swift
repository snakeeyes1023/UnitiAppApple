//
//  LoyerDetailView.swift
//  GestionObjetConnecte
//
//
import SwiftUI


struct LoyerDetailView: View {
        
    var loyer: Loyer;
    @Binding var gestionBD: GestionBD;
    
    var body: some View {
        VStack{

            ZStack(){
                Rectangle()
                    .fill(Color.gray)
                    .opacity(0.09)
                    .cornerRadius(10)
                
                Vstack(){
                    AsyncImage(url: URL(string: "https://images.unsplash.com/photo-1604251806132-6b149e8e6730?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80.png")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(width: 255 , height: 128)
                    .clipShape(RoundedRectangle(cornerRadius: 25))                    
                                           
                    Spacer()

                    VStack(alignment: .leading, spacing: 6) {      
                        Text("nom : " + loyer.nom)
                        
                    }
                    VStack(){
                        Text("grandeur : " + String(loyer.grandeur))
                    }

                    Spacer()

                    // button toggle active
                    Button(action: {
                        //self.gestionBD.loyerToggle(id: self.loyer.id, active: !self.loyer.dispo)
                        //self.loyer.dispo = !self.loyer.dispo
                    }) {
                        Text(loyer.dispo ? "Active" : "Inactive")
                    }                                                                
                }
            }.padding(10)             
            }
        }
        
    }

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
                
                HStack(){
                    
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

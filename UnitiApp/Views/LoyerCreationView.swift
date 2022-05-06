//
//  LoyerDetailView.swift
//
import SwiftUI


struct LoyerCreationView: View {

    @Binding var gestionBD: GestionBD;

    @StateObject var locationManager = LocationManager()

    @Environment(\.dismiss) private var dismiss
    let generator = UINotificationFeedbackGenerator()

    var id : Int = -1;
    
    @State var nom: String = "";
    @State var prix: Double = 0;
    @State var grandeur: Double = 3.5;
    @State var longitude: String = "" //String(locationManager.lastLocation?.coordinate.longitude ?? 0);
    @State var lattitude: String = "" //String(locationManager.lastLocation?.coordinate.latitude ?? 0);
    @State private var showingAlert = false


    var body: some View {
        VStack{
            
            if gestionBD.pointeurBD == nil {
                Text("Un problème empêche l'ouverture de la base de données.")
            } else {
                
                NavigationView {
                    ZStack(){
                        Rectangle()
                            .fill(Color.gray)
                            .opacity(0.09)
                            .cornerRadius(10)
                        
                           Form {
                                .alert("Erreur", isPresented: $showingAlert) {
                                    Text(id == 0 ? "Impossible de créer le loyer" :"Impossible d'applicer les modifications.")
                                }
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
                                   TextField("Longitude", text: $longitude)
                                   TextField("Lattitude", text: $lattitude)
                               }
                               
                               Section {
                                   
                               if nom != "" && grandeur != 0.0 && prix != 0.0 && longitude != "" && lattitude != "" {
                                       Button(action: {
                                           var result : Bool = false;

                                           // Création d'un nouveau loyer si le id n'est pas défini
                                           if self.id == -1 {
                                               result = self.gestionBD.ajouterLoyer(nom: self.nom, grandeur: self.grandeur, prix: self.prix, longitude: self.longitude, lattitude: self.lattitude)
                                           } else {
                                               result = self.gestionBD.modifierLoyer(id: self.id, nom: self.nom, prix: self.prix, grandeur: self.grandeur, longitude: self.longitude, lattitude: self.lattitude)
                                           }
                                           
                                           // Si la création a réussi, on affiche un message de confirmation
                                            if(result){
                                                dismiss()
                                                self.generator.notificationOccurred(.success)
                                            }
                                            else{
                                                self.generator.notificationOccurred(.error)
                                                showingAlert = true
                                            }
                                          
                                       }) {
                                           Text(id == -1 ? "Ajouter le loyer" : "Modifier le loyer")
                                       }
                                   }
                               }
                           }
                           .navigationBarTitle("Jonathan Côté")
                       }
                }
                }
                
            }
        }
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
    }) 
    }


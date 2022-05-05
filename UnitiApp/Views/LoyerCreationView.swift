//
//  LoyerDetailView.swift
//
import SwiftUI


struct LoyerCreationView: View {

    @Binding var gestionBD: GestionBD;

    @StateObject var locationManager = LocationManager()

    var id : Int = -1;
    
    @State var nom: String = "";
    @State var largeur: Double = 0.0;
    @State var longueur: Double = 0.0;
    @State var longitude: String = (locationManager.lastLocation?.coordinate.longitude ?? 0) as String;
    @State var lattitude: String = 0.0 (locationManager.lastLocation?.coordinate.latitude ?? 0) as String;
    

    var body: some View {
        VStack{
            
            if gestionBD.pointeurBD == nil {
                Text("Un problème empêche l'ouverture de la base de données.")
            } else {
                
                VStack{
                    
                    List{
                        
                        ZStack(){
                            Rectangle()
                                .fill(Color.gray)
                                .opacity(0.09)
                                .cornerRadius(10)
                                .border(Color.black, width: 2)
                            
                            HStack(){
                                
                                VStack(alignment: .leading, spacing: 6) {                                    
                                    Text("nom : ")
                                    TextField("nom", text: $nom)                                   
                                }

                                // Grandeur
                                VStack(){
                                    Text("largeur : ")
                                    TextField("largeur", value: $largeur, formatter: NumberFormatter())
                                }
                                VStack(){
                                    Text("longueur : ")
                                    TextField("longueur", value: $longueur, formatter: NumberFormatter())
                                }

                                // Position
                                VStack(){
                                    Text("longitude : ")
                                    TextField("longitude", value: $longitude)
                                }

                                VStack(){
                                    Text("lattitude : ")
                                    TextField("lattitude", value: $lattitude)
                                }

                                
                            }
                        }.padding(10)
                        }
                    }
                    
                    if nom != "" && largeur != 0.0 && longueur != 0.0 && description != "" {
                        Button(action: {
                            var result : Bool = false;

                            // Création d'un nouveau loyer si le id n'est pas défini
                            if self.id == -1 {
                                result = self.gestionBD.ajouterLoyer(nom: self.nom, largeur: self.largeur, longueur: self.longueur)
                            } else {
                                result = self.gestionBD.modifierLoyer(id: self.id, nom: self.nom, largeur: self.largeur, longueur: self.longueur)
                            }
                            
                            // Si la création a réussi, on affiche un message de confirmation

                           
                        }) {
                            Text("Ajouter")
                        }
                    }
                    
                }
                
            }
        }
    }

}


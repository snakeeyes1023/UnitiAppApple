//
//  LoyerDetailView.swift
//  Jonathan Côté
//
import SwiftUI


struct LoyerDetailView: View {
        
    @State var loyerId: Int;
    @Binding var gestionBD: GestionBD;

    
    @State var loyer: Loyer = Loyer(id: 0, nom: "", grandeur: 0, longitude: "", lattitude: "", prix: 0, uuid: "", dispo: false);
    @State private var action: Int? = 0
    @Environment(\.dismiss) private var dismiss
    let generator = UINotificationFeedbackGenerator()

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
                    AsyncImage(url: URL(string: "https://source.unsplash.com/random/?apartement")) { image in
                        image.resizable()
                    } placeholder: {
                        Color.gray
                    }
                    .frame(height: 150, alignment: .center)
                    .clipShape(RoundedRectangle(cornerRadius: 25))
                    .padding()
                                           
                    VStack(alignment: .leading, spacing: 6) {      
                        Text(loyer.nom).modifier(TexteTitre())
                    }
                    
                    Spacer()

                    VStack(alignment: .leading){
 
                        HStack(){
                            Text("Grandeur").modifier(TexteTag())
                            Spacer()
                            Text(String(loyer.grandeur))
                        }.padding()
                        
                        HStack(){
                            Text("Longitude").modifier(TexteTag())
                            Spacer()
                            Text(loyer.longitude)
                        }.padding()
                        
                        HStack(){
                            Text("Lattitude").modifier(TexteTag())
                            Spacer()
                            Text(loyer.lattitude)
                        }.padding()

                        HStack(){
                            Text("Prix").modifier(TexteTag())
                            Spacer()
                            Text(loyer.prix)
                        }.padding()
                        
                        HStack(){
                            Text("Dispo").modifier(TexteTag())
                            Spacer()
                            if loyer.dispo {
                              Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                
                                Text("Disponnible")
                            } else {
                              Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.red)
                                Text("Non disponnible")
                            }
                        }.padding()
                        
                    }.padding(5)
                    
                    Spacer()
                }
            }
            
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

                if(gestionBD.toggleDispo(id: loyer.id, nVal: !loyer.dispo)) {
                    generator.notificationOccurred(.success)
                    self.loyer.dispo = !self.loyer.dispo

                    Task{
                        await gestionBD.synchroniserLoyers()
                    }
                }
                else{
                    generator.notificationOccurred(.error)
                }
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
        .onAppear {
            loyer = gestionBD.obtenirLoyer(id : loyerId)!;
        }
    }        
}


struct TexteTitre: ViewModifier {
  func body(content: Content) -> some View {
    return content
          .font(.system(size: 25, weight: .bold, design: .default))
  }
}

struct TexteTag: ViewModifier {
  func body(content: Content) -> some View {
    return content
        .font(.system(size: 15, weight: .bold, design: .default))
  }
}

import Foundation
import LocalAuthentication


enum Statut {
  case authentifie, nonAuthentifie
}


class Authentification: ObservableObject {
  @Published var statut: Statut = .nonAuthentifie
  let context = LAContext()
  var error: NSError?

  init() {
    // Avec .deviceOwnerAuthentication (plutôt que .deviceOwnerAuthenticationWithBiometrics), demandera une authentification par code si Face ID n'est pas disponible.
    if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
      
      let justificationSiFaceIDNonDisponible = "Vous devez vous authentifier pour accéder à cette application."

      context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: justificationSiFaceIDNonDisponible ) { success, error in

        if success {
          // Retourne au fil d'exécution principal
          DispatchQueue.main.async {
            self.statut = .authentifie
          }
        } else {
          print(error?.localizedDescription ?? "L'authentification a échoué.")
        }
      }
    }
  }
}
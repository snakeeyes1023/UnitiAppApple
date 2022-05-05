//
//  MainView.swift
//  UnitiApp
//
//  Created by Élève 1 on 2022-04-25.
//

import SwiftUI


struct MainView: View {
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Menu", systemImage: "list.dash")
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

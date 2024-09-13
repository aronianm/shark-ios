//
//  SharkView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift

// Define the main view with a NavigationView
struct SharkView: View {
    let fronteggAuth = FronteggApp.shared.auth
    var body: some View {
        NavigationView {
            TabView {
                ProgramsView()
                    .tabItem {
                        Image(systemName: "list.bullet")
                        Text("Programs")
                    }
                SettingsView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                Button(action: {
                    fronteggAuth.logout()
                }) {
                    Text("Logout")
                }
                .tabItem {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Logout")
                }
            }
        }
    }
}


#Preview {
    FronteggWrapper {
        SharkView()
    }
    
}

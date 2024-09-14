//
//  SharkView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
import WatchConnectivity

// Define the main view with a NavigationView
struct SharkView: View {
    @StateObject private var viewModel = SharkViewModel()
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
                .onTapGesture {
                    fronteggAuth.logout()
                    WCSession.default.sendMessage(["FronteggAccessToken": ""], replyHandler: nil) { error in
                        print("Error sending logout message to Apple Watch: \(error.localizedDescription)")
                    }
                }
                }
            }.onAppear {
                viewModel.handleWatchSession(fronteggAuth: fronteggAuth)
            }
        }
       
    }
}

// ViewModel for handling WatchConnectivity and session management
class SharkViewModel: NSObject, ObservableObject, WCSessionDelegate {
    func handleWatchSession(fronteggAuth: FronteggAuth) {
        if let accessToken = fronteggAuth.accessToken {
            UserDefaults.standard.set(accessToken, forKey: "FronteggAccessToken")
            
            // Pass the access token to the Apple Watch app
            if WCSession.isSupported() {
                let session = WCSession.default
                session.delegate = self
                session.activate()
                
                let message = ["FronteggAccessToken": accessToken]
                session.sendMessage(message, replyHandler: nil) { error in
                    print("Error sending message to Apple Watch: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // WCSessionDelegate methods
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }

    func sessionDidBecomeInactive(_ session: WCSession) {
        // Handle session becoming inactive if needed
    }

    func sessionDidDeactivate(_ session: WCSession) {
        // Handle session deactivation if needed, and activate again
        session.activate()
    }
}


#Preview {
    FronteggWrapper {
        SharkView()
    }
    
}

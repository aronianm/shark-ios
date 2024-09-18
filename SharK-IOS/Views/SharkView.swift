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
    let fronteggAuth = FronteggApp.shared.auth
    @StateObject private var watchConnectivity = WatchConnectivityManager()
    
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
                WatchConnectivityView(watchConnectivity: watchConnectivity)
                    .tabItem {
                        Image(systemName: "applewatch")
                        Text("Watch")
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
        .onAppear {
            connectToAppleWatch()
        }
    }
    
    private func connectToAppleWatch() {
        watchConnectivity.activateSession()
    }
}

struct WatchConnectivityView: View {
    @ObservedObject var watchConnectivity: WatchConnectivityManager
    
    var body: some View {
        VStack {
            Text("Watch Connectivity")
            Text("Connection status: \(watchConnectivity.isReachable ? "Connected" : "Disconnected")")
            Button("Send Message to Watch") {
                watchConnectivity.sendMessage(["message": "Hello from iPhone!"])
            }
        }
    }
}

class WatchConnectivityManager: NSObject, ObservableObject, WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        // Implementation for sessionDidBecomeInactive
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        // Implementation for sessionDidDeactivate
    }
    @Published var isReachable = false
    private var session: WCSession = .default
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            session.delegate = self
        }
    }
    
    func activateSession() {
        session.activate()
    }
    
    func sendMessage(_ message: [String: Any]) {
        if session.isReachable {
            session.sendMessage(message, replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async {
            self.isReachable = session.isReachable
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        // Handle received messages from the watch
        print("Received message from watch: \(message)")
    }
}

#Preview {
    FronteggWrapper {
        SharkView()
    }
    
}

//
//  WCSessionDelegate.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/13/24.
//

import SwiftUI
import WatchConnectivity

class SessionDelegate: NSObject, WCSessionDelegate, ObservableObject {
    @Published var authenticationKey: String = ""
    
    override init() {
        super.init()
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
    }
    
    // WCSessionDelegate method to handle activation
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    // Handle incoming application context (when the iPhone app sends updated data)
    // func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
    //     if let token = applicationContext["FronteggAccessToken"] as? String {
    //         DispatchQueue.main.async {
    //             self.authenticationKey = token
    //         }
    //     }
    // }
    
    // Method to request authentication from the paired iPhone
    func requestAuthentication() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["request": "authentication"], replyHandler: { response in
                if let token = response["FronteggAccessToken"] as? String {
                    DispatchQueue.main.async {
                        self.authenticationKey = token
                    }
                }
            }) { error in
                print("Error requesting authentication: \(error.localizedDescription)")
            }
        }else{
            print("iPhone is not reachable")
        }
    }
    
    // Handle incoming messages
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let token = message["FronteggAccessToken"] as? String {
            DispatchQueue.main.async {
                self.authenticationKey = token
            }
        }
    }
}

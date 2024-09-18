//
//  WatchViewModel.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/14/24.
//

import Foundation
import WatchConnectivity

// ViewModel for handling WatchConnectivity and session management
class SharkViewModel: NSObject, ObservableObject, WCSessionDelegate {
    func handleWatchSession() {
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
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

}

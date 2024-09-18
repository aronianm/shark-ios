//
//  InterfaceController.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/17/24.
//


import WatchKit
import WatchConnectivity
import Foundation

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var watchLabel: WKInterfaceLabel!
    let session = WCSession.default
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    override func willActivate() {
        super.willActivate()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
}

extension InterfaceController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error {
            print("session activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let value = message["iPhone"] as? String {
            self.watchLabel.setText(value)
        }
    }
}

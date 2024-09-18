//
//  ViewController.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/17/24.
//

import Foundation
import UIKit
import WatchConnectivity
import SwiftUI

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var phoneLabel: UILabel!
    let session = WCSession.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if WCSession.isSupported() {
            session.delegate = self
            session.activate()
        }
    }
    
    @IBAction func sendDataToWatch(_ sender: UIButton) {
        let myArray = ["One", "Two", "Three", "Four", "Five", "Six"]
        phoneLabel.text = myArray.randomElement()
        session.sendMessage(["iPhone": phoneLabel.text ?? "I am empty"], replyHandler: nil, errorHandler: nil)
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
    if let error {
            print("session activation failed with error: \(error.localizedDescription)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        session.activate()
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        session.activate()
    }
}

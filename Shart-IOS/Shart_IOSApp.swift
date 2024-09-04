//
//  Shart_IOSApp.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
@main
struct Shart_IOSApp: App {
    var body: some Scene {
        WindowGroup {
            FronteggWrapper {
                ContentView()
            }
        }
    }
}

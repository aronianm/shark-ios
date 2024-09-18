//
//  ContentView.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/13/24.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject private var sessionDelegate = SessionDelegate()  // View model to manage session
    var body: some View {
        VStack {
            MainView()
        }
    }
}


#Preview {
    ContentView()
}

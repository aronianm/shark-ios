//
//  ContentView.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/13/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sessionDelegate = SessionDelegate()  // View model to manage session
    var body: some View {
        VStack {
            if sessionDelegate.authenticationKey.isEmpty {
                Button(action: {
                    sessionDelegate.requestAuthentication()
                }) {
                    Text("Login to view your data")
                        .foregroundColor(.blue)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                }
            } else {
                MainView()
            }
        }
        .onAppear {
            sessionDelegate.requestAuthentication()
        }
    }
}

#Preview {
    ContentView()
}

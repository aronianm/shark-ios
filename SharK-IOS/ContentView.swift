//
//  ContentView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
struct ContentView: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth
    var body: some View {
        if fronteggAuth.isAuthenticated {
            SharkView()
        } else {
            WelcomeView()
        }
    }
}

#Preview {
    FronteggWrapper {
        ContentView()
    }
}


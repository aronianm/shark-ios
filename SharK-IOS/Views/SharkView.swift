//
//  SharkView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift

// Define the main view with a NavigationView
struct SharkView: View {
    let fronteggAuth = FronteggApp.shared.auth
    var body: some View {
        NavigationView {
            ProgramsView()
        }
    }
}


#Preview {
    FronteggWrapper {
        SharkView()
    }
    
}

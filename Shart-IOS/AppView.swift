//
//  AppView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
struct AppView: View {
    var body: some View {
        FronteggWrapper {
            ContentView()
        }
    }
}

#Preview {
    AppView()
}

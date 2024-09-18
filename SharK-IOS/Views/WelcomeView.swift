//
//  WelcomeView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift 

struct WelcomeView: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth
    var body: some View {
        VStack{
            VStack {
                
                
                // Welcome Text
                Text("Welcome Shark!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Discover amazing features and join our community.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Image("default")
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                    .cornerRadius(10)
                Spacer()
                
                
                // Login Button
                Button(action: {
                    fronteggAuth.login()
                }) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .cornerRadius(10)
                }
            }
        }.background()
    }
}


#Preview {
    WelcomeView()
}

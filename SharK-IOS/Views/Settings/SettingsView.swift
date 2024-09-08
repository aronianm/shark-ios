//
//  SettingsView.swift
//  Shark-IOS
//
//  Created by Michael Aronian Aronian on 9/8/24.
//

import SwiftUI
import FronteggSwift

struct SettingsView: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth
    
    var user = FronteggApp.shared.auth.user
    @State private var trainorData: Trainor?
    @State private var isLoading = false
    @State private var error: Error?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if isLoading {
                    ProgressView()
                } else if let error = error {
                    Text("Error: \(error.localizedDescription)")
                        .foregroundColor(.red)
                } else if let trainer = trainorData {
                    VStack(spacing: 20) {
                        // Trainer Card
                        VStack(alignment: .center) {
                            AsyncImage(url: URL(string: trainer.profilePictureUrl)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                            
                            Text("Trainer")
                                .font(.headline)
                            
                            Text(trainer.name.capitalized)
                                .font(.title)
                            
                            Text("Email: \(trainer.email)")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                        
                        // User Card
                        VStack(alignment: .center) {
                            AsyncImage(url: URL(string: user?.profilePictureUrl ?? "")) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } placeholder: {
                                ProgressView()
                            }
                            
                            Text("User")
                                .font(.headline)
                            
                            Text(user?.name.capitalized ?? "")
                                .font(.title)
                            
                            Text("Email: \(user?.email ?? "")")
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
            }
            .padding()
        }.onAppear {
            isLoading = true
            fetchTrainer()
        }
    }

    // Fetch the trainer details
    private func fetchTrainer() {
        guard let url = URL(string: "http://Michaels-MacBook-Air.local:3001/athletes/users/get_trainor.json") else {
            self.error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
            self.isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let accessToken = FronteggApp.shared.auth.accessToken {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                guard let data = data else {
                    self.error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                    return
                }
                
                do {
                    // Assuming the response is a JSON object with trainer details
                    // You might need to adjust this based on the actual response structure
                    self.trainorData = try JSONDecoder().decode(Trainor.self, from: data)
                } catch {
                    self.error = error
                }
            }
        }.resume()
    }
    
}

#Preview {
    SettingsView()
}

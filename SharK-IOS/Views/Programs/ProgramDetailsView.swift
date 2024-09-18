//
//  ProgramDetailsView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift

struct ProgramDetailsView: View {
    let program: Program
    @EnvironmentObject var fronteggAuth: FronteggAuth
    @State private var showWorkoutIndex = 0
    
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) { 
                if program.workouts.isEmpty {
                    Text("No workouts available")
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    ForEach(Array(program.workouts.enumerated()), id: \.element.id) { index, workout in
                        if index == showWorkoutIndex {
                            WorkoutView(workout: workout)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
        }
        .environmentObject(ProgramEnvironment(program: program))
        .onAppear {
            if !program.started {
                updateProgramStarted()
            }
        }
    }
    
    private func updateProgramStarted() {
        guard let url = URL(string: "http://Michaels-MacBook-Air.local:3001/athletes/programs/\(program.userProgramId)/update_program.json") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let accessToken = FronteggApp.shared.auth.accessToken {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let parameters: [String: Any] = ["program_user": ["started": true]]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            print("Error encoding parameters: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error updating program started status: \(error)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("Status code: \(httpResponse.statusCode)")
            }
            
            // Handle the response as needed
        }.resume()
    }
}

class ProgramEnvironment: ObservableObject {
    @Published var program: Program
    
    init(program: Program) {
        self.program = program
    }
}


struct ProgramDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        ProgramDetailsView(program: Program(
            id: 1,
            name: "Sample Program",
            createdAt: "2024-03-03",
            updatedAt: "2024-03-03",
            createdBy: "User",
            updatedBy: "User",
            active: true,
            started: false,
            userProgramId: 1,
            workouts: [
                Workout(
                    id: 1,
                    programId: 1,
                    name: "Workout 1",
                    description: "Sample workout",
                    day: "1",
                    exercises: [
                        Exercise(
                            name: "Push-ups",
                            sets: [
                                WorkoutSet(reps: 10, weight: .string("BW"), completed: false),
                                WorkoutSet(reps: 10, weight: .string("BW"), completed: false)
                            ],
                            superSetKey: nil
                        )
                    ],
                    createdAt: "2024-03-03",
                    updatedAt: "2024-03-03",
                    createdBy: "User",
                    updatedBy: "User",
                    started: false,
                    completed: false,
                    startedAt: "2023"
                )
            ]
        ))
    }
}

//#Preview {
//    ProgramDetailsView()
//}

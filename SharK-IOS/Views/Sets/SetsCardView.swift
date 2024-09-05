//
//  SetsCardView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/3/24.
//

import SwiftUI
import FronteggSwift


struct SetsCardView: View {
    @State var programId:Int = 0
    @State var workoutId:Int = 0
    var exerciseIndex:Int
    @EnvironmentObject var fronteggAuth: FronteggAuth
    @EnvironmentObject var programEnvironment: ProgramEnvironment
    @EnvironmentObject var workoutEnvironment: WorkoutEnvironment
    let index: Int
    @State var set: Set
    
    var body: some View {
        HStack {
            Text("Program ID: \(workoutId)")
            Text("Set \(index + 1)")
                .font(.headline)
                .fontWeight(.bold)
            Spacer()
            Text("\(set.reps) reps")
                .font(.subheadline)
            Text("•")
                .foregroundColor(.gray)
            Text(weightString(set.weight))
                .font(.subheadline)
            Spacer()
            Button(action: { 
                
                updateSet { result in
                    switch result {
                    case .success(let workout):
                        print("Updated workout: \(workout)")
                    case .failure(let error):
                        print("Error updating set: \(error)")
                    }
                }
            }) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.completed ? .green : .gray)
                    .font(.title2)
            }.onAppear {
                programId = programEnvironment.program.id
                workoutId = workoutEnvironment.workout.id
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }

    func updateSet(completion: @escaping (Result<Workout, Error>) -> Void) {
        let baseURL = "http://Michaels-MacBook-Air.local:3001/programs/\(programId)/workouts/\(workoutId)/update_set.json"
        guard let url = URL(string: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        var request = URLRequest(url: url)
        if let accessToken = self.fronteggAuth.accessToken  {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let params = ["completed": !set.completed, "reps": set.reps, "weight": weightString(set.weight), "setIndex": index, "exerciseIndex": exerciseIndex] as [String : Any]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: params, options: [])
            request.httpBody = jsonData
        } catch {
            print("Error encoding set: \(error)")
        }
        
        self.set.completed.toggle()

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                return
            }
            print("HTTP Status Code: \(httpResponse.statusCode)")
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP request failed with status code: \(httpResponse.statusCode)")
                return
            }
            guard let data = data else {
                print("No data received")
                return
            }
            print("Received data of size: \(data.count) bytes")
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let workout = try decoder.decode(Workout.self, from: data)
                DispatchQueue.main.async {
                    workoutEnvironment.workout = workout
                }
            } catch {
                print("Decoding error: \(error)")
            }
        }
        task.resume()


    }
    
    private func weightString(_ weight: WeightValue) -> String {
            switch weight {
            case .string(let value):
                return value
            case .number(let value):
                return String(format: "%.1f", value)
            }
        }
}

#Preview {
    SetsCardView(
        exerciseIndex: 0, index: 0,
        set: Set(reps: 10, weight: .string("BW"), completed: false)
    )
}

//
//  WorkoutsView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
import HealthKit

struct WorkoutView: View {
    @State var workout: Workout
    @EnvironmentObject var programEnvironment: ProgramEnvironment
    @EnvironmentObject var fronteggAuth: FronteggAuth

    @State var showLeftIcon = false
    @State var showRightIcon = false

    var body: some View {

            VStack() {
                HStack{
                    Text(workout.name)
                        .font(.title)
                    Spacer()
                    if !workout.started {
                        Button(action: {
                        guard let url = URL(string: "http://Michaels-MacBook-Air.local:3001/athletes/workouts/\(workout.id).json") else {
                            print("Invalid URL")
                            return
                        }
                        var request = URLRequest(url: url)
                        if let accessToken = self.fronteggAuth.accessToken  {
                            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
                        }
                        request.httpMethod = "PUT"
                        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                        
                        let parameters: [String: Any] = ["workout": ["started": true]]
                        
                        do {
                            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                        } catch {
                            print("Error: Unable to encode parameters")
                            return
                        }
                        
                        URLSession.shared.dataTask(with: request) { data, response, error in
                            if let error = error {
                                print("Error: \(error.localizedDescription)")
                                return
                            }
                            
                            guard let httpResponse = response as? HTTPURLResponse,
                                  (200...299).contains(httpResponse.statusCode) else {
                                print("Error: Invalid response")
                                return
                            }
                            
                            DispatchQueue.main.async {
                                if let data = data {
                                    do {
                                        let decoder = JSONDecoder()
                                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                                        let decodedWorkout = try decoder.decode(Workout.self, from: data)
                                        self.workout = decodedWorkout
                                        // Enter fitness mode when the workout starts
                                        UIApplication.shared.isIdleTimerDisabled = true
//                                        WKExtension.shared().isAutoLaunchEnabled = true
                                        
                                        // Optionally, you can also start a workout session if you're using HealthKit
                                        // This would require importing HealthKit and setting up the necessary permissions
                                        let healthStore = HKHealthStore()
                                        let configuration = HKWorkoutConfiguration()
                                        configuration.activityType = .other
                                        healthStore.startWatchApp(with: configuration) { success, error in
                                            if let error = error {
                                                print("Error starting workout: \(error.localizedDescription)")
                                            }
                                        }
                                    } catch {
                                        print("Error decoding workout: \(error)")
                                    }
                                }
                            }
                        }.resume()
                        }) {
                            Text("Start Workout")
                                .foregroundColor(.green)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }else{
                        Text("Workout Started")
                            .foregroundColor(.green)
                    }
                }
                if let exercises = workout.exercises, !exercises.isEmpty {
                    HStack {
                        if showLeftIcon {
                            Image(systemName: "arrow.left")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("Swipe left or right to see more exercises")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Spacer()
                        if showRightIcon {
                            Image(systemName: "arrow.right")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    TabView {
                        ForEach(Array(exercises.enumerated()), id: \.element.name) { index, exercise in
                            SwipeableExerciseCard(exercise: exercise, exerciseIndex: index, exerciseCount: exercises.count, showLeftIcon: $showLeftIcon, showRightIcon: $showRightIcon)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(height: 400) // Adjust the height as needed for your layout
                } else {
                    Text("No exercises for this workout")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            ).environmentObject(WorkoutEnvironment(workout: workout))
        }
    
}


struct SwipeableExerciseCard: View {
    var exercise: Exercise
    var exerciseIndex: Int
    var exerciseCount: Int
    @Binding var showLeftIcon: Bool
    @Binding var showRightIcon: Bool
    @EnvironmentObject var programEnvironment: ProgramEnvironment
    
    var body: some View {
        VStack {
            ExerciseView(exercise: exercise, exerciseIndex: exerciseIndex)
        }
        .padding()
        .onAppear {
            showLeftIcon = exerciseIndex > 0
            showRightIcon = exerciseIndex < exerciseCount - 1
        }
    }
}
class WorkoutEnvironment: ObservableObject {
    @Published var workout: Workout
        
    init(workout: Workout) {
        self.workout = workout
    }
}
#Preview {
    WorkoutView(
        workout: Workout(
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
                ),
                Exercise(
                    name: "Pull-ups",
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
            completed: false
        )
    )
}

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
    @StateObject private var workoutService:WorkoutService
    @State private var workoutSession: HKWorkoutSession?
    @State private var workoutBuilder: HKWorkoutBuilder?
    @State private var isWorkoutActive = false
    @State var showLeftIcon = false
    @State var showRightIcon = false
    
    
    init(workout: Workout) {
        self._workout = State(initialValue: workout)
        self._workoutService = StateObject(wrappedValue: WorkoutService(fronteggAuth: FronteggApp.shared.auth))
    }
    
    let healthStore = HKHealthStore()

    var body: some View {
            VStack() {
                HStack{
                    Text(workout.name)
                        .font(.title)
                    Spacer()
                    if !workout.started {
                        Button(action: {
                            workoutService.startWorkout(workout: workout) { result in
                                switch result {
                                case .success(let updatedWorkout):
                                    DispatchQueue.main.async {
                                        DispatchQueue.main.async {
                                            self.workout = updatedWorkout
                                        }
                                        UIApplication.shared.isIdleTimerDisabled = true
                                        
                                        let healthStore = HKHealthStore()
                                        let configuration = HKWorkoutConfiguration()
                                        configuration.activityType = .other
                                        
                                        Task {
                                            do {
                                                try await healthStore.startWatchApp(with: configuration) { success, error in
                                                    if success {
                                                        print("Watch app started successfully")
                                                    } else if let error = error {
                                                        print("Failed to start watch app: \(error.localizedDescription)")
                                                    }
                                                }
                                            } catch {
                                                print("Failed to start watch app: \(error.localizedDescription)")
                                            }
                                        }
                                    }
                                case .failure(let error):
                                    print("Failed to start workout: \(error.localizedDescription)")
                                }
                            }
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
    
    func startWorkout() async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other // You can change this to match the specific workout type
        
        workoutBuilder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        do {
            try await workoutBuilder?.beginCollection(at: Date())
            isWorkoutActive = true
        } catch {
            print("Failed to start the workout: \(error.localizedDescription)")
            throw error
        }
    }
    
    func endWorkout() {
        Task {
            do {
                try await workoutBuilder?.endCollection(at: Date())
                let workout = try await workoutBuilder?.finishWorkout()
                isWorkoutActive = false
                print("Workout ended successfully")
            } catch {
                print("Failed to end the workout: \(error.localizedDescription)")
            }
        }
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

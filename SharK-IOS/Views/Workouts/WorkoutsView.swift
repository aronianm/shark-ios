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
    
    @State private var workoutDuration: TimeInterval = 0
    @State private var heartRate: Double = 0
    @State private var workoutTimer: Timer?
    @State private var heartRateQuery: HKQuery?

    let healthStore = HKHealthStore()

    init(workout: Workout) {
        self._workout = State(initialValue: workout)
        self._workoutService = StateObject(wrappedValue: WorkoutService(fronteggAuth: FronteggApp.shared.auth))
    }
    
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
                                        self.workout = updatedWorkout
                                        UIApplication.shared.isIdleTimerDisabled = true
                                        
                                        let healthStore = HKHealthStore()
                                        
                                        Task {
                                            do {
                                                let configuration = HKWorkoutConfiguration()
                                                configuration.activityType = .other
                                                configuration.locationType = .indoor
                                                
                                                let builder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
                                                
                                                try await builder.beginCollection(withStart: Date()) { success, error in
                                                    if success {
                                                        print("Workout collection began successfully")
                                                        self.workoutBuilder = builder
                                                        self.isWorkoutActive = true
                                                        print("Entered fitness mode on iPhone")
                                                        startWorkoutTimer()
                                                        startHeartRateQuery()
                                                    } else if let error = error {
                                                        print("Failed to begin workout collection: \(error.localizedDescription)")
                                                    }
                                                }
                                            } catch {
                                                print("Failed to setup workout: \(error.localizedDescription)")
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

            if workout.started {
                VStack(spacing: 20) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Workout Duration")
                                .font(.headline)
                            Text(formatDuration(workoutDuration))
                                .font(.title)
                                .fontWeight(.bold)
                        }
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text("Heart Rate")
                                .font(.headline)
                            Text("\(Int(heartRate)) BPM")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.vertical)
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
            .onAppear {
                setupHealthKitAuthorization()
                if(workout.started){
                    startWorkoutTimer()
                    startHeartRateQuery()
                }
            }
        }
    
    private func setupHealthKitAuthorization() {
        let typesToShare: Set = [HKObjectType.workoutType()]
        let typesToRead: Set = [HKObjectType.quantityType(forIdentifier: .heartRate)!]
        
        healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (success, error) in
            if success {
                print("HealthKit authorization successful")
            } else if let error = error {
                print("HealthKit authorization failed: \(error.localizedDescription)")
            }
        }
    }

    private func startWorkoutTimer() {
       let dateFormatter = DateFormatter()
       dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
       if let startDate = dateFormatter.date(from: workout.startedAt!) {
           workoutDuration = Date().timeIntervalSince(startDate)
           Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
               self.workoutDuration = Date().timeIntervalSince(startDate)
           }
       } else {
           print("Error: Unable to parse startedAt date")
       }
    }

    private func stopWorkoutTimer() {
        workoutTimer?.invalidate()
        workoutTimer = nil
    }

    private func startHeartRateQuery() {
        guard let heartRateType = HKObjectType.quantityType(forIdentifier: .heartRate) else { return }
        
        let query = HKAnchoredObjectQuery(type: heartRateType, predicate: nil, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            if let error = error {
                print("Error in heart rate query: \(error.localizedDescription)")
                return
            }
            
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            for sample in samples {
                DispatchQueue.main.async {
                    do {
                        self.heartRate = try sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                    } catch {
                        print("Error converting heart rate: \(error.localizedDescription)")
                    }
                }
            }
        }
        
        query.updateHandler = { (query, samples, deletedObjects, anchor, error) in
            guard let samples = samples as? [HKQuantitySample] else { return }
            
            for sample in samples {
                DispatchQueue.main.async {
                    self.heartRate = sample.quantity.doubleValue(for: HKUnit.count().unitDivided(by: .minute()))
                }
            }
        }
        
        healthStore.execute(query)
        self.heartRateQuery = query
    }

    private func stopHeartRateQuery() {
        if let query = heartRateQuery {
            healthStore.stop(query)
        }
    }

    private func formatDuration(_ duration: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad
        return formatter.string(from: duration) ?? "00:00:00"
    }

    func startWorkout() async throws {
        let configuration = HKWorkoutConfiguration()
        configuration.activityType = .other
        
        workoutBuilder = HKWorkoutBuilder(healthStore: healthStore, configuration: configuration, device: .local())
        
        do {
            try await workoutBuilder?.beginCollection(at: Date())
            isWorkoutActive = true
            startWorkoutTimer()
            startHeartRateQuery()
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
                stopWorkoutTimer()
                stopHeartRateQuery()
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
            completed: false,
            startedAt: nil
        )
    )
}

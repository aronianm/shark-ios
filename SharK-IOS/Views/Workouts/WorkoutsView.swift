//
//  WorkoutsView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI

struct WorkoutView: View {
    var workout: Workout
    @EnvironmentObject var programEnvironment: ProgramEnvironment
    var body: some View {
        VStack{
            VStack(alignment: .leading, spacing: 10) {
                HStack{
                    Text(workout.name)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 5)
                    Spacer()
                }
                .frame(maxWidth: .infinity, alignment: .center)
                if let exercises = workout.exercises, !exercises.isEmpty {
                    ForEach(Array(exercises.enumerated()), id: \.element.name) { index, exercise in
                        ExerciseView(exercise: exercise, exerciseIndex: index)
                    }.listStyle(InsetGroupedListStyle()).environment(\.defaultMinListRowHeight, 0)
                } else {
                    Text("No exercises for this workout")
                        .foregroundColor(.secondary)
                }
            }.padding().background(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray, lineWidth: 1)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(radius: 5)
            )
        }.padding().environmentObject(WorkoutEnvironment(workout: workout))
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
                        Set(reps: 10, weight: .string("BW"), completed: false),
                        Set(reps: 10, weight: .string("BW"), completed: false)
                    ],
                    superSetKey: nil
                ),
                Exercise(
                    name: "Pull-ups",
                    sets: [
                        Set(reps: 10, weight: .string("BW"), completed: false),
                        Set(reps: 10, weight: .string("BW"), completed: false)
                    ],
                    superSetKey: nil
                )
            ],
            createdAt: "2024-03-03",
            updatedAt: "2024-03-03",
            createdBy: "User",
            updatedBy: "User"
        )
    )
}

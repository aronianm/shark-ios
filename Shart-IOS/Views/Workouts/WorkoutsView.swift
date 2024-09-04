//
//  WorkoutsView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI

struct WorkoutView: View {
    var workout: Workout
    
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
                    ForEach(exercises, id: \.name) { exercise in
                        ExerciseView(exercise: exercise)
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
        }.padding()
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

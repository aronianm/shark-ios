//
//  ProgramDetailsView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI

struct ProgramDetailsView: View {
    var program: Program
    @State private var showWorkoutIndex = 0
    var body: some View {
        HStack{
            Picker("Select Workout", selection: $showWorkoutIndex) {
                ForEach(0..<program.workouts.count, id: \.self) { index in
                    Text("Workout \(index + 1)")
                        .tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
        }
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("Todays Workout")
                    .font(.title)
                    .padding(.horizontal)
                
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
                    .padding(.horizontal)
                }
            }
        }
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
            ]
        ))
    }
}

//#Preview {
//    ProgramDetailsView()
//}

//
//  ExerciseView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/3/24.
//

import SwiftUI

struct ExerciseView: View {
    var exercise: Exercise
    @State var showPopup = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text(exercise.name)
                .font(.headline)

                Button(action: {
                    showPopup.toggle()
                }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                }
                Spacer()
            }
            
            if let sets = exercise.sets, !sets.isEmpty {
                ForEach(Array(sets.enumerated()), id: \.offset) { index, set in
                    SetsCardView(index: index, set: set)
                }
            } else {
                Text("No sets for this exercise")
                    .foregroundColor(.secondary)
            }
        }.sheet(isPresented: $showPopup) {
                        VStack {
                            Text(exercise.name)
                                .font(.headline)
                                .padding()
                            Text("Preview of exercise coming soon")
                            Button("Close") {
                                self.showPopup.toggle()
                            }
                        }
                    }
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

struct ExerciseView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseView(exercise: Exercise(
            name: "Push-ups",
            sets: [
                Set(reps: 10, weight: .string("BW"), completed: false),
                Set(reps: 10, weight: .string("BW"), completed: false)
            ],
            superSetKey: nil
        ))
    }
}

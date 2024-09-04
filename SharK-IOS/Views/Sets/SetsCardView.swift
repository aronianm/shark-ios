//
//  SetsCardView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/3/24.
//

import SwiftUI

struct SetsCardView: View {
    let index: Int
    @State var set: Set
    
    var body: some View {
        HStack {
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
            Button(action: { set.completed.toggle() }) {
                Image(systemName: set.completed ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(set.completed ? .green : .gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
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
        index: 0,
        set: Set(reps: 10, weight: .string("BW"), completed: false)
    )
}

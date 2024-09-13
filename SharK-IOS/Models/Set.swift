//
//  Set.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import Foundation
struct WorkoutSet: Codable {
    let reps: Int
    let weight: WeightValue
    var completed: Bool
}

// sometimes the weight is Body Weight
enum WeightValue: Codable {
    case string(String)
    case number(Double)

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string("BW")
        } else if let numberValue = try? container.decode(Double.self) {
            self = .number(numberValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Weight must be either a string or a number")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        }
    }
}

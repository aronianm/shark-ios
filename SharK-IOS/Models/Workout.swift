//
//  Workout.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import Foundation

struct Workout: Codable {
    let id: Int
    let programId: Int
    let name: String
    let description: String?
    let day: String?
    let exercises: [Exercise]?
    let createdAt: String
    let updatedAt: String
    let createdBy: String
    let updatedBy: String
    let started: Bool
    let completed: Bool
    let startedAt: String?
}

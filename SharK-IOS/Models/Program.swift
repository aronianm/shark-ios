//
//  Program.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import Foundation

// Define models for the data
struct Program: Codable {
    let id: Int
    let name: String
    let createdAt: String
    let updatedAt: String
    let createdBy: String
    let updatedBy: String
    let active: Bool
    let started: Bool
    let userProgramId: Int
    let workouts: [Workout] // Optional because we may not have workouts for a program
}

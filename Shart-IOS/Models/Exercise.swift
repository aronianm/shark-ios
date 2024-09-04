//
//  Exercise.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import Foundation

struct Exercise: Codable {
    let name: String
    let sets: [Set]?
    let superSetKey: String?
}

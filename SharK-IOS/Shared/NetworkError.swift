//
//  NetworkError.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import Foundation
enum NetworkError: Error {
    case invalidURL
    case noData
    case decodingError(String)
}

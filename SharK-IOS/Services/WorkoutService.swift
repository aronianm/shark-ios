//
//  WorkoutService.swift
//  Shark-IOS
//
//  Created by Michael Aronian Aronian on 9/13/24.
//

import Foundation
import FronteggSwift

class WorkoutService:  ObservableObject {
    
    private let fronteggAuth: FronteggAuth
    
    init(fronteggAuth: FronteggAuth) {
        self.fronteggAuth = fronteggAuth
    }
    
    func startWorkout(workout: Workout, completion: @escaping (Result<Workout, Error>) -> Void) {
        guard let url = URL(string: "http://Michaels-MacBook-Air.local:3001/athletes/workouts/\(workout.id).json") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        var request = URLRequest(url: url)
        if let accessToken = self.fronteggAuth.accessToken {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = ["workout": ["started": true]]
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
        } catch {
            completion(.failure(error))
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                completion(.failure(URLError(.badServerResponse)))
                return
            }
            
            guard let data = data else {
                completion(.failure(URLError(.cannotParseResponse)))
                return
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            do {
                let updatedWorkout = try decoder.decode(Workout.self, from: data)
                completion(.success(updatedWorkout))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}

//
//  ProgramService.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import Foundation
import FronteggSwift

class ProgramService:  ObservableObject {

    private let fronteggAuth: FronteggAuth
    
    init(fronteggAuth: FronteggAuth) {
        self.fronteggAuth = fronteggAuth
    }

    func fetchProgram(programId: Int, completion: @escaping (Result<Program, Error>) -> Void) {

        let baseURL = "http://Michaels-MacBook-Air.local:3001/programs/\(programId).json"
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }

        var request = URLRequest(url: url)
        // set token in the header
        if let accessToken = self.fronteggAuth.accessToken  {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                print("Invalid response type")
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            print("HTTP Status Code: \(httpResponse.statusCode)")
            
            guard (200...299).contains(httpResponse.statusCode) else {
                print("HTTP request failed with status code: \(httpResponse.statusCode)")
                completion(.failure(NetworkError.invalidURL))
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(.failure(NetworkError.noData))
                return
            }
            
            print("Received data of size: \(data.count) bytes")

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let program = try decoder.decode(Program.self, from: data)
                completion(.success(program))
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    func fetchPrograms(completion: @escaping (Result<[Program], Error>) -> Void) {
        let baseURL = "http://Michaels-MacBook-Air.local:3001/programs.json"
        
        guard let url = URL(string: baseURL) else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        //        if let token = userDefaults.string(forKey: "token") {
        var request = URLRequest(url: url)
        // set token in the header
        if let accessToken = self.fronteggAuth.accessToken  {
            request.setValue("\(accessToken)", forHTTPHeaderField: "Authorization")
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // ... existing error handling ...

            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let programs = try decoder.decode([Program].self, from: data)
                completion(.success(programs))
                
                
            } catch {
                print("Decoding error: \(error)")
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
}

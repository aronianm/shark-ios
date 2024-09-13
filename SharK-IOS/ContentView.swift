//
//  ContentView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
import HealthKit

struct ContentView: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth
    @State private var healthKitAuthorized = false
    @State private var healthKitError: String?
    
    let healthStore = HKHealthStore()
    
    
    
    var body: some View {
        if fronteggAuth.isAuthenticated {
            SharkView().onAppear {
                    Task {
                        do {
                            try await requestHealthAuthorization()
                        } catch {
                            print("Error requesting HealthKit authorization: \(error)")
                        }
                    }
                }
        } else {
            WelcomeView() // Show when the user is not authenticated
        }
    }

        // Function to request HealthKit authorization
    func requestHealthAuthorization() async throws {
        // Define the health data types you want to read and write.
        // Define the health data types you want to read and write
        let typesToRead: Set<HKObjectType> = [
            HKObjectType.quantityType(forIdentifier: .stepCount)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!,
            HKObjectType.workoutType()
        ]
        
        guard let stepType = HKObjectType.quantityType(forIdentifier: .stepCount) else {
            throw HealthKitError.dataTypeNotAvailable
        }
        
        // Check if HealthKit is available on the device.
        if HKHealthStore.isHealthDataAvailable() {
            // Request authorization.
            try await healthStore.requestAuthorization(toShare: Set<HKSampleType>(), read: typesToRead)
        } else {
            throw HealthKitError.dataUnavailable
        }
    }
    
    // HealthKit-specific errors
    enum HealthKitError: Error {
        case dataTypeNotAvailable
        case dataUnavailable
    }

}


#Preview {
    FronteggWrapper {
        ContentView()
    }
}


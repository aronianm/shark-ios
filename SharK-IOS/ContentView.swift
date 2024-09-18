//
//  ContentView.swift
//  Shart-IOS
//
//  Created by Michael Aronian Aronian on 9/2/24.
//

import SwiftUI
import FronteggSwift
import HealthKit
import WatchConnectivity

struct ContentView: View {
    @EnvironmentObject var fronteggAuth: FronteggAuth
    @State private var healthKitAuthorized = false
    @State private var healthKitError: String?
    
    let healthStore = HKHealthStore()
    
    @State private var watchAppOpened = false
    
    func openWatchApp() {
        guard WCSession.isSupported() else { return }
        let session = WCSession.default
        if session.activationState == .activated {
            print("Sending message to open Watch App")
            session.sendMessage(["request": "openWatchApp"], replyHandler: nil) { error in
                print("Error sending message: \(error.localizedDescription)")
            }
            watchAppOpened = true
        } else {
            print("Watch session is not activated")
        }
    }
    
    var body: some View {
        if fronteggAuth.isAuthenticated {
            SharkView().onAppear {
                    Task {
                        do {
                            openWatchApp()
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
            HKObjectType.quantityType(forIdentifier: .appleExerciseTime)!,
            HKObjectType.quantityType(forIdentifier: .appleMoveTime)!,
            HKObjectType.quantityType(forIdentifier: .pushCount)!,
            HKObjectType.quantityType(forIdentifier: .restingHeartRate)!,
            HKObjectType.quantityType(forIdentifier: .appleStandTime)!,
        ]
        
        let typesToWrite: Set<HKSampleType> = [
            HKObjectType.workoutType(), // For writing workout data
            HKObjectType.quantityType(forIdentifier: .activeEnergyBurned)!,
            HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning)!,
            HKObjectType.quantityType(forIdentifier: .heartRate)!
        ]
        
        // Check if HealthKit is available on the device.
        if HKHealthStore.isHealthDataAvailable() {
            // Request authorization.
            try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
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


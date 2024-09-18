//
//  MainView.swift
//  SharkWatch Watch App
//
//  Created by Michael Aronian Aronian on 9/13/24.
//

import SwiftUI
import HealthKit

struct MainView: View {
    @State private var heartRate: String = "75 bpm"
    @State var heartError: String?
    @State private var timer: String = "00:00"
    @State private var currentExercise: String = "Running"
    @State private var numberOfReps: String = "10"
    
    private let healthStore = HKHealthStore()
    
    private func startHeartRateMonitoring() {
        guard HKHealthStore.isHealthDataAvailable() else {
            self.heartError = "HealthKit is not available on this device"
            return
        }
        
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            self.heartError = "Heart rate type is no longer available in HealthKit"
            return
        }
        
        healthStore.requestAuthorization(toShare: [], read: [heartRateType]) { success, error in
            if success {
                let query = HKObserverQuery(sampleType: heartRateType, predicate: nil) { _, completionHandler, error in
                    if let error = error {
                        self.heartError = "Failed to set up observer query: \(error.localizedDescription)"
                        return
                    }
                    self.fetchLatestHeartRateSample()
                    completionHandler()
                }
                self.healthStore.execute(query)
            } else if let error = error {
                self.heartError = "HealthKit authorization failed: \(error.localizedDescription)"
            } else {
                self.heartError = "HealthKit authorization denied"
            }
        }
        
       
        
        Task {
            do {
                try await healthStore.enableBackgroundDelivery(for: heartRateType, frequency: .immediate)
            } catch {
                self.heartError = "Failed to set up background delivery: \(error.localizedDescription)"
            }
        }
    }
    
    private func fetchLatestHeartRateSample() {
        guard let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate) else {
            return
        }
        
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        let query = HKSampleQuery(sampleType: heartRateType, predicate: nil, limit: 1, sortDescriptors: [sortDescriptor]) { _, results, error in
            if let error = error {
                self.heartError = "Failed to fetch heart rate sample: \(error.localizedDescription)"
                return
            }
            guard let sample = results?.first as? HKQuantitySample else { return }
            let heartRate = sample.quantity.doubleValue(for: HKUnit(from: "count/min"))
            DispatchQueue.main.async {
                self.heartRate = String(format: "%.0f bpm", heartRate)
            }
        }
        
        healthStore.execute(query)
    }
    
    var body: some View {
        VStack {
            if let error = heartError {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding()
            } else {
                HStack {
                    // Top Left: Heart Rate
                    VStack {
                        Text("Heart Rate")
                            .font(.subheadline)
                        Text("\(heartRate)")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Top Right: Timer
                    VStack {
                        Text("Timer")
                            .font(.subheadline)
                        Text(timer)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                }
                
                Spacer()
                
                HStack {
                    // Bottom Left: Current Exercise
                    VStack {
                        Text("Current Exercise")
                            .font(.subheadline)
                        Text(currentExercise)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    
                    // Bottom Right: Number of Reps
                    VStack {
                        Text("Reps")
                            .font(.subheadline)
                        Text(numberOfReps)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding()
                }
            }
        }
        .onAppear {
            startHeartRateMonitoring()
        }
    }
}

#Preview {
    MainView()
}

//
//  HealthStore.swift
//  Shark-IOS
//
//  Created by Michael Aronian Aronian on 9/12/24.
//

import Foundation
import HealthKit
import WidgetKit

class HealthKitManager: ObservableObject {
  static let shared = HealthKitManager()

  var healthStore = HKHealthStore()

  var stepCountToday: Int = 0
  var thisWeekSteps: [Int: Int] = [1: 0, 2: 0, 3: 0,]
}

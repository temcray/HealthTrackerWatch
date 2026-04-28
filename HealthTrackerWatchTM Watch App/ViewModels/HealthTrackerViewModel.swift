//
//  HealthTrackerViewModel.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/25/26.
//

import SwiftUI
import Combine
import Foundation

@MainActor
class HealthTrackerViewModel: ObservableObject {
    @Published var goals: UserGoals
    @Published var todaysCalories: Double = 0
    @Published var todaysWater: Double = 0
    
    
    var caloriesProgress: Double {
        min(todaysCalories / goals.dailyCaloriesGoal, 1.0)
        
    }
    
    var waterProgress: Double {
        min(todaysWater / goals.dailyWaterGoal, 1.0)
    }
    
    private let storgeManger = StorageManager.shared
    
    init() {
        self.goals = StorageManager.shared.loadGoals()
        refreshTodaysData()
    }
    
    func refreshTodaysData() {
        todaysCalories = storeManager.getTodaysTotal(for: .calories)
        todaysWater = storageManager.getTodaysTotal(for: .water)
    }
}

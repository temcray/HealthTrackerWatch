//
//  UserGoals.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/25/26.
//

import Foundation

struct UserGoals: Codable {
    var dailyCaloriesGoal: Double
    var dailyWaterGoal: Double
    
    static let defaultGoals = UserGoals(
        dailyCaloriesGoal: 2000,
        dailyWaterGoal: 2000
    )
}

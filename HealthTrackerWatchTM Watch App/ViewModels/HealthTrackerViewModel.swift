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
class HealtTrackerViewModel: ObservableObject {
    @Published var goals: UserGoals
    @Published var todaysCalories: Double = 0
    @Published var todaysWater: Double = 0
    
    @Published var useHealthKit: Bool = false
    @Published var hkAuthStatus: String = "Not Requested"
    
    // MARK: - Hearth Rate State Variables
    @Published var currentHeartRate: Double = 0
    @Published var isMonitoringHeartRate: Bool = false
    @Published var isHealthKitHeartRateAuthorized: Bool = false
    // @Published var heartRateError: String?
    @Published var lastHeartRateUpdate: Date?
    @Published var maxHeartRate: Double = 190.0
    
    var caloriesProgress: Double {
        min(todaysCalories / goals.dailyCaloriesGoal, 1.0)
    }
    
    var waterProgress: Double {
        min(todaysWater / goals.dailyWaterGoal, 1.0)
    }
    
    // MARK: - View Model For Storage Manager
    private let storageManager = StorageManager.shared
    private let healthKitManager = HealthKitManager.shared
    
    init() {
        self.goals = StorageManager.shared.loadGoals()
        refreshTodaysData()
    }
    
    func updateGoals(calories: Double, water: Double) {
        goals = UserGoals(dailyCaloriesGoal: calories, dailyWaterGoal: water)
        storageManager.saveGoals(goals)
    }
    
    func addCalories(_ amount: Double) {
        let entry = DiaryEntry(type: .calories, value: amount)

        if useHealthKit {
            Task {
                do {
                    try await healthKitManager.addEntry(entry)
                    // Give HealthKit a moment to index the data
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    // Refresh to get updated totals from HealthKit
                    await refreshTodaysData()
                    print("Successfully added \(amount) calories to HealthKit")
                } catch {
                    print("Error adding calories to HealthKit: \(error)")
                    // Fallback to local storage
                    await MainActor.run {
                        storageManager.addEntry(entry)
                        todaysCalories += amount
                    }
                }
            }
        } else {
            storageManager.addEntry(entry)
            todaysCalories += amount
        }
    }

    func addWater(_ amount: Double) {
        let entry = DiaryEntry(type: .water, value: amount)

        if useHealthKit {
            Task {
                do {
                    try await healthKitManager.addEntry(entry)
                    // Give HealthKit a moment to index the data
                    try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                    // Refresh to get updated totals from HealthKit
                    await refreshTodaysData()
                    print("Successfully added \(amount) ml water to HealthKit")
                } catch {
                    print("Error adding water to HealthKit: \(error)")
                    // Fallback to local storage
                    await MainActor.run {
                        storageManager.addEntry(entry)
                        todaysWater += amount
                    }
                }
            }
        } else {
            storageManager.addEntry(entry)
            todaysWater += amount
        }
    }
    
    func refreshTodaysData() async {
        print("Refreshing data... Source: \(useHealthKit ? "HealthKit" : "Local Storage")")

        if useHealthKit {
            do {
                let calories = try await healthKitManager.getTodaysTotal(for: .calories)
                let water = try await healthKitManager.getTodaysTotal(for: .water)

                print("HealthKit data - Calories: \(calories), Water: \(water)")

                // Update on main thread
                await MainActor.run {
                    todaysCalories = calories
                    todaysWater = water
                    print("UI Updated - Calories: \(todaysCalories), Water: \(todaysWater)")
                }
            } catch {
                print("HealthKit error: \(error) - Falling back to local storage")
                // Fallback to storage on error
                await MainActor.run {
                    todaysCalories = storageManager.getTodaysTotal(for: .calories)
                    todaysWater = storageManager.getTodaysTotal(for: .water)
                }
            }
        } else {
            await MainActor.run {
                todaysCalories = storageManager.getTodaysTotal(for: .calories)
                todaysWater = storageManager.getTodaysTotal(for: .water)
                print("Local data - Calories: \(todaysCalories), Water: \(todaysWater)")
            }
        }
    }

    func refreshTodaysData() {
        Task {
            await refreshTodaysData()
        }
    }
    
    // MARK: - HealthKit
    
    func toggleUseHealthKith() {
        useHealthKit = !useHealthKit
    }
    
    func requestHealthKitAuth() async {
        do {
            try await healthKitManager.requestAuth()
            hkAuthStatus = "Authorized"
            isHealthKitHeartRateAuthorized = true
            await refreshTodaysData()
        } catch {
            hkAuthStatus = "Failed Auth"
        }
    }
    
    // MARK: - Heart Rate Methods
    func handleHeartRateSamples(_ samples: [HeartRateSample]) {
        if let latestSample = samples.first {
            currentHeartRate = latestSample.bpm
            lastHeartRateUpdate = latestSample.timestamp
        }
    }
    
    func startHeartRateMonitoring() {
        isMonitoringHeartRate = true
        healthKitManager.startHearthRateMonitoring { [weak self] samples in
            Task { @MainActor in
                self?.handleHeartRateSamples(samples)
            }
        }
    }
    
    func stopHeartRateMonitoring() {
        healthKitManager.stopHearthRateMonitoring()
        isMonitoringHeartRate = false
    }
    
    func toggleHeartRateMonitoring() {
        if isMonitoringHeartRate {
            stopHeartRateMonitoring()
        } else {
            startHeartRateMonitoring()
        }
    }
    
}

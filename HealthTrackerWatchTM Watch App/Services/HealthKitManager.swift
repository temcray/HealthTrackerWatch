//
//  HealthKitManager.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/2/26.
//

import Foundation
import Combine
import HealthKit

class HealthKitManager {
    // MARK: - Singleton
    static let shared = HealthKitManager()
    private init() {}
    
    let healthStore = HKHealthStore()
    
    // MARK: - HealthKit Types
    private let caloriesType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    private let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
    
    // MARK: - Units
    private let caloriesUnit = HKUnit.kilocalorie()
    private let waterUnit = HKUnit.literUnit(with: .milli)
    
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    func requestAuth() async throws {
        let typesToRead: Set<HKObjectType> = [caloriesType, waterType]
        let typesToWrite: Set<HKSampleType> = [caloriesType, waterType]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    func checkAuthStatus(for type: EntryType) -> Bool {
        let caloriesAuthStatus: HKAuthorizationStatus = healthStore.authorizationStatus(for: caloriesType)
        let waterAuthStatus = healthStore.authorizationStatus(for: waterType)
        
        return caloriesAuthStatus == .sharingAuthorized && waterAuthStatus == .sharingAuthorized
    }
    
    func getTodaysTotal(for type: EntryType) async throws -> Double {
        let hkType = type == .calories ? caloriesType : waterType
        let unit = type == .calories ? caloriesUnit : waterUnit

        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)

        print("Fetching today's \(type.displayName) from HealthKit...")
        print("Time range: \(startOfDay) to \(endOfDay ?? now)")

        let predicate = HKQuery.predicateForSamples(
            withStart: startOfDay, end: endOfDay, options: .strictStartDate
        )

        return try await withCheckedThrowingContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: hkType,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, samples, error in
                if let error = error {
                    print("Error fetching \(type.displayName): \(error)")
                    continuation.resume(throwing: error)
                    return
                }

                let sum = samples?.sumQuantity()?.doubleValue(for: unit) ?? 0.0
                print("Fetched \(sum) \(type.displayName) from HealthKit")
                continuation.resume(returning: sum)
            }

            healthStore.execute(query)
        }
    }
    
    func addEntry(_ entry: DiaryEntry) async throws {
        let hkType = entry.type == .calories ? caloriesType : waterType
        let unit = entry.type == .calories ? caloriesUnit : waterUnit

        print("Adding \(entry.value) \(entry.type.displayName) to HealthKit...")

        let quantity = HKQuantity(unit: unit, doubleValue: entry.value)
        let sample = HKQuantitySample(
            type: hkType,
            quantity: quantity,
            start: entry.timestamp,
            end: entry.timestamp
        )

        try await healthStore.save(sample)
        print("Saved to HealthKit successfully")
    }
}

//
//  HealthKitManager.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/2/26.
//

import Foundation
import HealthKit

class HealthKitManager {
    // MARK: - Singleton
    static let shared = HealthKitManager()
    private init() {}
    
    let healthStore = HKHealthStore()
    
    // MARK: - Error TRackers
    private var heartRateErrors = ""
    
    // MARK: - HealthKit Types
    private let caloriesType = HKQuantityType.quantityType(forIdentifier: .dietaryEnergyConsumed)!
    private let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
    private let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
    
    // MARK: - Units
    private let caloriesUnit = HKUnit.kilocalorie()
    private let waterUnit = HKUnit.literUnit(with: .milli)
    private let heartRaterUnit = HKUnit(from: "count/min") // BPM
    
    // MARK: - Query
    private var heartRateQuery: HKAnchoredObjectQuery?
    
    // MARK: - Computed Props
    var isHealthDataAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }
    
    // MARK: - Methods Section (Auth)
    func requestAuth() async throws {
        let typesToRead: Set<HKObjectType> = [caloriesType, waterType, heartRateType]
        let typesToWrite: Set<HKSampleType> = [caloriesType, waterType]
        
        try await healthStore.requestAuthorization(toShare: typesToWrite, read: typesToRead)
    }
    
    func checkAuthStatus(for type: EntryType) -> Bool {
        let caloriesAuthStatus: HKAuthorizationStatus = healthStore.authorizationStatus(for: caloriesType)
        let waterAuthStatus = healthStore.authorizationStatus(for: waterType)
        
        return caloriesAuthStatus == .sharingAuthorized && waterAuthStatus == .sharingAuthorized
    }
    
    func checkHearthRateAuthorizationStatus () -> HKAuthorizationStatus {
        healthStore.authorizationStatus(for: heartRateType)
    }
    
    
    // MARK: - Methods Section (Water Calories)
    func getTodaysTotal(for type: EntryType) async throws -> Double {
        let hkType = type == .calories ? caloriesType : waterType
        let unit = type == .calories ? caloriesUnit : waterUnit
        
        let calendar = Calendar.current
        let now = Date()
        let startOfDay = calendar.startOfDay(for: now)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)
        
        print("Fetching today's \(type.displayType) from HealthKit...")
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
                    print("Error fetching \(type.displayType): \(error)")
                    continuation.resume(throwing: error)
                    return
                }
                
                let sum = samples?.sumQuantity()?.doubleValue(for: unit) ?? 0.0
                print("Fetched \(sum) \(type.displayType) from HealthKit")
                continuation.resume(returning: sum)
            }
            
            healthStore.execute(query)
        }
    }
    
    func addEntry(_ entry: DiaryEntry) async throws {
        let hkType = entry.type == .calories ? caloriesType : waterType
        let unit = entry.type == .calories ? caloriesUnit : waterUnit
        
        print("Adding \(entry.value) \(entry.type.displayType) to HealthKit...")
        
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
    
    // MARK: - Hearth Rate Methods
    
    // This func transforms HKSample coming from HKStore to the
    // custome heart rate sample model that our app will use for
    // simplicity
    func processHeartRateSamples(samples: [HKSample]?, onUpdate: @escaping ([HeartRateSample]) -> Void) {
        guard let quantitySamples = samples as? [HKQuantitySample], !quantitySamples.isEmpty else { return }
        
        let heartRateSamples: [HeartRateSample] = quantitySamples.map { sample in
                HeartRateSample(
                    bpm: sample.quantity.doubleValue(for: heartRaterUnit),
                    timestamp: sample.startDate)
        }
        
        DispatchQueue.main.async {
            onUpdate(heartRateSamples)
        }
    }
    
    func startHearthRateMonitoring(onUpdate: @escaping ([HeartRateSample]) -> Void) {
        stopHearthRateMonitoring()
        
        let query = HKAnchoredObjectQuery(
            type: heartRateType,
            predicate: nil,
            anchor: nil,
            limit: HKObjectQueryNoLimit
        ) { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self,
                  let error = error else {
                self?.heartRateErrors = "Something wrong happened while getting heart Rate Data"
                return
            }
            self.processHeartRateSamples(samples: samples, onUpdate: onUpdate)
        }
        
        query.updateHandler = { [weak self] query, samples, deletedObjects, anchor, error in
            guard let self = self,
                  let error = error else {
                self?.heartRateErrors = "Something wrong happened while getting heart Rate Data"
                return
            }
            self.processHeartRateSamples(samples: samples, onUpdate: onUpdate)
        }
        
        
        self.heartRateQuery = query
        healthStore.execute(query)
    }
    
    // startHearthRateMonitoring() { heartRateSamples in
    //     -- you process the samples in here
    // }

    func stopHearthRateMonitoring() {
        if let query = self.heartRateQuery {
            healthStore.stop(query)
            heartRateQuery = nil
        }
    }
}

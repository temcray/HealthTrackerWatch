//
//  MotionManager.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/9/26.
//

import CoreMotion
import Foundation
import Combine

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    // MARK: - Published Properties
    @Published var accelerometerData: (x: Double, y: Double, z: Double) = (0, 0, 0) // 1.0 G
    @Published var gyroscopeData: (x: Double, y: Double, z: Double) = (0, 0, 0)  // Radians
    @Published var currentUserActivity: ActivityType?
    
    @Published var errorMessage: String?
    @Published var shakeDetected: Bool = false
    
    // MARK: - Private Properties
    private let motionManager = CMMotionManager() // To Get Raw Sensors data
    private let activityManager = CMMotionActivityManager() // This sub-module from CM allow us to get procesed data into real metrics like steps count, activity Type
    private let updateInterval: TimeInterval = 0.1 // 10 HZ
    
    private var shakeThreshold: Double = 2.5 // Magnitude For 3-Axis Motion root_sqr(x^2 + y^2 + z^2) =
    private var lastShakeTime: Date = .distantPast
    private var shakeDebounceInterval: TimeInterval = 1.0
    
    // MARK: - Computed Props
    var isAccelerometerAvailable: Bool {
        motionManager.isAccelerometerActive
    }
    
    var isGyroscopeAvailable: Bool {
        motionManager.isGyroAvailable
    }
    
    var isActivityAvailable: Bool {
        CMMotionActivityManager.isActivityAvailable()
    }
    
    // MARK: - Initialization
    private init() {
        motionManager.accelerometerUpdateInterval = updateInterval
        motionManager.gyroUpdateInterval = updateInterval
    }
    
    // MARK: - Public Methods
    
    func startShakeDetection() {
        startActivityUpdates()
    }
    
    func startActivityTracking() {
        startActivityUpdates()
    }
    
    private func startAccelerometer() {
        guard isAccelerometerAvailable else {
            errorMessage = "Accelerometer Not Available"
            return
        }
        
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else {
                if let error = error {
                    self?.errorMessage = "Accelerometer not available"
                }
                return
            }
            
            self.accelerometerData = (
                x: data.acceleration.x,
                y: data.acceleration.y,
                z: data.acceleration.z,
            )
            
            self.detectShake(acceleration: data.acceleration)
        }
    }
    
    private func startGyroscope() {
        guard isGyroscopeAvailable else {
            return
        }
        
        motionManager.startGyroUpdates(to: .main) { [weak self] data, error in
            guard let self = self, let data = data else {
                return
            }
            
            self.gyroscopeData = (
                x: data.rotationRate.x,
                y: data.rotationRate.y,
                z: data.rotationRate.z
            )
        }
    }
    
    private func startActivityUpdates() {
        guard isActivityAvailable else {
            return
        }
        
        activityManager.startActivityUpdates(to: .main) { [weak self] activityData in
            guard let self = self, let activityData = activityData else {
                return
            }
            
            self.currentUserActivity = ActivityType.from(activityData)
        }
    }
    
    private func detectShake(acceleration: CMAcceleration) {
        let magnitude = sqrt(
            pow(acceleration.x, 2) +
            pow(acceleration.y, 2) +
            pow(acceleration.z, 2)
        )
        
        let now = Date()
        if magnitude > shakeThreshold && now.timeIntervalSince(lastShakeTime) > shakeDebounceInterval {
            lastShakeTime = now
            
            DispatchQueue.main.async {
                self.shakeDetected = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.shakeDetected = false
                    
                }
            }
        }
    }
    
}

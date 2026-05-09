//
//  AcivityTtpe.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/9/26.
//

import CoreMotion
import Foundation
import Combine


enum ActivityType: String {
    case stationary = "Stationary"
    case walking = "Walking"
    case running = "Running"
    case cycling = "Cycling"
    case automotive = "Automotive"
    case unknown = "Unknown"
    
    
    var icon: String {
        switch self {
        case .stationary: return "figure.stand"
        case .walking: return "figure.walk"
        case .running: return "figure.run"
        case .cycling: return "figure.outdoor.cycle"
        case .automotive: return "car.fill"
        case .unknown: return "questionmark.circle"
        }
    }
    
    static func from(_ cmActivity: CMMotionActivity) -> ActivityType {
           if cmActivity.stationary {
               return .stationary
           } else if cmActivity.walking {
               return .walking
           } else if cmActivity.running {
               return .running
           } else if cmActivity.cycling {
               return .cycling
           } else if cmActivity.automotive {
               return .automotive
           } else {
               return .unknown
           }
       }
   
}

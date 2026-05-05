//
//  HeartRateSample.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/2/26.
//

import Foundation
import Combine

struct HeartRateSample: Identifiable {
    let id: UUID
    let bpm: Double
    let timestamp: Date
    
    var formttedBpm: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        return formatter.string(from: timestamp)
    }
}

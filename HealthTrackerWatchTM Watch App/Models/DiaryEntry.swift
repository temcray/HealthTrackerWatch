//
//  DiaryEntry.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/23/26.
//

import Foundation
import SwiftUI


enum EntryType: String, Codable, CaseIterable {
    case calories = "calories"
    case water = "water"
    
    var icon: String {
        switch self {
        case .calories: return "flame.fill"
        case .water: return "drop.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .calories: return .orange
        case .water: return .cyan
        }
    }
    
    var displayType: String {
        switch self {
        case .calories: return "Calories"
        case .water: return "water"
        }
    }
    
    var unit: String {
        switch self{
        case .calories: return "kCal"
        case .water: return "ml"
        }
    }
    
    struct DiaryEntry: Identifiable, Codable {
        let id: UUID
        let type: EntryType
        let value: Double
        let timestamp: Date
        
       
        init(id: UUID, type: EntryType, value: Double, timestamp: Date) {
            self.id = id
            self.type = type
            self.value = value
            self.timestamp = timestamp
        }
    }
}

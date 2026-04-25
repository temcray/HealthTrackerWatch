//
//  StrongeManager.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/23/26.
//

import Foundation
import Combine


// singleton
class StrongeManager {
    static let shared = StrongeManager()
    private init() {}
    
    
    // Mark: - Keys
    private enum Keys {
        static let diaryEntries = "diary_Entries"
        static let userGoals = "user_Goals"
    }
    
    // Mark: - private props
    private let defaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONEncoder()
    
    //Mark: - Function
    func saveEntries(_entries: [DiaryEntry]) {
        if let encodedeEntries = try? encoder.encode(entries) {
            defaults.set(encodedeEntries, forKey: Keys.diaryEntries)
        }
        
    }
    
    func loadEntries() -> [DiaryEntry]? {
        gruard let encodeDiaryEntries = defaults.data(forKey: Keys.diaryEntries),
                   let diaryEntries = try? decoder.decoder([DiaryEntry].self, from: encodedDiaryEntries) eles {
                       return []
                   }
    }
}

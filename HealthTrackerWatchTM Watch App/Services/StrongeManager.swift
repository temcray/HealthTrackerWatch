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
    private let decoder = JSONDecoder()
    
    //Mark: - Function
    func saveEntries(_ entries: [DiaryEntry]) {
        if let encoded = try? encoder.encode(entries) {
            defaults.set(encoded, forKey: Keys.diaryEntries)
        }
        
    }
    
    func loadEntries() -> [DiaryEntry] {
        guard let encodeDiaryEntries = defaults.data(forKey: Keys.diaryEntries),
        let diaryEntries = try? decoder.decode([DiaryEntry].self, from: encodeDiaryEntries) else {
            return []
        }
        
        return diaryEntries
    }
    
    func addEntry(_ entry: DiaryEntry) {
        var entries = loadEntries()
        entries.append(entry)
        saveEntries(entries)
    }
    
    // Mark: - user Goals Section
    
    
    func saveGoals(_ goals: UserGoals) {
        if let encodeGoals = try? encoder.encode(goals){
            defaults.set(encoder, forKey: Keys.userGoals)
        }
    }
    
    func loadGoals() -> UserGoals {
        guard let encodedGoals = defaults.data(forKey: Keys.userGoals),
              let userGoals = try? decoder.decode(UserGoals.self, from: encodedGoals) else {
            return UserGoals.defaultGoals
        }
        
        return userGoals
    }
    
    func getTodayEntries() -> [DiaryEntry] {
        let allTimeEntries = loadEntries()
        
        let calender = Calender.current
        let startofDayToday = calendar.startOfDay(for: Date())
        
        return allTimeEntries.filter {entry in
            calender.isDate(entry.timestamp, inSameDayAs: startOfDayToday)
        }
    }
    
    func getTodaysTotal(for type: EntryType) -> Double {
        getTodaysEntries()
            .filter {$0.type == type }
            .reduce(0) {$0 + $1.value}
    }
    
}

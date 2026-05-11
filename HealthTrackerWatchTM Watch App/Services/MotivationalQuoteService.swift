//
//  MotivationalQuoteService.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/9/26.
//

import Foundation
import Combine

class MotivationalQuoteService {
    static let shared = MotivationalQuoteService()
    private init() {}
    
    private let apiURL = "https://zenquotes.io/api/random"
    
    private let lastFallbackQuotesSyncTime: Date = Date()
    private let fallbackQuotes: [MotivationlQuote] = [
            MotivationlQuote(quote: "Every step counts towards your goal!", author: "Health Wisdom"),
            MotivationlQuote(quote: "Hydration is the foundation of health.", author: "Health Wisdom"),
        ]
    
    func fetchQuote() async -> MotivationlQuote {
        if fallbackQuotes.count > 0  && lastFallbackQuotesSyncTime.timeIntervalSinceNow > 60.0 {
            return fallbackQuotes.randomElement() ?? fallbackQuotes[0]
        }
        guard let url = URL(string: apiURL) else {
            return fallbackQuotes.randomElement() ?? MotivationlQuote(quote: "Every step counts towards your goal!", author: "Health Wisdom")
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let response = try JSONDecoder().decode([MotivationlQuote.APIResponse].self, from: data)
        } catch {
            print("API Error")
        }
    }
   
}

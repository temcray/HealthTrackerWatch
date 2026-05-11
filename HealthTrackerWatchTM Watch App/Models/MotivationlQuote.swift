//
//  MotivationlQuote.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/9/26.
//

import Foundation
import Combine

struct MotivationlQuote: Codable {
    let quote: String
    let author: String
    
    
    static APIResponse: Codable {
        let q: String
        let a: String
    }
    
    static func from(apiResponse: MotivationlQuote.APIResponse) -> MotivationalQuote {
        return MotivationalQuote(
            quote: quote.q, author: quote.a
        )
    }
}

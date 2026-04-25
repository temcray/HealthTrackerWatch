//
//  MainDashboardView.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/23/26.
//

import SwiftUI

struct MainDashboardView: View {
    var body: some View {
        ScrollView {
           VStack (spacing: 16){
                Text("Today")
                   .font(.system(size: 14, weight: .medium))
                   .foregroundColor(.gray)
            }
            
            HStack(spacing: 20){
                VStack(spacing: 6){
                    //water ring
                    ProgressRingView(
                        color: .cyan,
                        progress: 0.5,
                        icon: "drop.fill",
                        size: 55
                    )
                    //today water intake / goal <--text
                    Text("/(Int(1000))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    // diplay the measure ml / litters
                    Text("/(Int(2000)) ml")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 6){
                    ProgressRingView(
                        color: .cyan,
                        progress: 0.5,
                        icon: "drop.fill",
                        size: 55
                    )
                    
                    Text("/(Int(1000))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.cyan)
                    
                    Text("/(Int(2000)) ml")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                   
                }
                
            }
        }
    }
}

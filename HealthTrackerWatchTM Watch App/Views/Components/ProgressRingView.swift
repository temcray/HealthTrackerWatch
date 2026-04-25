//
//  ProgressRingView.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/23/26.
//

import SwiftUI

struct ProgressRingView: View {
    // color, progress, icon, size
    let color: Color
    let progress: Double
    let icon: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            //backgroundColor
            Circle()
                .stroke(color.opacity(0.2), lineWidth: 8)
               
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    color,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.5))
                .foregroundColor(color)
                
        }
        .frame(width: size, height: size)
    }
    
}


#Preview {
    HStack(spacing: 16){
        ProgressRingView(
            color: .cyan,
            progress: 0.3,
            icon: "drop.fill",
            size: 90
            )
    
    
       ProgressRingView(
            color: .orange,
            progress: 0.5,
            icon: "flame.fill",
            size: 90
           )
    }
 
}

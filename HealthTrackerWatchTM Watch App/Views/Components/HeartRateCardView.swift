//
//  HeartRateCardView.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 5/2/26.
//

import SwiftUI

struct HeartRateCardView: View {
    @ObservedObject var viewModel: HealtTrackerViewModel
    
    @State private var isHeartPulsing = false
    
    private var pulseDuration: Double {
        return 60.0 / viewModel.currentHeartRate
    }
    
    private var isBeating: Bool {
        viewModel.isMonitoringHeartRate
    }
    
    private func handleTapEvent() {
        if !viewModel.isHealthKitHeartRateAuthorized {
            Task {
                await viewModel.requestHealthKitAuth()
            }
        } else {
            viewModel.toggleHeartRateMonitoring()
        }
    }
    
    private var cardBackground: some View {
        if !viewModel.isHealthKitHeartRateAuthorized {
            Color.orange.opacity(0.12)
        } else {
            switch viewModel.currentHeartRate {
            case 40...70: Color.green.opacity(0.12)
            case 70...120: Color.yellow.opacity(0.12)
            case 120...160: Color.orange.opacity(0.12)
            default: Color.red.opacity(0.12)
            
            }
        }
    }
    
    private var animatedHeart: some View {
        Image(systemName: isBeating ? "heart.fill" : "heart")
            .font(.system(size: 20))
            .foregroundColor(.red)
            .scaleEffect(isHeartPulsing && isBeating ? 1.15: 1.0)
            .animation(
                isBeating ? .easeInOut(duration: pulseDuration / 2).repeatForever() : .default,
                value: isHeartPulsing
            )
    }
    
    private var heartRateDisplay: some View {
        VStack(alignment: .leading, spacing: 1) {
            if !viewModel.isHealthKitHeartRateAuthorized {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("--")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("BPM")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                    
                    Text("Tap To Authorize")
                        .font(.system(size: 8))
                        .foregroundColor(.orange)
                }
            } else {
                HStack(alignment: .lastTextBaseline, spacing: 2) {
                    Text("\(Int(viewModel.currentHeartRate))")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.orange)
                    Text("BPM")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
            }
        }
    }
    
    var body: some View {
        Button {
            handleTapEvent()
        } label: {
            HStack(spacing: 20) {
                animatedHeart
                
                Spacer()
                // Status Indicator
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(cardBackground)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            if isBeating {
                // start pulse
            }
        }
        .onChange(of: isBeating) { _, newValue in
            if newValue {
                //startPulse
            } else {
                //stop pulse
            }
        }
        .onChange(of: viewModel.currentHeartRate) {
            // restart pulse
        }
    }
}

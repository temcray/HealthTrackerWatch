//
//  HealthTrackerWatchTMApp.swift
//  HealthTrackerWatchTM Watch App
//
//  Created by Tatiana6mo on 4/23/26.
//

import SwiftUI

@main
struct HealthTracker_Watch_AppApp: App {
    @StateObject private var viewModel = HealtTrackerViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainDashboardView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.refreshTodaysData()
                Task {
                    await viewModel.requestHealthKitAuth()
                }
            }
        }
    }
}

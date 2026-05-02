//
//  HealthTrackerWatchTMApp.swift
//  HealthTrackerWatchTM Watch App
//
//  Created by Tatiana6mo on 4/23/26.
//

import SwiftUI
import Combine

@main
struct HealthTrackerWatchTM_Watch_AppApp: App {
    @StateObject private var viewModel = HealthTrackerViewModel()
    
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainDashboardView(viewModel: viewModel)
                
              }
            .onAppear {
                viewModel.refreshTodaysData()
            }
        }
    }
}

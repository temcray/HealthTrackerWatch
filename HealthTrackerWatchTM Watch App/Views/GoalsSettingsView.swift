//
//  GoalsSettingsView.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/28/26.
//

import SwiftUI

struct GoalsSettingsView: View {
    @ObservedObject var viewModel: HealtTrackerViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var caloriesGoal: Double
    @State private var waterGoal: Double
    
    private var quickAddOptions: [Double] {
        return [1500, 2000, 2500, 3000]
    }
    
    init(viewModel: HealtTrackerViewModel) {
        self.viewModel = viewModel
        _caloriesGoal = State(initialValue: viewModel.goals.dailyCaloriesGoal)
        _waterGoal = State(initialValue: viewModel.goals.dailyWaterGoal)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // HealthKit Toggle Section
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "heart.fill")
                            .foregroundColor(.red)
                        Text("Data Source")
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                    }
                    
                    Toggle(isOn: $viewModel.useHealthKit) {
                        HStack {
                            Image(systemName: viewModel.useHealthKit ? "applelogo" : "internaldrive")
                                .foregroundColor(.white)
                                .font(.system(size: 13))
                            Text(viewModel.useHealthKit ? "HealthKit" : "Local Storage")
                                .font(.system(size: 11))
                        }
                    }
                    .onChange(of: viewModel.useHealthKit) { newValue in
                        Task {
                            if newValue {
                                // Request permission if switching to HealthKit
                                await viewModel.requestHealthKitAuth()
                            }
                            // Refresh data from new source
                            await viewModel.refreshTodaysData()
                        }
                    }
                }
                .padding(4)
                Divider()
                // Calories Goal Section
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: EntryType.calories.icon)
                            .foregroundColor(EntryType.calories.color)
                        Text("\(EntryType.calories.displayName) Goal")
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                    }
                    
                    Text("\(Int(caloriesGoal)) kcal")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(EntryType.calories.color)
                    
                    HStack(spacing: 6) {
                        ForEach(quickAddOptions, id: \.self) { preset in
                            Button {
                                caloriesGoal = preset
                            } label: {
                                Text("\(Int(preset))k")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        caloriesGoal == preset
                                        ? EntryType.calories.color
                                        : EntryType.calories.color.opacity(0.2)
                                    )
                                    .foregroundColor(caloriesGoal == preset ? .black : EntryType.calories.color)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                Divider()
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: EntryType.water.icon)
                            .foregroundColor(EntryType.water.color)
                        Text("\(EntryType.water.displayName) Goal")
                            .font(.system(size: 13, weight: .medium))
                        Spacer()
                    }
                    
                    Text("\(Int(waterGoal)) kcal")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(EntryType.water.color)
                    
                    HStack(spacing: 6) {
                        ForEach(quickAddOptions, id: \.self) { preset in
                            Button {
                                waterGoal = preset
                            } label: {
                                Text("\(Int(preset))k")
                                    .font(.system(size: 11, weight: .medium))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 6)
                                    .background(
                                        waterGoal == preset
                                        ? EntryType.water.color
                                        : EntryType.water.color.opacity(0.2)
                                    )
                                    .foregroundColor(waterGoal == preset ? .black : EntryType.water.color)
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                
                Button {
                    viewModel.updateGoals(calories: caloriesGoal, water: waterGoal)
                    dismiss()
                } label: {
                    Text("Save Goals")
                        .font(.system(size: 14, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.green)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
              
            }
            .padding(8)
        }
        .navigationTitle("Goals")
        .navigationBarTitleDisplayMode(.inline)
    }
}

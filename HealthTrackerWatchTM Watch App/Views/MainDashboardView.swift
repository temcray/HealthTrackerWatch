//
//  MainDashboardView.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/23/26.
//

import SwiftUI

struct MainDashboardView: View {
    @ObservedObject var viewModel: HealthTrackerViewModel
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
                        color: EntryType.water.color,
                        progress: viewModel.waterProgress,
                        icon: EntryType.water.icon,
                        size: 55
                    )
                    //today water intake / goal <--text
                    Text("/(Int(viewModel.todaysWater))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(EntryType.water.color)
                    // diplay the measure ml / litters
                    Text("/(Int(viewModel.goals.dailyWaterGoal)) ml")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                }
                
                VStack(spacing: 6){
                    ProgressRingView(
                        color: EntryType.calories.color,
                        progress: viewModel.caloriesProgress,
                        icon: EntryType.calories.icon,
                        size: 55
                    )
                    
                    Text("/(Int(viewModel.todaysCalories))")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(EntryType.calories.color)
                    
                    Text("/(Int(viewModel.goals.dailyCaloriesGoal)) kcal")
                        .font(.system(size: 9))
                        .foregroundColor(.gray)
                   
                }
                
            }
            
            HStack(spacing: 12){
                NavigationLink(destination: AddEntryView(viewModel: viewModel, entryType: .water)) {
                    QuickAddButton(
                        icon: "plus",
                        label: EntryType.water.displayType,
                        color: EntryType.water.color
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                NavigationLink(destination: AddEntryView(viewModel: viewModel, entryType: .calories)) {
                    QuickAddButton(
                        icon: "plus",
                        label: EntryType.calories.displayType,
                        color: EntryType.calories.color
                    )
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            NavigationLink(destination: GoalsSettingView(viewModel: viewModel)) {
                HStack{
                    Image(systemName: "gearshape.fill")
                        .font(.system(size: 12))
                    Text("Goals")
                        .font(.system(size: 12))
                }.foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.top, 4)
        }
    }
}

#Preview{
    MainDashboardView(viewModel: HealthTrackerViewModel())
}

//
//  AddEntryView.swift
//  HealthTrackerWatch
//
//  Created by Tatiana6mo on 4/28/26.
//

import SwiftUI

struct AddEntryView: View {
    @ObservedObject var viewModel: HealthTrackerViewModel
    let entryType: EntryType
    @State private var selectedAmount: Double = 0
    @Environment(\.dismiss)private var dismiss
    
    private var quickAddOptions: [Double] {
        return[100,200,300,500]
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 16){
                Image(systemName: entryType.icon)
                    .font(.system(size: 28))
                    .foregroundColor(entryType.color)
                
                Text("Add\(entryType.displayName)")
                    .font(.system(size: 14, weight: .medium))
                
                Text("\(Int(selectedAmount))")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(entryType.color)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.fixed())
                ], spacing: 10) {
                    ForEach(quickAddOptions, id: \.self){ amount in
                        Button {
                            selectedAmount = amount
                        }label: {
                            Text("+\(Int(amount))")
                                .font(.system(size: 14, weight: .semibold))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(selectedAmount == amount ? .black : .white)
                                .cornerRadius(10)
                        }
                    }
                }
                
            }
        }
        
    }
    
}

#Preview {
    AddEntryView(viewModel: HealthTrackerViewModel(), entryType: .calories)
}


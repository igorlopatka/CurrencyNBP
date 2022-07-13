//
//  CurrencyView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 11/04/2022.
//

import SwiftUI
import Charts

struct CurrencyDetailsView: View {
    
    @ObservedObject var viewModel: CurrencyViewModel
    
    let rate: Rate
    let table: String
    
    @State var startDate = Date.now.addingTimeInterval(-7776000)
    @State var endDate = Date.now
    
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        
        VStack(alignment: .leading) {
            Chart {
                ForEach(viewModel.timeLine, id: \.self) { rate in
                    LineMark(
                        x: .value("Date", rate.effectiveDate),
                        y: .value("Mid", rate.mid)
                    )
                }
            }
            HStack {
                DatePicker("\(startDate, formatter: formatter)", selection: $startDate, displayedComponents: .date)
                    .labelsHidden()
                Text(" - ")
                DatePicker("\(endDate, formatter: formatter)", selection: $endDate, displayedComponents: .date)
                    .labelsHidden()
            }
            Text(rate.code)
                .font(.headline)
            
            Text(rate.currency)
                .foregroundColor(.secondary)
        }
        .onAppear {
            Task {
                await viewModel.fetchCurrencyTimeline(table: table, rate: rate, startDate: formatter.string(from: startDate), endDate: formatter.string(from: endDate))
            }
        }
    }
}

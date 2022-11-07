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
    
    @State var startDate = Date.now.addingTimeInterval(-3000000)
    @State var endDate = Date.now
    
    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        switch viewModel.detailsLoadingState {
        case .loaded:
            VStack() {
                Chart {
                    ForEach(viewModel.timeLine, id: \.self) { rate in
                        LineMark(
                            x: .value("Date", viewModel.dateForChart(date: rate.effectiveDate)),
                            y: .value("Mid", rate.mid)
                        )
                    }
                }
                .onAppear {
                    viewModel.updateTimeline(table: table, rate: rate, startDate: formatter.string(from: startDate), endDate: formatter.string(from: endDate))
                }
                .padding()
                .frame(height: 300)
                HStack {
                    DatePicker("\(startDate, formatter: formatter)", selection: $startDate,in: endDate.addingTimeInterval(-8035000)...endDate, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: startDate) { newDate in
                            viewModel.updateTimeline(table: table, rate: rate, startDate: formatter.string(from: newDate), endDate: formatter.string(from: endDate))
                        }
                    Text(" - ")
                    DatePicker("\(endDate, formatter: formatter)", selection: $endDate, in: startDate...Date.now, displayedComponents: .date)
                        .labelsHidden()
                        .onChange(of: endDate) { newDate in
                            viewModel.updateTimeline(table: table, rate: rate, startDate: formatter.string(from: startDate), endDate: formatter.string(from: newDate))
                        }
                }
                Text(rate.code)
                    .font(.headline)
                Text(rate.currency)
                    .foregroundColor(.secondary)
            }
            .navigationTitle(rate.code)
        case .loading:
            ProgressView()
                .onAppear {
                    viewModel.updateTimeline(table: table, rate: rate, startDate: formatter.string(from: startDate), endDate: formatter.string(from: endDate))
                }
        case .failed:
            Text("Please try again later.")
        }
    }
}

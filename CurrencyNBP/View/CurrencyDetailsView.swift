//
//  CurrencyView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 11/04/2022.
//

import SwiftUI

struct CurrencyDetailsView: View {
    
    let rate: Rate
    let table: String

    @State var endDate = Date.now
    @State var startDate = Date.now

    var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading) {
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
    }
}


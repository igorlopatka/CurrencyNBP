//
//  CurrencyListView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 04/11/2022.
//

import SwiftUI

struct CurrencyListView: View {
    
    @ObservedObject var viewModel: CurrencyViewModel
    
    var body: some View {
        List {
            ForEach(viewModel.rates, id: \.self) { rate in
                NavigationLink {
                    CurrencyDetailsView(viewModel: viewModel, rate: rate, table: viewModel.chosenTable)
                } label: {
                    VStack {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(rate.code)
                                    .font(.headline)
                                Text(rate.currency)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if viewModel.chosenTable == viewModel.tables[2] {
                                VStack {
                                    Text(String(format: "%.3f", rate.ask ?? 0) + "zł")
                                        .font(.title)
                                    Text(String(format: "%.3f", rate.bid ?? 0)  + "zł")
                                        .font(.title)
                                }
                                .padding()
                            } else {
                                VStack(alignment: .center) {
                                    Text(String(format: "%.3f", rate.mid ?? 0)  + "zł")
                                        .font(.title)
                                }
                            }
                        }
                    }
                    .frame(height: 80)
                }
            }
        }
    }
}

struct CurrencyListView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyListView(viewModel: CurrencyViewModel())
    }
}

//
//  CurrencyListView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 10/04/2022.
//

import SwiftUI

struct CurrencyListView: View {
    
    @StateObject private var viewModel = CurrencyViewModel()
    
    var body: some View {
        NavigationView {
            Section {
                switch viewModel.loadingState {
                case .loaded:
                    List {
                        ForEach(viewModel.rates, id: \.self) { rate in
                            NavigationLink {
                                CurrencyDetailsView(rate: rate)
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
                case .loading:
                    ProgressView()
                case .failed:
                    Text("Please try again later.")
                }
            }
            .navigationTitle("CurrencyNBP")
            .toolbar {
                Menu(content: {
                    Picker("Table", selection: $viewModel.chosenTable) {
                        ForEach(viewModel.tables, id: \.self) { value in
                            Text(value)
                        }
                    }
                    .onReceive([self.viewModel.chosenTable].publisher.first()) { value in
                        self.viewModel.updateTable(table: value)
                    }
                },
                     label: { Text("Table \(viewModel.chosenTable)") })
            }
            .task {
                await viewModel.fetchCurrencyList(table: viewModel.chosenTable)
            }
            .onAppear {
                viewModel.updateTable(table: viewModel.chosenTable)
            }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        CurrencyListView()
    }
}

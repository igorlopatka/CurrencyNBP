//
//  CurrencyListView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 10/04/2022.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var viewModel = CurrencyViewModel()
    
    var body: some View {
        NavigationView {
            Section {
                switch viewModel.loadingState {
                case .loaded:
                    CurrencyListView(viewModel: viewModel)
                case .loading:
                    ProgressView()
                case .failed:
                    Text("Unable to load data.")
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
                    .onChange(of: viewModel.chosenTable, perform: { newValue in
                        viewModel.updateTable(table: newValue)
                    })
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  CurrencyListView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 10/04/2022.
//

import SwiftUI

struct MainView: View {
    
    @State private var loadingState = LoadingState.loading
    @State private var rates = [Rate]()
    @State private var chosenTable = "A"
    @State private var tableType = TableType.rate
    @State private var showingDetails = false
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    enum TableType {
        case rate, buySell
    }
    
    let tables = ["A", "B", "C"]
    
    
    var body: some View {
        NavigationView {
            Section {
                switch loadingState {
                case .loaded:
                    List {
                        ForEach(rates, id: \.self) { rate in
                            NavigationLink {
                                DetailsView(rate: rate)
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
                                        
                                        if chosenTable == tables[2] {
                                            VStack {
                                                Text(String(format: "%.4f", rate.ask ?? 0))
                                                    .font(.title)
                                                Text(String(format: "%.4f", rate.bid ?? 0))
                                                    .font(.title)
                                            }
                                        } else {
                                            VStack(alignment: .center) {
                                                Text(String(format: "%.4f", rate.mid ?? 0))
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
                    Picker("Table", selection: $chosenTable) {
                        ForEach(tables, id: \.self) { value in
                            Text(value)
                        }
                    }
                    .onReceive([self.chosenTable].publisher.first()) { value in
                        self.updateTable(table: value)
                    }
                },
                     label: { Text("Table \(chosenTable)") })
            }
            .task {
                await fetchCurrencyList(table: tables[0])
            }
            .onAppear {
                updateTable(table: chosenTable)
            }
        }
    }
    
    func updateTable(table: String) {
        loadingState = .loading
        let inputTable = table
        chosenTable = table
        Task {
            await fetchCurrencyList(table: inputTable)
            loadingState = .loaded
        }
    }
    
    func fetchCurrencyList(table: String) async {
        
        let urlString = "https://api.nbp.pl/api/exchangerates/tables/\(table)/?format=json"
        
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode([Currency].self, from: data)
            rates = items[0].rates
            loadingState = .loaded
        } catch {
            loadingState = .failed
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

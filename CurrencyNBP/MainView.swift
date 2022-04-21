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
    @State private var table = "A"
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
//                    List {
//                        ForEach(rates, id: \.code) { rate in
//                            Text(rate.code)
//                                .font(.headline)
//                        }
//                    }
//                    .onTapGesture {showingDetails.toggle()}
//                    .sheet(isPresented: $showingDetails) {DetailsView()}
                    List {
                        ForEach(rates, id: \.self) { rate in
                            NavigationLink {
                                DetailsView(rate: rate)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(rate.code)
                                        .font(.headline)
                                    
                                    Text(rate.currency)
                                        .foregroundColor(.secondary)
                                }
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
                    Picker("Table", selection: $table) {
                        ForEach(tables, id: \.self) { value in
                            Text(value)
                        }
                    }
                    .onReceive([self.table].publisher.first()) { value in
                        self.updateTable(table: value)
                    }
                },
                     label: { Text("Table \(table)") })
            }
            .task {
                await fetchCurrencyList(table: "a")
            }
        }
    }
    
    func updateTable(table: String) {
        let inputTable = table
        Task {
            await fetchCurrencyList(table: inputTable)
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

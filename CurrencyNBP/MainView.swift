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
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    
    var body: some View {
        NavigationView {
            Section {
                switch loadingState {
                case .loaded:
                    List {
                        ForEach(rates, id: \.code) { rate in
                            Text(rate.code)
                                .font(.headline)
                        }
                    }
                case .loading:
                    ProgressView()
                case .failed:
                    Text("Please try again later.")
                }
            }
            .navigationTitle("CurrencyNBP")
            .task {
                await fetchCurrencyList()
            }
        }
    }
    
    func fetchCurrencyList() async {
        let urlString = "https://api.nbp.pl/api/exchangerates/tables/a/?format=json"
        
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

struct CurrencyListView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

//
//  CurrencyViewModel.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 08/07/2022.
//

import SwiftUI

@MainActor class CurrencyViewModel: ObservableObject {
    
    @Published var loadingState = LoadingState.loading
    @Published var rates = [Rate]()
    @Published var chosenTable = "A"
    @Published var showingDetails = false
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    enum RequestType {
        case standard, timeline
    }

    let tables = ["A", "B", "C"]
    
    func getData(from urlString: String) async {
        
        var notTimelineRequest = false
        if urlString.contains("tables") {
            notTimelineRequest = true
        }
        
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let decoder = JSONDecoder()

            
            if notTimelineRequest {
                let standardResponse = try decoder.decode([Currency].self, from: data)
//                rates = standardResponse[0].rates
//                loadingState = .loaded
            }
            else {
                let timelineResponse = try decoder.decode(CurrencyTimeline.self, from: data)
//                rates = timelineResponse[0].rates
//                loadingState = .loaded
            }
        } catch {
//                loadingState = .failed
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

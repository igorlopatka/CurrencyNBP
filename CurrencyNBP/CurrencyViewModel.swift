//
//  CurrencyViewModel.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 08/07/2022.
//

import SwiftUI

@MainActor class CurrencyViewModel: ObservableObject {
    
    @Published var loadingState = LoadingState.loading
    @Published var detailsLoadingState = DetailsLoadingState.loading
    @Published var rates = [Rate]()
    @Published var timeLine = [TimeLineRate]()
    @Published var chosenTable = "A"
    @Published var showingDetails = false
    
    enum LoadingState {
        case loading, loaded, failed
    }
    
    enum DetailsLoadingState {
        case loading, loaded, failed
    }
    
    enum RequestType {
        case standard, timeline
    }

    let tables = ["A", "B", "C"]
        
    func updateTable(table: String) {
        loadingState = .loading
        let inputTable = table
        chosenTable = table
        Task {
            await fetchCurrencyList(table: inputTable)
            loadingState = .loaded
        }
    }
    
    func updateTimeline(table: String, rate: Rate, startDate: String, endDate: String) {
        
        detailsLoadingState = .loading
        
        let inputTable = table
        let inputRate = rate
        let inputStartDate = startDate
        let inputEndDate = endDate
        
        Task {
            await fetchCurrencyTimeline(table: inputTable, rate: inputRate, startDate: inputStartDate, endDate: inputEndDate)
            detailsLoadingState = .loaded
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

    func fetchCurrencyTimeline(table: String, rate: Rate, startDate: String, endDate: String) async {
        let urlString = "https://api.nbp.pl/api/exchangerates/rates/\(table)/\(rate.code)/\(startDate)/\(endDate)/?format=json"
        
        guard let url = URL(string: urlString) else {
            print("Bad URL: \(urlString)")
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let items = try JSONDecoder().decode(CurrencyTimeline.self, from: data)
            let timelineRates = items.rates
            timeLine = timelineRates
            detailsLoadingState = .loaded
        } catch {
            detailsLoadingState = .failed
        }
    }
    
    func dateForChart(date: String) -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
            
        let dateConverted = formatter.date(from: date)!
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: dateConverted)
        
        formatter.dateFormat = "D"
        
        let finalDate = calendar.date(from:components)!
        
        let dateForChart = formatter.string(from: finalDate)
        
        return dateForChart
    }
}

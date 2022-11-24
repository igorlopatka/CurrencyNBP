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
    @Published var timelineChartData = [TimeLineForChart]()
    @Published var chosenTable = "A"
    @Published var showingDetails = false
    @Published var searchText = ""
    
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
    
    var searchResults: [Rate] {
        get {
            if searchText.isEmpty {

                    return rates
                
            } else {
                
                return rates.filter { $0.code.lowercased().contains(searchText.lowercased())}
            }
        }
        set {
            objectWillChange.send()
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
    
    func updateTimeline(table: String, rate: Rate, startDate: String, endDate: String) {
        
        detailsLoadingState = .loading
        
        let inputTable = table
        let inputRate = rate
        let inputStartDate = startDate
        let inputEndDate = endDate
        
        Task {
            await fetchCurrencyTimeline(table: inputTable, rate: inputRate, startDate: inputStartDate, endDate: inputEndDate)
        }
        
        detailsLoadingState = .loaded
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
        
        timelineChartData = []
        
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
            
            if table == tables[2] {
                for rate in timeLine {
                    let bidRate = TimeLineForChart(no: rate.no, effectiveDate: rate.effectiveDate, price: rate.bid!, type: "Bid")
                    timelineChartData.append(bidRate)
                    let askRate = TimeLineForChart(no: rate.no, effectiveDate: rate.effectiveDate, price: rate.ask!, type: "Ask")
                    timelineChartData.append(askRate)
                }
            } else {
                for rate in timeLine {
                    let midRate = TimeLineForChart(no: rate.no, effectiveDate: rate.effectiveDate, price: rate.mid!, type: "Mid")
                    timelineChartData.append(midRate)
                }
            }
            
            detailsLoadingState = .loaded
        } catch {
            detailsLoadingState = .failed
        }
    }
    
    func dateForChart(date: String) -> String {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateFormatter.date(from: date)
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        let resultString = dateFormatter.string(from: date!)
        return resultString
    }
}

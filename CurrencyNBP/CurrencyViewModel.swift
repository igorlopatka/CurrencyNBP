//
//  CurrencyViewModel.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 08/07/2022.
//

import Foundation

class CurrencyViewModel: ObservableObject {
    
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
}

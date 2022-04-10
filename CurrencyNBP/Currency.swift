//
//  Currency.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 10/04/2022.
//

import Foundation

struct Currency: Decodable {
    
    struct Rate: Decodable {
        let currency: String
        let code: String
        let mid: Double
    }
    
    let table: String
    let no: String
    let effectiveDate: String
    let rates: [Rate]
}




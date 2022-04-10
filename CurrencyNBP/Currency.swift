//
//  Currency.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 10/04/2022.
//

import Foundation

struct Currency: Codable {
    
    let table: String
    let no: String
    let effectiveDate: String
    let rates: [Rate]
}

struct Rate: Codable {
    let currency: String
    let code: String
    let mid: Double
}



    

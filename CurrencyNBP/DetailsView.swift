//
//  CurrencyView.swift
//  CurrencyNBP
//
//  Created by Igor Łopatka on 11/04/2022.
//

import SwiftUI

struct DetailsView: View {
    
    let rate: Rate
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(rate.code)
                .font(.headline)
            
            Text(rate.currency)
                .foregroundColor(.secondary)
        }
    }
}

//struct CurrencyView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailsView(rate: )
//    }
//}

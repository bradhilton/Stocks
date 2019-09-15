//
//  StocksView.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/14/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

struct StocksView: View {
    let stocks: [Stock]
    @State var sort = Stock.Sort.symbol
    @State var ascending = true
    @State var search = ""
    @State var stockDisplay = Stock.Display.lastSale

    var filteredAndSortedStocks: [Stock] {
        stocks
            .filter(stockMatches(search))
            .sorted(by: sort.comparator(ascending))
    }
    
    var body: some View {
        Group {

            SortPicker(sort: $sort, ascending: $ascending)
                .padding([.top, .leading, .trailing])

            TextField("Search", text: $search)
                .padding(.all)

            List(
                filteredAndSortedStocks,
                id: \.symbol
            ) { stock in
                StockView(stock: stock, display: self.$stockDisplay)
            }

        }
        .navigationBarTitle("Stocks")
    }
}

struct StocksView_Previews: PreviewProvider {
    static var previews: some View {
        StocksView(stocks: loadStocks(count: 100))
    }
}

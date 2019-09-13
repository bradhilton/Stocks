//
//  ContentView.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/12/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var data: AppData
    @State var sort = Stock.Sort.symbol
    @State var ascending = true
    @State var search = ""
    @State var stockDisplay = Stock.Display.lastSale
    
    var filteredAndSortedStocks: [Stock] {
        data.stocks
            .filter(stockMatches(search))
            .sorted(by: sort.comparator(ascending))
    }
    
    var body: some View {
        NavigationView {
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
            .navigationBarItems(
                trailing: Text("\(data.notificationsCount) Notifications").bold()
            )
        }
    }

}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(data: AppData())
    }
}

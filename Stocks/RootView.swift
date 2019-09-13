//
//  RootView.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/12/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

struct RootView: View {
    @ObservedObject var appData: AppData

    var body: some View {
        NavigationView {
            StocksView(
                notificationsCount: appData.notificationsCount,
                stocks: appData.stocks
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView(appData: AppData(stocksCount: 100))
    }
}

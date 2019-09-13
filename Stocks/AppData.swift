//
//  State.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/12/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Combine
import Foundation

class AppData : ObservableObject {
    @Published var notificationsCount: Int
    @Published var stocks: [Stock]
    
    init(stocksCount: Int) {
        notificationsCount = 2
        stocks = loadStocks(count: stocksCount)
        
        startNotificationsCountUpdates()
        startStockUpdates()
        
    }
    
    var updateNotificationsCountTimer: Timer?
    
    func startNotificationsCountUpdates() {
        self.updateNotificationsCountTimer = .scheduledTimer(
            withTimeInterval: 5,
            repeats: true
        ) { _ in
            let randomChange = Int.random(in: -1...1)
            let count = self.notificationsCount + randomChange
            self.notificationsCount = max(count, 0)
        }
    }
    
    var updateStocksTimer: Timer?
    
    func startStockUpdates() {
        let exchangeSymbolPairs = stocks.map { ($0.exchange, $0.symbol) }
        
        self.updateStocksTimer = .scheduledTimer(
            withTimeInterval: 0.1,
            repeats: true
        ) { _ in
            self.updateStocks(
                with: randomStockUpdates(for: exchangeSymbolPairs)
            )
        }
    }
    
    func updateStocks(with updates: [Stock.Update]) {
        for update in updates {
            guard let index = stocks.firstIndex(
                where: { stock in
                    return stock.exchange == update.exchange
                        && stock.symbol == update.symbol
                }
            ) else {
                continue
            }
            stocks[index].lastSale *= update.priceChange
        }
    }
    
}

func randomStockUpdates(
    for exchangeSymbolPairs: [(exchange: Stock.Exchange, symbol: String)]
) -> [Stock.Update] {
    let numberOfUpdates = Int.random(in: 0..<4)
    return (0..<numberOfUpdates).map { _ in
        let (exchange, symbol) = exchangeSymbolPairs.randomElement()!
        let change = Double.random(in: 0.01..<0.03)
        let sign = Bool.random() ? 1.0 : -1.0
        return Stock.Update(
            exchange: exchange,
            symbol: symbol,
            priceChange: change * sign + 1.0
        )
    }
}

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
    
    var pendingStocks: [Stock]
    
    init() {
        notificationsCount = 2
        let stocks = loadStocks(count: 500)
        self.stocks = stocks
        self.pendingStocks = stocks
        startNotificationsCountUpdates()
        startStockUpdates()
    }
    
    var updateNotificationsCountTimer: Timer?
    
    func startNotificationsCountUpdates() {
        self.updateNotificationsCountTimer = .scheduledTimer(
            withTimeInterval: 2,
            repeats: true
        ) { _ in
            let randomChange = Int.random(in: -1...1)
            let count = self.notificationsCount + randomChange
            let clampedCount = max(count, 0)
            self.notificationsCount = clampedCount
        }
    }
    
    var updatePendingStocksTimer: Timer?
    var updateStocksTimer: Timer?
    
    func startStockUpdates() {
        let exchangeSymbolPairs = stocks.map { ($0.exchange, $0.symbol) }
        
        self.updatePendingStocksTimer = .scheduledTimer(
            withTimeInterval: 0.002,
            repeats: true
        ) { [unowned self] _ in
            self.updateStocks(
                with: randomStockUpdates(for: exchangeSymbolPairs)
            )
        }
        
        self.updateStocksTimer = .scheduledTimer(
            withTimeInterval: 0.250,
            repeats: true
        ) { [unowned self] _ in
            self.stocks = self.pendingStocks
        }
    }
    
    func updateStocks(with updates: [Stock.Update]) {
        for update in updates {
            guard let index = pendingStocks.firstIndex(
                where: { stock in
                    return stock.exchange == update.exchange
                        && stock.symbol == update.symbol
                }
            ) else {
                continue
            }
            pendingStocks[index].lastSale *= update.priceChange
        }
    }
    
}

func randomStockUpdates(
    for exchangeSymbolPairs: [(exchange: Stock.Exchange, symbol: String)]
) -> [Stock.Update] {
    let maxNumberOfUpdates = (exchangeSymbolPairs.count / 500) + 1
    let numberOfUpdates = max(Int.random(in: -5...maxNumberOfUpdates), 0)
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

//
//  Stock.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/12/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Foundation

struct Stock : Codable {
    let exchange: Exchange
    let symbol: String
    let name: String
    var lastSale: Double
    var open: Double
    
    var percentChange: Double {
        (lastSale - open) / open
    }
    
    enum Exchange : String, CaseIterable, Codable {
        case nasdaq, nyse, amex
    }
    
    enum Sort : Hashable, CaseIterable {
        case symbol, name, movers
        
        func comparator(_ ascending: Bool) -> (Stock, Stock) -> Bool {
            return ascending ? comparator : { !self.comparator($0, $1) }
        }
        
        private var comparator: (Stock, Stock) -> Bool {
            switch self {
            case .symbol:
                return { $0.symbol < $1.symbol }
            case .name:
                return { $0.name < $1.name }
            case .movers:
                return { $0.percentChange < $1.percentChange }
            }
        }
        
    }
    
    enum Display : CaseIterable {
        case lastSale, percentChange
        
        mutating func rotate() {
            switch self {
            case .lastSale:
                self = .percentChange
            case .percentChange:
                self = .lastSale
            }
        }
        
    }
    
    struct Update {
        let exchange: Stock.Exchange
        let symbol: String
        let priceChange: Double
    }
    
}

// MARK: Stocks Search

func stockMatches(_ search: String) -> (Stock) -> Bool {
    return { stock in
        guard !search.isEmpty else { return true }
        return stock.symbol.lowercased().contains(search.lowercased())
            || stock.name.lowercased().contains(search.lowercased())
    }
}

// MARK: Descriptions

extension Stock {
    
    var lastSaleDescription: String {
        currencyFormatter.string(from: NSNumber(value: lastSale))!
    }
    
    var percentChangeDescription: String {
        percentChangeFormatter.string(from: NSNumber(value: percentChange))!
    }
    
}

// MARK: Number Formatters

let currencyFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    return formatter
}()

let percentChangeFormatter: NumberFormatter = {
    let formatter = NumberFormatter()
    formatter.numberStyle = .percent
    formatter.negativePrefix = "-"
    formatter.positivePrefix = "+"
    formatter.minimumFractionDigits = 2
    formatter.maximumFractionDigits = 2
    return formatter
}()

// MARK: Additional Properties

//extension Stock {
//    let marketCap: Double
//    let adrTSO: Int?
//    let ipoYear: Int?
//    let sector: String?
//    let industry: String?
//    let summaryQuote: String
//}

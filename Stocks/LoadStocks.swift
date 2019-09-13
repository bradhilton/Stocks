//
//  LoadStocks.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/12/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Foundation

func loadStocks(count: Int) -> [Stock] {
    guard let path = Bundle.main.path(
        forResource: "stocks",
        ofType: "json"
    ) else {
        fatalError("stocks.json not found in bundle")
    }
    do {
        let data = try Data(contentsOf: URL(fileURLWithPath: path))
        let stocks = try JSONDecoder().decode([Stock].self, from: data)
        return count < stocks.count ? Array(stocks[0..<count]) : stocks
    } catch {
        fatalError(error.localizedDescription)
    }
}

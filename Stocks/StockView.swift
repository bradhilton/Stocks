//
//  StockView.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/12/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

struct StockView: View {
    let stock: Stock
    @Binding var display: Stock.Display
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(stock.symbol)
                    .font(.title)
                    .bold()
                Spacer()
                Button(action: { self.display.rotate() }) {
                    Text(displayText)
                        .foregroundColor(displayColor)
                        .font(.system(.title, design: .monospaced))
                }
            }
            Text(stock.name).font(.headline)
        }
    }
    
    var displayText: String {
        switch display {
        case .lastSale:
            return stock.lastSaleDescription
        case .percentChange:
            return stock.percentChangeDescription
        }
    }
    
    var displayColor: Color {
        stock.percentChange >= 0 ? .green : .red
    }
    
}

struct StockView_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(Stock.Display.allCases, id: \.self) { display in
            StockView(
                stock: loadStocks(count: 1)[0],
                display: .constant(display)
            )
            .previewLayout(.fixed(width: 320, height: 63))
            .previewDisplayName(String(describing: display))
        }
    }
}

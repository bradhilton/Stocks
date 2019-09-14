//
//  SortPicker.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import SwiftUI

struct SortPicker: View {
    @Binding var sort: Stock.Sort
    @Binding var ascending: Bool
    var body: some View {
        HStack {
            Text("Sort By")
                .foregroundColor(Color(.sRGB, white: 0.5, opacity: 0.5))
            Picker("Sort", selection: $sort) {
                Text("Symbol").tag(Stock.Sort.symbol)
                Text("Name").tag(Stock.Sort.name)
                Text("Movers").tag(Stock.Sort.movers)
            }
            .pickerStyle(SegmentedPickerStyle())
            Button(action: { self.ascending.toggle() }) {
                Image(
                    systemName: ascending
                        ? "arrowtriangle.up.fill"
                        : "arrowtriangle.down.fill"
                ).padding([.leading])
            }
        }
    }
}

struct SortPicker_Previews: PreviewProvider {
    
    static var previews: some View {
        ForEach(Stock.Sort.allCases, id: \.self) { sort in
            Group {
                preview(sort: sort, ascending: true)
                preview(sort: sort, ascending: false)
            }
        }
    }
    
    static func preview(
        sort: Stock.Sort,
        ascending: Bool
    ) -> some View {
        SortPicker(
            sort: .constant(sort),
            ascending: .constant(ascending)
        )
        .previewLayout(.sizeThatFits)
        .previewDisplayName("sort: \(sort) ascending: \(ascending)")
    }
    
}

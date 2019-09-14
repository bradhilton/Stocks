//
//  Array.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/14/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

extension Array {
    
    /// Performs a binary search to find the sorted position of an element in the array.
    /// - Precondition:
    /// The array is sorted.
    /// - Returns:
    /// Either the index of the element if it is present or the index that the element should be inserted at to maintain sort order.
    func sortedIndex(of element: Element, _ areInIncreasingOrder: (Element, Element) -> Bool) -> Int {
        var start = startIndex
        var end = endIndex
        while start < end {
            let middle = start + (end - start) / 2
            if areInIncreasingOrder(self[middle], element) {
                start = middle + 1
            } else {
                end = middle
            }
        }
        return start
    }
    
}

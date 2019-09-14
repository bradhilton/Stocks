//
//  Sequence.swift
//  DiffableCollections
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

extension Sequence {
    
    public func areSorted(by areInIncreasingOrder: (Element, Element) throws -> Bool) rethrows -> Bool {
        for (lhs, rhs) in zip(self, self.dropFirst()) {
            guard try areInIncreasingOrder(lhs, rhs) else {
                return false
            }
        }
        return true
    }
    
}

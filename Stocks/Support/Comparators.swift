//
//  Comparators.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Foundation

func compare<A, B : Comparable>(_ b: KeyPath<A, B>) -> (A, A) -> Bool {
    { $0[keyPath: b] < $1[keyPath: b] }
}

func compare<A, B : Comparable, C : Comparable>(
    _ b: KeyPath<A, B>,
    _ c: KeyPath<A, C>
) -> (A, A) -> Bool {
    { $0[keyPath: b] != $1[keyPath: b]
        ? compare(b)($0, $1)
        : compare(c)($0, $1)
    }
}

func compare<A, B : Comparable, C : Comparable, D: Comparable>(
    _ b: KeyPath<A, B>,
    _ c: KeyPath<A, C>,
    _ d: KeyPath<A, D>
) -> (A, A) -> Bool {
    { $0[keyPath: b] != $1[keyPath: b]
        ? compare(b)($0, $1)
        : compare(c, d)($0, $1)
    }
}

func descending<A>(_ comparator: @escaping (A, A) -> Bool) -> (A, A) -> Bool {
    { comparator($1, $0) }
}

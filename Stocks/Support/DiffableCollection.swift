//
//  DiffableCollection.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

protocol DiffableCollection : RandomAccessCollection where Index == Int, Element : Hashable {
    associatedtype Value
    subscript(key: Element) -> Value? { get }
    func position(of key: Element) -> Int?
    func diff(from other: Self) -> Set<Element>
}

extension DiffableCollection {
    
    var values: Values<Self> {
        Values(base: self)
    }
    
    func map<Transform : Function>(_ transform: Transform) -> Map<Self, Transform> {
        Map(base: self, transform: transform)
    }
    
}

extension DiffableCollection where Value : Searchable {
    
    func search(_ search: String) -> Search<Self> {
        Search(base: self, search: search.lowercased())
    }
    
}

struct Values<Base : DiffableCollection> : RandomAccessCollection {
    
    let base: Base
    
    var startIndex: Int {
        base.startIndex
    }
    
    var endIndex: Int {
        base.endIndex
    }
    
    subscript(position: Int) -> Base.Value {
        base[base[position]]!
    }
    
}

protocol Function {
    associatedtype Args
    associatedtype Result
    func callAsFunction(_ args: Args) -> Result
}

struct Map<Base : DiffableCollection, Transform : Function> : DiffableCollection where Transform.Args == Base.Value {
    
    let base: Base
    let transform: Transform
    
    var startIndex: Int {
        base.startIndex
    }
    
    var endIndex: Int {
        base.endIndex
    }
    
    subscript(position: Int) -> Base.Element {
        base[position]
    }
    
    subscript(key: Base.Element) -> Transform.Result? {
        base[key].map(transform.callAsFunction)
    }
    
    func position(of key: Base.Element) -> Int? {
        base.position(of: key)
    }
    
    func diff(from other: Map) -> Set<Base.Element> {
        base.diff(from: other.base)
    }
    
}

protocol Searchable {
    func matches(search: String) -> Bool
}

struct Search<Base : DiffableCollection> : DiffableCollection where Base.Value : Searchable {
    let base: Base
    let search: String
    
    var filteredElements: [Base.Element] {
        cachedResult(for: self) { $0._filteredResults }
    }
    
    private var _filteredResults: [Base.Element] {
        search.isEmpty
            ? base.map { $0 }
            : base.filter { base[$0]!.matches(search: search) }
    }
    
    var set: Set<Base.Element> {
        cachedResult(for: self) { Set($0.filteredElements) }
    }
    
    var positions: [Base.Element: Int] {
        cachedResult(for: self) {
            Dictionary(
                uniqueKeysWithValues: $0.filteredElements.enumerated().lazy.map { ($1, $0) }
            )
        }
    }
    
    var startIndex: Int {
        filteredElements.startIndex
    }
    
    var endIndex: Int {
        filteredElements.endIndex
    }
    
    subscript(position: Int) -> Base.Element {
        filteredElements[position]
    }
    
    subscript(key: Base.Element) -> Base.Value? {
        base[key]
    }
    
    func position(of key: Base.Element) -> Int? {
        positions[key]
    }
    
    func diff(from other: Search<Base>) -> Set<Base.Element> {
        var diff = base.diff(from: other.base)
        if search == other.search {
            for key in diff {
                if let value = base[key], !value.matches(search: search) {
                    diff.remove(key)
                }
            }
        } else if search.contains(other.search) {
            diff.formUnion(other.set.subtracting(set))
        } else if other.search.contains(search) {
            diff.formUnion(set.subtracting(other.set))
        } else {
            diff.formUnion(base)
        }
        return diff
    }
    
}

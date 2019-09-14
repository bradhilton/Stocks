//
//  MutableDiffableSortedDictionary.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

public struct MutableDiffableSortedDictionary<Key : Hashable, Value> {
    public typealias Keys = [Key]
    
    public fileprivate(set) var keys: Keys
    fileprivate var _values: DiffableDictionary<Key, Value>
    fileprivate let areInIncreasingOrder: (Value, Value) -> Bool
    
    private var lazyValues: LazyMapSequence<[Key], Value> {
        return keys.lazy.map { self._values[$0]! }
    }
    
    fileprivate var isSorted: Bool {
        return lazyValues.areSorted(by: areInIncreasingOrder)
    }
    
    fileprivate enum CodingKeys : String, CodingKey {
        case keys, _values
    }
    
}

extension MutableDiffableSortedDictionary {
    
    init(keys: Keys, values: [Key: Value], areInIncreasingOrder: @escaping (Value, Value) -> Bool) {
        self.keys = keys
        self._values = .init(dictionary: values)
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    public func mapKeys<U>(_ transform: (Key) -> U, uniquingKeysWith combine: (Value, Value) -> Value) -> MutableDiffableSortedDictionary<U, Value> {
        .init(
            withoutActuallyEscaping(transform) { transform in
                keys.lazy.map { (transform($0), self._values[$0]!) }
            },
            uniquingKeysWith: combine,
            sortedBy: areInIncreasingOrder
        )
    }
    
}

extension MutableDiffableSortedDictionary : RandomAccessCollection {
    
    public var startIndex: Int {
        return 0
    }
    
    public var endIndex: Int {
        return keys.endIndex
    }
    
    public func index(after index: Int) -> Int {
        return index + 1
    }
    
    public subscript(index: Int) -> (key: Key, value: Value) {
        let key = keys[index]
        let value = _values[key]!
        return (key, value)
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return _values[key]
        }
        set {
            removeValue(forKey: key)
            if let value = newValue {
                keys.insert(key, at: insertionIndex(of: value))
                _values[key] = value
            }
        }
    }
    
    private func insertionIndex(of value: Value) -> Int {
        var start = startIndex
        var end = endIndex
        while start < end {
            let middle = start + (end - start) / 2
            if areInIncreasingOrder(self[middle].value, value) {
                start = middle + 1
            } else {
                end = middle
            }
        }
        return start
    }
    
    public func index(ofKey key: Key) -> Int? {
        guard let value = _values[key] else { return nil }
        return insertionIndex(of: value)
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        guard let value = _values[key] else { return nil }
        let index = insertionIndex(of: value)
        keys.remove(at: index)
        _values[key] = nil
        return value
    }
    
    @discardableResult
    public mutating func remove(at index: Int) -> (key: Key, value: Value) {
        let key = keys.remove(at: index)
        let value = _values.removeValue(forKey: key)!
        return (key, value)
    }
    
}

extension MutableDiffableSortedDictionary {
    
    public func diff(from other: MutableDiffableSortedDictionary) -> Set<Key> {
        return _values.diff(from: other._values)
    }
    
}

extension MutableDiffableSortedDictionary {
    
    public typealias Values = AnyRandomAccessCollection<Value>
    
    public var values: Values {
        return Values(keys.lazy.map { self._values[$0]! })
    }
    
}

extension MutableDiffableSortedDictionary {
    
    init(values: [Key: Value], sortedBy areInIncreasingOrder: @escaping (Value, Value) -> Bool) {
        self.keys = values.keys.sorted { areInIncreasingOrder(values[$0]!, values[$1]!) }
        self._values = .init(dictionary: values)
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
    public init<S>(
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value,
        sortedBy areInIncreasingOrder: @escaping (Value, Value) -> Bool
    ) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.init(
            values: try [Key: Value](keysAndValues, uniquingKeysWith: combine),
            sortedBy: areInIncreasingOrder
        )
    }
    
    public init<S>(
        uniqueKeysWithValues keysAndValues: S,
        sortedBy areInIncreasingOrder: @escaping (Value, Value) -> Bool
    ) where S : Sequence, S.Element == (Key, Value) {
        self.init(
            values: [Key: Value](uniqueKeysWithValues: keysAndValues),
            sortedBy: areInIncreasingOrder
        )
    }
    
    public init(sortedBy areInIncreasingOrder: @escaping (Value, Value) -> Bool) {
        self.keys = []
        self._values = [:]
        self.areInIncreasingOrder = areInIncreasingOrder
    }
    
}

extension MutableDiffableSortedDictionary where Value : Comparable {
    
    public init<S>(
        _ keysAndValues: S,
        uniquingKeysWith combine: (Value, Value) throws -> Value
    ) rethrows where S : Sequence, S.Element == (Key, Value) {
        self.init(
            values: try [Key: Value](keysAndValues, uniquingKeysWith: combine),
            sortedBy: <
        )
    }
    
    public init<S>(
        uniqueKeysWithValues keysAndValues: S
    ) where S : Sequence, S.Element == (Key, Value) {
        self.init(
            values: [Key: Value](uniqueKeysWithValues: keysAndValues),
            sortedBy: <
        )
    }
    
    public init() {
        self.init(sortedBy: <)
    }
    
}

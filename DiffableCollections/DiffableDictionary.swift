//
//  DiffableDictionary.swift
//  Stocks
//
//  Created by Bradley Hilton on 3/1/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import Foundation

public struct DiffableDictionary<Key : Hashable, Value> {
    fileprivate var storage: Storage<Key, Value>
}

extension DiffableDictionary : Collection {

    public typealias Element = Dictionary<Key, Value>.Element
    
    public struct Index : Comparable {
        fileprivate let depth: Int
        fileprivate let index: Dictionary<Key, Value>.Index
        
        public static func < (lhs: Index, rhs: Index) -> Bool {
            if lhs.depth != rhs.depth {
                return lhs.depth < rhs.depth
            } else {
                return lhs.index < rhs.index
            }
        }
    }
    
    public func makeIterator() -> AnyIterator<DiffableDictionary<Key, Value>.Element> {
        return storage.makeIterator()
    }

    public var count: Int {
        return storage.count
    }
    
    public var startIndex: Index {
        return storage.startIndex
    }
    
    public var endIndex: Index {
        return storage.endIndex
    }
    
    public func index(after index: Index) -> Index {
        return storage.index(after: index)
    }
    
    public subscript(index: Index) -> Element {
        return storage[index]
    }
    
    public subscript(key: Key) -> Value? {
        get {
            return storage[key]
        }
        set {
            compactAndExtendStorage()
            storage[key] = newValue
        }
    }
    
    @discardableResult
    public mutating func removeValue(forKey key: Key) -> Value? {
        compactAndExtendStorage()
        return storage.removeValue(forKey: key)
    }
    
    private func compactStorage() {
        storage.compact()
    }
    
    private mutating func compactAndExtendStorage() {
        if !isKnownUniquelyReferenced(&storage) {
            storage = .init(previous: storage)
        }
        storage.compact()
    }
    
}

extension DiffableDictionary {
    
    public init(dictionary: [Key: Value]) {
        self.init(storage: .init(inserted: dictionary))
    }
    
}

extension DiffableDictionary : ExpressibleByDictionaryLiteral {
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.init(dictionary: .init(uniqueKeysWithValues: elements))
    }
    
}

extension DiffableDictionary {
    
    public func diff(from other: DiffableDictionary) -> Set<Key> {
        compactStorage()
        other.compactStorage()
        return storage.diff(from: other.storage)
    }
    
}

fileprivate class Storage<Key : Hashable, Value> : Diffable<Key> {
    var inserted: [Key: Value]
    var removed: Set<Key>
    var previous: Storage?
    
    init(inserted: [Key: Value] = [:], previous: Storage<Key, Value>? = nil) {
        self.inserted = inserted
        self.removed = []
        self.previous = previous
    }
    
    subscript(key: Key) -> Value? {
        get {
            if let value = inserted[key] {
                return value
            } else if removed.contains(key) {
                return nil
            } else {
                return previous?[key]
            }
        }
        set {
            if let newValue = newValue {
                inserted[key] = newValue
                if previous != nil {
                    removed.remove(key)
                }
            } else {
                removeValue(forKey: key)
            }
        }
    }
    
    @discardableResult
    func removeValue(forKey key: Key) -> Value? {
        guard let value = self[key] else { return nil }
        inserted.removeValue(forKey: key)
        if previous != nil {
            removed.insert(key)
        }
        return value
    }
    
    func compact() {
        previous?.compact()
        if isKnownUniquelyReferenced(&previous) {
            removed.formUnion(previous!.removed.subtracting(inserted.keys))
            inserted.merge(previous!.inserted.filter { !removed.contains($0.key) }, uniquingKeysWith: { lhs, rhs in lhs })
            previous = previous?.previous
        }
        if previous == nil {
            removed = []
        }
    }
    
    var nodes: Set<Storage> {
        var nodes = Set<Storage>()
        addNodes(to: &nodes)
        return nodes
    }
    
    private func addNodes(to set: inout Set<Storage>) {
        set.insert(self)
        previous?.addNodes(to: &set)
    }
    
    override func diff(from other: Diffable<Key>) -> Set<Key>? {
        (other as? Storage).map(diff(from:))
    }
    
    func diff(from other: Storage) -> Set<Key> {
        var diff = Set<Key>()
        reverseChanges(&diff, tillNodeIn: other.nodes, thenRecordChangesFrom: other)
        return diff
    }
    
    private func reverseChanges(_ diff: inout Set<Key>, tillNodeIn nodes: Set<Storage>, thenRecordChangesFrom other: Storage) {
        if nodes.contains(self) {
            other.recordChanges(&diff, till: self)
        } else {
            diff.formUnion(removed)
            diff.formUnion(inserted.keys)
            if let previous = previous {
                previous.reverseChanges(&diff, tillNodeIn: nodes, thenRecordChangesFrom: other)
            } else {
                other.recordChanges(&diff, till: nil)
            }
        }
    }
    
    private func recordChanges(_ diff: inout Set<Key>, till node: Storage?) {
        guard self != node else { return }
        previous?.recordChanges(&diff, till: node)
        diff.formUnion(inserted.keys)
        diff.formUnion(removed)
    }
    
}

extension Storage : Collection {
    
    func makeIterator() -> AnyIterator<DiffableDictionary<Key, Value>.Element> {
        var node = self
        var index = node.inserted.startIndex
        var seen = Set<Key>()
        return AnyIterator {
            while index == node.inserted.endIndex || seen.contains(node.inserted[index].key) {
                if index == node.inserted.endIndex {
                    if let previous = node.previous {
                        seen.formUnion(node.inserted.keys)
                        seen.formUnion(node.removed)
                        node = previous
                        index = node.inserted.startIndex
                    } else {
                        return nil
                    }
                } else {
                    index = node.inserted.index(after: index)
                }
            }
            defer {
                index = node.inserted.index(after: index)
            }
            return node.inserted[index]
        }
    }
    
    var count: Int {
        guard let previous = previous else {
            return inserted.count
        }
        return previous.count + inserted.filter { previous[$0.key] == nil }.count - removed.count
    }
    
    var startIndex: DiffableDictionary<Key, Value>.Index {
        return firstValidIndex(startingWith: inserted.startIndex, depth: 0, parents: [])
    }
    
    var endIndex: DiffableDictionary<Key, Value>.Index {
        return endIndex(depth: 0)
    }
    
    private func endIndex(depth: Int) -> DiffableDictionary<Key, Value>.Index {
        return previous?.endIndex(depth: depth + 1) ?? .init(depth: depth, index: inserted.endIndex)
    }
    
    func index(after index: DiffableDictionary<Key, Value>.Index) -> DiffableDictionary<Key, Value>.Index {
        guard let (node, parents) = nodeAndParents(at: index.depth) else {
            fatalError()
        }
        
        return node.index(after: index.index, depth: index.depth, parents: parents)
    }
    
    private func index(after index: Dictionary<Key, Value>.Index, depth: Int, parents: [Storage]) -> DiffableDictionary<Key, Value>.Index {
        guard index != inserted.endIndex else {
            return previous!.firstValidIndex(startingWith: previous!.inserted.startIndex, depth: depth + 1, parents: parents + [self])
        }
        
        return firstValidIndex(startingWith: inserted.index(after: index), depth: depth, parents: parents)
    }
    
    private func nodeAndParents(at depth: Int) -> (node: Storage, parents: [Storage])? {
        var node = self
        var parents = [Storage]()
        for _ in 0..<depth {
            guard let previous = node.previous else { return nil }
            parents.append(node)
            node = previous
        }
        return (node, parents)
    }
    
    private func node(at depth: Int) -> Storage? {
        var node = self
        for _ in 0..<depth {
            guard let previous = node.previous else { return nil }
            node = previous
        }
        return node
    }
    
    private func firstValidIndex(startingWith index: Dictionary<Key, Value>.Index, depth: Int, parents: [Storage]) -> DiffableDictionary<Key, Value>.Index {
        guard index != inserted.endIndex else {
            return previous?.firstValidIndex(
                startingWith: previous!.inserted.startIndex,
                depth: depth + 1,
                parents: parents + [self]
            ) ?? .init(depth: depth, index: index)
        }
        
        let key = inserted[index].key
        
        guard parents.allSatisfy({ $0.inserted[key] == nil && !$0.removed.contains(key) }) else {
            return firstValidIndex(startingWith: inserted.index(after: index), depth: depth, parents: parents)
        }
        
        return .init(depth: depth, index: index)
    }
    
    subscript(index: DiffableDictionary<Key, Value>.Index) -> DiffableDictionary<Key, Value>.Element {
        return node(at: index.depth)!.inserted[index.index]
    }
    
}

extension Storage : Hashable {
    
    static func ==(lhs: Storage, rhs: Storage) -> Bool {
        return lhs === rhs
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(unsafeBitCast(self, to: Int.self))
    }
    
}


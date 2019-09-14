//
//  Table.swift
//  Stocks
//
//  Created by Bradley Hilton on 9/13/19.
//  Copyright © 2019 Brad Hilton. All rights reserved.
//

import DiffableCollections

protocol SortProtocol {
    associatedtype Item
    var comparator: (Item, Item) -> Bool { get }
}

protocol Indexable {
    associatedtype Sort : Hashable, CaseIterable, SortProtocol where Sort.Item == Self
}

struct SortedEntities<Entity : Identifiable & Indexable> : DiffableCollection {
    let sort: Entity.Sort
    let ascending: Bool
    let table: Table<Entity>
    
    private var sortedIDs: [Entity.ID] {
        table.indexedIDs[sort]!
    }
    
    var startIndex: Int {
        sortedIDs.startIndex
    }
    
    var endIndex: Int {
        sortedIDs.endIndex
    }
    
    subscript(position: Int) -> Entity.ID {
        sortedIDs[ascending ? position : endIndex - 1 - position]
    }
    
    subscript(key: Entity.ID) -> Entity? {
        table.entities[key]
    }
    
    func position(of key: Entity.ID) -> Int? {
        guard table.entities[key] != nil else { return nil }
        return sortedIDs.sortedIndex(of: key, table.areInIncreasingOrder(sort))
    }
    
    func diff(from other: SortedEntities) -> Set<Entity.ID> {
        var diff = table.entities.diff(from: other.table.entities)
        if sort != other.sort {
            diff.formUnion(self)
        } else if ascending != other.ascending {
            diff.formUnion(self)
        }
        return diff
    }
    
}

struct Table<Entity : Identifiable & Indexable> {
    var indexedIDs: [Entity.Sort: [Entity.ID]]
    var entities: DiffableDictionary<Entity.ID, Entity>
    
    init<S : Sequence>(_ sequence: S) where S.Element == Entity {
        self.entities = .init(dictionary: .init(uniqueKeysWithValues: sequence.map { ($0.id, $0) }))
        self.indexedIDs = Dictionary(
            uniqueKeysWithValues: Entity.Sort.allCases.map { sort in
                (sort, sequence.sorted(by: sort.comparator).map { $0.id })
            }
        )
        for sort in Entity.Sort.allCases {
            assert(indexedIDs[sort]!.areSorted(by: areInIncreasingOrder(sort)))
        }
    }
    
    func sorted(by sort: Entity.Sort, ascending: Bool) -> SortedEntities<Entity> {
        SortedEntities(
            sort: sort,
            ascending: ascending,
            table: self
        )
    }
    
    func areInIncreasingOrder(_ sort: Entity.Sort) -> (Entity.ID, Entity.ID) -> Bool {
        {
            let entities = self.entities
            return sort.comparator(entities[$0]!, entities[$1]!)
        }
    }
    
    mutating func insertEntity(_ entity: Entity) {
        removeEntity(for: entity.id)
        entities[entity.id] = entity
        for sort in Entity.Sort.allCases {
            indexedIDs[sort]!.insert(
                entity.id,
                at: indexedIDs[sort]!
                    .sortedIndex(
                        of: entity.id,
                        areInIncreasingOrder(sort)
                    )
            )
        }
    }
    
    mutating func removeEntity(for id: Entity.ID) {
        guard let entity = entities[id] else { return }
        for sort in Entity.Sort.allCases {
            indexedIDs[sort]!.remove(at:
                indexedIDs[sort]!
                    .sortedIndex(of: entity.id, areInIncreasingOrder(sort))
            )
        }
        entities[id] = nil
    }
    
    mutating func updateEntity(for id: Entity.ID, update: (inout Entity) -> ()) {
        guard var entity = entities[id] else { return }
        update(&entity)
        insertEntity(entity)
    }
    
}

extension Array {
    
    /// precondition: The array is sorted
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

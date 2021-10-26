//
//  Differ+Map.swift
//  Sectional
//
//  Created by Chris Conover on 1/27/18.
//  Copyright © 2018 Curious Applications. All rights reserved.
//

import Differ
import RxSwift
import Foundation


public struct Updates<T> {

    public let total: [T]
    public let changes: [Diff.Element]
    public let insertions: [Int]
    public let modified: [Int]
    public let deletions: [Int]
    public var hasChanges: Bool { return insertions.count + deletions.count > 0 }

    public init<C: Collection>(from: C, to: C,
                               isEqual: (T, T) -> Bool) where C.Element == T {
        total = Array(to)
        changes = from.diff(to, isEqual: isEqual).elements
        (insertions, deletions) = changes.split()
        modified = []
    }
}

extension Sequence {
    func runs<K: Equatable>(of matching: @escaping (Element) -> K) -> AnySequence<(K, AnySequence<Element>)> {
        return runs(of: matching, isEqual: { $0 == $1 })
    }

    func runs<K>(of matching: @escaping (Element) -> K, isEqual: @escaping (K, K) -> Bool)
        -> AnySequence<(K, AnySequence<Element>)> {

        var iterator = makeIterator()
        var next = iterator.next()
        guard let first = next
            else { return AnySequence<(K, AnySequence<Element>)> { AnyIterator { nil } }}
        var pattern = matching(first)
        var nextPattern = pattern

        return AnySequence<(K, AnySequence<Element>)> { ()
            -> AnyIterator<(K, AnySequence<Element>)> in
            return AnyIterator {
                guard next != nil else { return nil }
                return (pattern, AnySequence<Element> { () -> AnyIterator<Element> in
                    return AnyIterator {
                        guard let _ = next else { return nil }
                        guard isEqual(nextPattern, pattern) else {
                            pattern = matching(next!)
                            nextPattern = pattern
                            return nil
                        }

                        defer  {
                            next = iterator.next()
                            if let next = next { nextPattern = matching(next) }
                        }
                        return next
                    }
                })
            }
        }
    }
}

extension SectionedUpdates: CustomStringConvertible {
    public var description: String {
        return """
            sections: \(sections)
            section keys: \(sectionKeys)
            inserted sections: \(insertedSections)
            insertions: \(insertions)
            deleted sections: \(deletedSections)
            deletions: \(deletions)
            """
    }
}

public struct SectionedUpdates<T, K> where K: Hashable, K: Comparable {

    public let sections: [[T]]
    public let sectionKeys: [K]
    #if DEBUG
    private let fromSections: [[T]]
    #endif

    public let insertions: [IndexPath]
    public let deletions: [IndexPath]
    public let insertedSections: [Int]
    public let deletedSections: [Int]
    public var hasData: Bool {
        return sections.first(where: { !$0.isEmpty } ) != nil
    }
    public var hasChanges: Bool {
        return insertions.count
            + insertedSections.count
            + deletedSections.count
            + deletions.count > 0
    }

    /**
     init: Default initializer for flat, non sectioned data sources

     - Parameter from: Original collection from which to diff
     - Parameter to: Next collection representing a change from `fromSorted`
     - Parameter isEqual: closure to define comparison for any non-Equatable types
     */
    public init<C: Collection>(from: C, to: C, isEqual: (T, T) -> Bool) where C.Element == T {

            #if DEBUG
            fromSections = [Array(from)]
            #endif
            sections = [Array(to)]
            sectionKeys = []

            // perform diff on flat sequence, mapping to nested paths via above indices
            (insertions, deletions) = from.diff(to, isEqual: isEqual).elements.split(
                insertion: { IndexPath(item: $0, section: 0) },
                deletion: { IndexPath(item: $0, section: 0)  })
            insertedSections = []
            deletedSections = []
    }

    /**
     init: Default initializer for flat, non sectioned data sources for which the collection element `C.Element` is Equatable
     - Parameter from: Original collection from which to diff
     - Parameter to: Next collection representing a change from `fromSorted`
     */
    public init<C: Collection>(from: C, to: C) where C.Element == T, T: Equatable {
            self.init(from: from, to: to, isEqual: { $0 == $1 })
    }

    /**
     init: Optimized initializer for only for sorted collections. Use this initializer when the sequences are known to be sorted, as this implementation avoid the additional cost of sorting.

     - Parameter fromSorted: Original sorted collection from which to diff
     - Parameter toSorted: Next sorted collection representing a change from `fromSorted`
     - Parameter isEqual: closure to define comparison for any non-Equatable types
     - Parameter groupBy: closure to yield a stable section key for a given element `C.T`
     */
    public init<C: Collection>(fromSorted from: C, toSorted to: C,
                               isEqual: (T, T) -> Bool,
                               groupBy: @escaping (T) -> K) where C.Element == T {

            // create section groupings
            let fromSectionIndex = Dictionary(grouping: from, by: groupBy)
            let fromSectionKeys = fromSectionIndex.keys.sorted()
            #if DEBUG
            fromSections = fromSectionKeys.map { fromSectionIndex[$0]! }
            #endif
            let toSectionIndex = Dictionary(grouping: to, by: groupBy)
            sectionKeys = toSectionIndex.keys.sorted()
            sections = sectionKeys.map { toSectionIndex[$0]! }

            // create mappings from flat order into nested sections
            let makeIndex: ([K], [K: [T]]) -> [IndexPath] = { keys, lookup in
                return zip(0..., keys)
                    .flatMap { (offsetAndGroup: (offset: Int, name: K)) -> [IndexPath] in
                        let section = offsetAndGroup.offset
                        let run = lookup[offsetAndGroup.name]!
                        return zip(0..., run).map { IndexPath(item: $0.0, section: section) }}
            }
            let fromIndex = makeIndex(fromSectionKeys, fromSectionIndex)
            let toIndex = makeIndex(sectionKeys, toSectionIndex)

            // perform diff on flat sequence, mapping to nested paths via above indices
            (insertions, deletions) = from.diff(to, isEqual: isEqual).elements.split(
                insertion: { toIndex[($0)] },
                deletion: { fromIndex[$0] })
            (insertedSections, deletedSections) = fromSectionKeys.diff(sectionKeys).split()
    }


    /**
     init: create with initial data
     - Parameter initial:    initial data set for which there is to be no diff
     */

    public init<C: Collection>(initial to: C, groupBy: @escaping (T) -> K) where C.Element == T {

            // create section groupings
            #if DEBUG
            fromSections = []
            #endif
            let toSectionIndex = Dictionary(grouping: to, by: groupBy)
            sectionKeys = toSectionIndex.keys.sorted()
            sections = sectionKeys.map { toSectionIndex[$0]! }

            deletions = []
            deletedSections = []
            insertions = []
            insertedSections = []
    }

    /**
     init: Default initializer for unsorted collections. Use this initializer when the sequences are not unsorted, as this implementation incurs the additional cost of sorting and keeping grouping in tact.  Note that groups may be repeated.

     - Parameter fromSorted: Original sorted collection from which to diff
     - Parameter toSorted: Next sorted collection representing a change from `fromSorted`
     - Parameter isEqual: closure to define comparison for any non-Equatable types
     - Parameter groupBy: closure to yield a stable section key for a given element `C.T`
     */
    public init<C: Collection>(fromUnsorted from: C, toUnsorted to: C,
                               isEqual: (T, T) -> Bool,
                               groupBy: @escaping (T) -> K) where C.Element == T {

            // create section groupings
            let fromSectionIndex = Dictionary(grouping: from.enumerated(), by: { groupBy($0.1) })
            let fromSectionKeys = fromSectionIndex.keys.sorted()
            #if DEBUG
            fromSections = fromSectionKeys.map { fromSectionIndex[$0]!.map { $0.1 } }
            #endif

            let toSectionIndex = Dictionary(grouping: to.enumerated(), by: { groupBy($0.1) })
            sectionKeys = toSectionIndex.keys.sorted()
            sections = sectionKeys.map { toSectionIndex[$0]!.map { $0.1 } }

            // create mappings from flat order into nested sections
            let makeIndex: ([K], [K: [(Int, T)]]) -> [IndexPath] = { keys, lookup in
                return zip(0..., keys)
                    .flatMap { (offsetAndGroup: (offset: Int, name: K)) -> [(Int, IndexPath)] in
                        let section = offsetAndGroup.offset
                        let run = lookup[offsetAndGroup.name]!.map { $0.0 }
                        return zip(0..., run).map {
                            ($0.1, IndexPath(item: $0.0, section: section)) }}
                    .sorted(by: { $0.0 < $1.0 })
                    .map { $0.1 }
            }
            let fromIndex = makeIndex(fromSectionKeys, fromSectionIndex)
            let toIndex = makeIndex(sectionKeys, toSectionIndex)

            // perform diff on flat sequence, mapping to nested paths via above indices
            (insertions, deletions) = from.diff(to, isEqual: isEqual).elements.split(
                insertion: { toIndex[($0)] },
                deletion: { fromIndex[$0] })
            (insertedSections, deletedSections) = fromSectionKeys.diff(sectionKeys).split()
    }

    public init<C: Collection>(fromUnsorted from: C, toUnsorted to: C,
                               groupBy: @escaping (C.Element) -> K) where C.Element == T, T: Equatable {
            self.init(fromUnsorted: from, toUnsorted: to,
                      isEqual: { $0 == $1 },
                      groupBy: groupBy)
    }

    public init<C: Collection>(fromSorted from: C, toSorted to: C,
                               groupBy: @escaping (C.Element) -> K) where C.Element == T, T: Equatable {
            self.init(fromSorted: from, toSorted: to,
                      isEqual: { $0 == $1 },
                      groupBy: groupBy)
    }
}


extension Updates where T:Groupable {

}

public protocol Groupable {
    var index: String { get }
}

extension String: Groupable {
    public var index: String { return String(prefix(1)) }
}


extension Updates where T: Equatable {
    public init<C: Collection>(
        from: C, to: C,
        indexPathTransform: (IndexPath) -> IndexPath = { $0 }) where C.Element == T {
        self.init(from: from, to: to, isEqual: { $0 == $1 })
    }
}


extension Updates: CustomStringConvertible {
    public var description: String {
        return "total: \(total), insertions: \(insertions) modified: \(modified) deletions: \(deletions)"
    }
}

extension ObservableType {

    func withPreviousOrDefault(startWith first: Element) -> Observable<(Element, Element)> {
        return scan((first, first)) {($0.1, $1)}
    }

    func changeWithPrevious(startWith first: Element) -> Observable<(Element, Element)> {
        return withPreviousOrDefault(startWith: first).skip(1)
    }

    func withPreviousOrInitial(seed: Element) -> Observable<(Element, Element)> {
        var firstCycle = true
        return scan((seed, seed)) {
            if firstCycle {
                firstCycle = false
                return ($1, $1)
            }
            return ($0.1, $1)}
    }
}


//typealias Updates<T> = (total: [T], insertions: [Int], updates: [Int], deletions: [Int])


extension Collection where Element == Diff.Element {
    func split<T>(insertion: (Int) -> T,
                  deletion: (Int) -> T)
        -> (insertions: [T], deletions: [T]) {
            return reduce(into: (insertions: [T](), deletions: [T]())) { result, value in
                switch value {
                case .insert(let at): result.insertions.append(insertion(at))
                case .delete(let at): result.deletions.append(deletion(at))
                }
            }
    }

    func split() -> (insertions: [Int], deletions: [Int]) {
            return reduce(into: (insertions: [Int](), deletions: [Int]())) { result, value in
                switch value {
                case .insert(let at): result.insertions.append(at)
                case .delete(let at): result.deletions.append(at)
                }
            }
    }
}

extension ObservableType where Element:Collection {

    func withDiffsOfPreviousOrInitial(seed: Element, isEqual: @escaping (Element.Element, Element.Element) -> Bool)
        -> Observable<Updates<Element.Element>> {
            return withPreviousOrInitial(seed: seed)
                .map { Updates(from: $0.0, to: $0.1, isEqual: isEqual) }
    }

    public func patch2<T: Collection, U>(from: T, to: T, offset: Int = 0, transform: (T.Element) -> U)
        -> [Patch<U>] where T.Iterator.Element: Equatable {
            return patch(from: from, to: to).map { $0.map(offset: offset, transform) }
    }
}


extension ObservableType where Element:Collection, Element.Iterator.Element: Equatable {

    func withDiffsOfPreviousOrInitial(seed: Element) -> Observable<Updates<Element.Element>> {
            return withPreviousOrInitial(seed: seed)
                .map { Updates(from: $0.0, to: $0.1, isEqual: ==) }
    }

    func withPatchesOfPreviousOrInitial(seed: Element) -> Observable<(Element, [Patch<Element.Element>])> {
        return withPreviousOrInitial(seed: seed)
            .map { from, to in (to, from.diff(to).patch(to: to)) }
    }

    func diffedWithPreviousOrInitial(seed: Element) -> Observable<([Patch<Element.Element>])> {
        return withPatchesOfPreviousOrInitial(seed: seed).map { $0.1 }
    }
}


public extension Diff {

    /// Generates a patch sequence based on a diff. It is a list of steps to be applied to obtain the `to` collection from the `from` one.
    ///
    /// - Complexity: O(N)
    ///
    /// - Parameters:
    ///   - from: The source collection (usually the source collecetion of the callee)
    ///   - to: The target collection (usually the target collecetion of he callee)
    /// - Returns: A sequence of steps to obtain `to` collection from the `from` one.
    func patch<T: Collection, U>(to: T, offset: Int = 0, transform: (T.Element) -> U)
        -> [Patch<U>] where T.Iterator.Element: Equatable {
            return patch(to: to).map { $0.map(offset: offset, transform) }
    }
}


public extension Patch {

    /**
     Rebases patch, applying mapping function specified by `transform`, to any insertion patches

     - Parameter offset:    Offset to add to index, to allow changes to sub sequences within a larger sequence.
     - Parameter transform:    Mapping transform to apply to any insertions.  Useful for mapping data to resulting type.

     - Returns: Remapped patch with corresponding type U
     */

    func map<U>(offset: Int, _ transform: (Element) -> U) -> Patch<U>  {
        switch self {
        case let .insertion(index, element):
            return .insertion(index: index + offset, element: transform(element))
        case let .deletion(index):
            return .deletion(index: index + offset)
        }
    }
}


extension Collection {

    func unzip<T>() -> (insertions: [Patch<T>], deletions: [Patch<T>])
        where Element == Patch<T> {
            return reduce(into: (insertions: [Patch<T>](),
                                 deletions: [Patch<T>]())) { result, value in
                switch value {
                case .insertion: result.insertions.append(value)
                case .deletion: result.deletions.append(value)
                }
            }
    }

    func unzip<T, U>(insertion: (Int, T) -> U, deletion: ((Int) -> Int)? = nil)
        -> (insertions: [U], deletions: [Int]) where Element == Patch<T> {
            return reduce(into: (insertions: [U](), deletions: [Int]())) { result, value in
                switch value {
                case let .insertion(at, value): result.insertions.append(insertion(at, value))
                case .deletion(let at): result.deletions.append(deletion?(at) ?? at)
                }
            }
    }
}

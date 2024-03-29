//
//  CompositeCollectionDataSource.swift
//  Sectional
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


// MARK: UICollectionViewDataSource

/**
 Delegates to nested child handlers with each handling one or more sections

 Only required methods are implemented, since there is no easy way to determine in advance if a child handler will implement an method
 */
public class CompositeCollectionDataSource: NSObject, UICollectionViewDataSource {

    // MARK: Item and section metrics
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return rebasedSections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let source = rebasedSections[section]!
        let rebased = section - source.baseOffset.section
        return source.dataSource.collectionView(collectionView, numberOfItemsInSection: rebased)
    }

    // MARK: Item and section metrics
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let (source, _) = sourceAndPath(absolute: indexPath) // path conversion in nested source
        return source.dataSource.collectionView(collectionView, cellForItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let (source, _) = sourceAndPath(absolute: indexPath) // path conversion in nested source
        return source.dataSource.collectionView!(collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        let (source, indexPath) = sourceAndPath(absolute: indexPath)
        return source.dataSource.collectionView!(collectionView, canMoveItemAt: indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let (fromSource, from) = sourceAndPath(absolute: sourceIndexPath)
        let (toSource, to) = sourceAndPath(absolute: sourceIndexPath)
        guard fromSource.baseOffset == toSource.baseOffset else { assert(false); fatalError("not handled yet!") }
        return fromSource.dataSource.collectionView!(collectionView, moveItemAt: from, to: to)
    }

    @available(iOS 14.0, *)
    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        let indexTitles = sections.map { $0.dataSource }
            .flatMap { $0.indexTitles?(for: collectionView) ?? [] }
        return indexTitles.nilIfEmpty
    }

    @available(iOS 14.0, *)
    public func collectionView(_ collectionView: UICollectionView,
                               indexPathForIndexTitle title: String,
                               at index: Int) -> IndexPath {
        guard let sourceForIndex = indexToSource[index]
            else { fatalError("Trying to retrieve unknown index at \(index)") }
        let relativeIndex = index - sourceForIndex.indexOffset
        guard let path = sourceForIndex.dataSource.collectionView?(
            collectionView, indexPathForIndexTitle: title,
            at: relativeIndex)
            else {
                fatalError("Section source failed to return IndexPath for index: \(index)")
        }
        return path
    }

    func sourceAndPath(absolute: IndexPath) -> (RebasedCollectionDataSource, IndexPath) {
        let source = rebasedSections[absolute.section]!
        return (source, absolute.relativeTo(source.baseOffset))
    }

    fileprivate init(collectionView: UICollectionView,
                     models: [CollectionViewNestedConfiguration]) {
        delegate = CollectionViewCompositeDelegate(
            collectionView: collectionView, models: models)
        self.collectionView = collectionView
        self.sections = models
        super.init()
        configure()
    }

    func configure() {
        var section = 0
        var currentIndex = 0
        for source in sections.map({ $0.dataSource }) {
            let rebased = RebasedCollectionDataSource(
                baseOffset: IndexPath(row: 0, section: section),
                indexOffset: currentIndex,
                source: source)
            let sections = source.numberOfSections?(in: collectionView) ?? 0
            (section ..< section + sections).forEach {
                self.rebasedSections[$0] = rebased
            }
            section += sections

            let indicesInSection: Int
            if #available(iOS 14.0, *) {
                indicesInSection = source.indexTitles?(for: collectionView)?.count ?? 0
            }
            else {
                indicesInSection = 0
            }
            (currentIndex ..< currentIndex + indicesInSection).forEach { index in
                indexToSource[index] = rebased
            }
            currentIndex += indicesInSection
        }
    }

    struct RebasedCollectionDataSource {
        
        init(baseOffset: IndexPath,
             indexOffset: Int,
             source: CollectionViewSectionDataSource) {
            self.baseOffset = baseOffset
            self.indexOffset = indexOffset
            self.dataSource = source
            self.dataSource.baseOffset = baseOffset
        }
        
        var baseOffset: IndexPath
        var indexOffset: Int
        var dataSource: CollectionViewSectionDataSource
    }

    public var sections: [CollectionViewNestedConfiguration] { didSet { configure() }}
    unowned var collectionView: UICollectionView
    private var rebasedSections = [Int: RebasedCollectionDataSource]()
    private var indexToSource = [Int: RebasedCollectionDataSource]()

    fileprivate var delegate: CollectionViewCompositeDelegate
}

extension UICollectionView {

    public func sections(
        _ models: CollectionViewNestedConfiguration...,
        configure: ((CompositeCollectionDataSource, CollectionViewCompositeDelegate) -> Void)? = nil)
        -> CompositeCollectionDataSource {
            sections(from: models, configure: configure)
    }

    public func sections(
        from models: [CollectionViewNestedConfiguration],
        configure: ((CompositeCollectionDataSource, CollectionViewCompositeDelegate) -> Void)? = nil)
        -> CompositeCollectionDataSource {
            let sections = CompositeCollectionDataSource(
                collectionView: self, models: models)
            configure?(sections, sections.delegate)
            dataSource = sections
            delegate = sections.delegate
            return sections
    }
}

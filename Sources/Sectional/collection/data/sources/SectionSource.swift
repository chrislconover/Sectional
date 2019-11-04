//
//  CollectionSection.swift
//  Sectional
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit

public class CollectionSource<T>: CollectionSectionDataSourceBase {

    internal init(collectionView: UICollectionView,
                  data: [T],
                  build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                  onUpdate: CollectionAnimationStrategy<T>) {
//        assert(data.count > 0)
        self.collectionView = collectionView
        self.data = data
        self.onUpdate = onUpdate
        super.init()
        numberOfSections = { _ in return 1 }
        numberOfItemsInSection = { [unowned self] _, _ in self.data.count }
        cellForItemAt = { [unowned self] collectionView, path in
            build(collectionView, path, self.data[path.row])
        }
    }

    public func at(_ index: Int) -> T { return data[index] }
    public var data: [T] { didSet {
        onUpdate.update(collectionView,
                        offset: self.dataSource,
                        from: oldValue, to: data) }}
    fileprivate var collectionView: UICollectionView
    fileprivate var onUpdate: CollectionAnimationStrategy<T>
}

public class CollectionAnimationStrategy<T> {

    func update(_ collectionView: UICollectionView,
                offset: CollectionOffset,
                from oldValue: [T],
                to data: [T],
                completion: ((Bool) -> Void)? = nil) {
        fatalError("Abstract base")
    }
}


extension CollectionAnimationStrategy {

    public class None: CollectionAnimationStrategy {
        override func update(_ collectionView: UICollectionView,
                             offset: CollectionOffset,
                             from oldValue: [T],
                             to data: [T],
                             completion: ((Bool) -> Void)? = nil) {
            collectionView.reloadData()
        }
    }

    public static var none: CollectionAnimationStrategy { return None() }
}


extension CollectionAnimationStrategy {
    public class Animate: CollectionAnimationStrategy {

        var isEqual: (T, T) -> Bool
        init(_ isEqual: @escaping (T, T) -> Bool) {
            self.isEqual = isEqual
        }

        override func update(_ collectionView: UICollectionView,
                             offset: CollectionOffset,
                             from oldValue: [T],
                             to data: [T],
                             completion: ((Bool) -> Void)? = nil) {
            guard let dataSource = collectionView.dataSource else { return }

            let updates = Updates(from: oldValue, to: data, isEqual: isEqual)
            let toCollectionPath = { (row: Int) -> IndexPath in
                return offset.absolutePathFrom(relative: IndexPath(row: row, section: 0)) }
            let insertions = updates.insertions.map(toCollectionPath)
            let deletions = updates.deletions.map(toCollectionPath)

            // if only section
            if dataSource.numberOfSections?(in: collectionView) ?? 0 == 1 {
                // and there were no previous entries
                if oldValue.count == 0 {
                    if updates.total.count > 0 {
                        collectionView.reloadData()
                    }
                    return
                }
            }

            guard updates.hasChanges else {
                collectionView.reloadData()
                return
            }
            collectionView.performBatchUpdates({
                collectionView.deleteItems(at: deletions)
                collectionView.insertItems(at: insertions)
            }, completion: completion)
        }
    }

    public static func animate(_ isEqual: @escaping (T, T) -> Bool)
        -> CollectionAnimationStrategy {
            return Animate(isEqual)
    }
}

extension CollectionAnimationStrategy where T: Equatable {
    public static var animate: CollectionAnimationStrategy { return Animate(==) }
}

extension UICollectionView {


    public func sectionData<T>(_ data: [T],
                               build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                               onUpdate: CollectionAnimationStrategy<T>,
                               configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                               withDelegate: ((CollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionSource<T> {

            let dataSource = CollectionSource<T>(
                collectionView: self, data: data,
                build: build,
                onUpdate: onUpdate)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }
            return dataSource
    }

    public func sectionData<T>(
        _ data: [T],
        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
        onUpdate: CollectionAnimationStrategy<T> = .animate,
        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
        withDelegate: ((CollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionSource<T> where T: Equatable {

            let dataSource = CollectionSource<T>(
                collectionView: self, data: data,
                build: build,
                onUpdate: onUpdate)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }
            return dataSource
    }
}


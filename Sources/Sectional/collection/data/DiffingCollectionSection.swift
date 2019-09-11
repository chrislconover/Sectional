//
//  DiffingCollectionSection.swift
//  Sectional
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit

class CollectionDiffingSource<T>: CollectionSectionDataSourceBase {

    internal init(collectionView: UICollectionView,
                     data: [T],
                     isEqual: @escaping (T, T) -> Bool,
                     build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell) {

        self.collectionView = collectionView
        self.data = data
        self.isEqual = isEqual
        super.init()
        numberOfSections = { _ in return 1 }
        numberOfItemsInSection = { [unowned self] _, _ in
            return self.data.count
        }
        cellForItemAt = { [unowned self] collectionView, path in
            build(collectionView, path, self.data[path.row])
        }
    }

    func at(index: Int) -> T { return data[index] }

    func animateDataChanges(from oldValue: [T]) {
        guard let dataSource = collectionView.dataSource else { return }

        let updates = Updates(from: oldValue, to: data, isEqual: isEqual)
        let toCollectionPath = { (row: Int) -> IndexPath in
            return self.dataSource.absolutePathFrom(
                relative: IndexPath(row: row, section: 0)) }
        let insertions = updates.insertions.map(toCollectionPath)
        let deletions = updates.deletions.map(toCollectionPath)

        // if only section
        if dataSource.numberOfSections?(in: self.collectionView) ?? 0 == 1 {
            // and there were no previous entries
            if oldValue.count == 0 {
                if updates.total.count > 0 {
                    self.collectionView.reloadData()
                }
                return
            }
        }

        guard updates.hasChanges else {
            return
        }
        self.collectionView.performBatchUpdates({
            self.collectionView.deleteItems(at: deletions)
            self.collectionView.insertItems(at: insertions)
            //                    Logger.trace("Committing animations")
        }, completion: { done in
            //                    Logger.trace("Animations complete")
        })
    }

    var data: [T] { didSet {
        animateDataChanges(from: oldValue)
        }}

    var isEqual: (T, T) -> Bool
    var collectionView: UICollectionView
}


extension UICollectionView {


    func sectionData<T>(diffing data: [T],
                        isEqual: @escaping (T, T) -> Bool,
                        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                        withDelegate: ((CollectionDiffingSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionDiffingSource<T> {

            let dataSource = CollectionDiffingSource<T>(
                collectionView: self, data: data,
                isEqual: isEqual,
                build: build)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }
            return dataSource
    }

    func sectionData<T>(diffing data: [T],
                        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                        isEqual: @escaping (T, T) -> Bool,
                        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                        withDelegate: ((CollectionDiffingSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionDiffingSource<T> {

            let dataSource = CollectionDiffingSource<T>(
                collectionView: self, data: data,
                isEqual: isEqual,
                build: build)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }
            return dataSource
    }

    func sectionData<T>(diffing data: [T],
                        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                        withDelegate: ((CollectionDiffingSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionDiffingSource<T> where T: Equatable {

            let dataSource = CollectionDiffingSource<T>(
                collectionView: self, data: data,
                isEqual: ==,
                build: build)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }
            return dataSource
    }
}


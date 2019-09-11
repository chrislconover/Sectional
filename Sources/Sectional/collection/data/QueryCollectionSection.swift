//
//  QueryCollectionSection.swift
//  Sectional
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit




class CollectionQuerySource<T>: CollectionSectionDataSourceBase {

    static func create(for collectionView: UICollectionView,
                       query: QueryDataSource<T>,
                       build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                       configure: ((CollectionQuerySource, UICollectionView) -> ())? = nil,
                       withDelegate: ((CollectionQuerySource, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionQuerySource {

            let dataSource = CollectionQuerySource(collectionView: collectionView, query: query, build: build)
            configure?(dataSource, collectionView)

            // if the caller wants to override the delegate
            if let withDelegate = withDelegate {

                // then initialize delegate override and call handler for configuration
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }

            return dataSource
    }

    fileprivate init(collectionView: UICollectionView,
                     query: QueryDataSource<T>,
                     build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell) {

        self.query = query
        self.collectionView = collectionView
        super.init()

        numberOfSections = { _ in return 1 }
        numberOfItemsInSection = { [unowned self] _, _ in self.data.count }
        cellForItemAt = { [unowned self] cv, path in build(cv, path, self.data[path.row]) }

        configureQuery(query)
    }

    func commit() { _ = query.commit() }

    func configureQuery(_ query: QueryDataSource<T>) { self.query = query }
    var query: QueryDataSource<T> {
        didSet {
            query.onChanged = { [unowned self] updates in

                let toCollectionPath = { (row: Int) -> IndexPath in
                    return self.dataSource.absolutePathFrom(
                        relative: IndexPath(row: row, section: 0)) }
                let insertions = updates.insertions.map(toCollectionPath)
                let deletions = updates.deletions.map(toCollectionPath)

                guard updates.deletions.count + updates.insertions.count > 0 else {
                    if self.data.count == 0 {
                        self.data = updates.total
                        if self.collectionView.dataSource != nil {
                            self.collectionView.reloadData()
                        }
                    }
                    return
                }

                self.data = updates.total
                self.collectionView.performBatchUpdates({
                    self.collectionView.deleteItems(at: deletions)
                    self.collectionView.insertItems(at: insertions)
                    //                    Logger.trace("Committing animations")
                }, completion: { done in
                    //                    Logger.trace("Animations complete")
                })
            }
        }}

    func at(index: Int) -> T { return data[index] }
    var data: [T] = []
    unowned var collectionView: UICollectionView
}

extension UICollectionView {
    func sectionDataSource<T>(
        query: QueryDataSource<T>,
        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
        configure: ((CollectionQuerySource<T>, UICollectionView) -> ())? = nil,
        withDelegate: ((CollectionQuerySource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionQuerySource<T> {

            let dataSource = CollectionQuerySource(collectionView: self, query: query, build: build)
            configure?(dataSource, self)

            // if the caller wants to override the delegate
            if let withDelegate = withDelegate {

                // then initialize delegate override and call handler for configuration
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }

            return dataSource
    }
}

//
//  StaticCollectionSection.swift
//  Sectional
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit



class CollectionStaticSource<T>: CollectionSectionDataSourceBase {

    fileprivate init(collectionView: UICollectionView,
                     data: [T],
                     refresh: (() -> Void)? = nil,
                     build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell)  {

        self.collectionView = collectionView
        super.init()
        self.data = data

        numberOfSections = { _ in
            refresh?()
            return 1
        }
        numberOfItemsInSection = { [unowned self] _, section in
            return self.data.count
        }
        cellForItemAt = { [unowned self] cv, path in
            build(cv, path, self.data[path.row])
        }
    }

    func at(index: Int) -> T { return data[index] }
    var data: [T] = [] { didSet { collectionView.reloadData() }}
    unowned var collectionView: UICollectionView
}


extension UICollectionView {

    func sectionData<T>(
        from data: [T],
        refresh: (()->Void)? = nil,
        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
        withDelegate: ((CollectionStaticSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionStaticSource<T> {
            let dataSource = CollectionStaticSource(
                collectionView: self,
                data: data,
                refresh: refresh,
                build: build)
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

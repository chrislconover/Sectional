//
//  BaseCollectionSectionDataSource.swift
//  IQDashboard
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


class CollectionSectionDataSourceBase: NSObject, CollectionViewSectionDataSource {

    var indexTitles: ((UICollectionView) -> [String]?)! = nil
    var indexPathForTitleAt: ((UICollectionView, String, Int) -> IndexPath)! = nil

    init(indexTitles: ((UICollectionView) -> [String]?)! = nil,
                  indexPathForTitleAt: ((UICollectionView, String, Int) -> IndexPath)! = nil) {
        self.indexTitles = indexTitles
        self.indexPathForTitleAt = indexPathForTitleAt
        super.init()
    }

    func indexTitles(for collectionView: UICollectionView) -> [String]? {
        return self.indexTitles(collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        return indexPathForTitleAt(collectionView, title, index)
    }


    override func responds(to aSelector: Selector!) -> Bool {
        switch aSelector {
        case Selector.indexTitles:
            return indexTitles != nil
        case Selector.indexPathForIndexTitleAt:
            return indexPathForTitleAt != nil
        default:
            return super.responds(to: aSelector)
        }
    }

    var rebase: () -> Void = {}
    var baseOffset: IndexPath = IndexPath(item: 0, section: 0)
    var totalSections: () -> Int = { 1 }

    var numberOfSections: (_ in: UICollectionView) -> Int = { _ in
        fatalError("This must be defined")
    }

    var numberOfItemsInSection: (_ collectionView: UICollectionView, Int) -> Int = {_, _ in
        fatalError("This must be defined")
    }

    var cellForItemAt: (UICollectionView, IndexPath) -> UICollectionViewCell = { _, _ in
        fatalError("This must be defined")
    }

    var viewForSupplementaryElementOfKind: (UICollectionView, String, IndexPathOffset) -> UICollectionReusableView = {
        view, kind, at in fatalError("Must return valid view if specified via layout")
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections(collectionView)
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(collectionView, section)
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cellForItemAt(collectionView, indexPath)
    }

    // The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return viewForSupplementaryElementOfKind(collectionView, kind, pathOffset(absolute: indexPath))
    }

    static func `for`(collectionView: UICollectionView,
                      configure: (CollectionSectionDataSourceBase) -> ()) -> UICollectionViewDataSource {
        let dataSource = CollectionSectionDataSourceBase()
        configure(dataSource)
        return dataSource
    }

    var delegate: CollectionViewNestedDelegateType?
}

extension CollectionSectionDataSourceBase: CollectionViewNestedConfiguration {
    var dataSource: CollectionViewSectionDataSource {
        return self
    }
}

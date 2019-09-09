//
//  GroupingCollectionSource.swift
//  IQDashboard
//
//  Created by Chris Conover on 10/10/18.
//

import UIKit


class GroupingCollectionSource<T, K>: CollectionSectionDataSourceBase
    where K: Comparable & Hashable & CustomStringConvertible {

    internal init(collectionView: UICollectionView,
                  data: [T],
                  isEqual: @escaping (T, T) -> Bool,
                  groupBy: @escaping (T) -> K,
                  prepare: ((UICollectionView)->())? = nil,
                  build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell) {

        self.collectionView = collectionView
        self.data = data
        self.isEqual = isEqual
        self.groupBy = groupBy
        self.prepare = prepare
        self.current = SectionedUpdates(initial: data, groupBy: groupBy)
        super.init()

        indexTitles = { [unowned self] collection in
            self.current.sectionKeys.map { $0.description } }
        indexPathForTitleAt = { collection, title, at in
            IndexPath(item: 0, section: at) }

        totalSections = { [unowned self] in
            // assume just this section, unless overriden by outer composite
            self.current.sections.count
        }
        numberOfSections = { [unowned self] _ in
            let sections = self.current.sections.count
            self.prepare?(self.collectionView)
            return sections
        }
        numberOfItemsInSection = { [unowned self] _, section in
            let count = self.current.sections[section].count
            return count
        }
        cellForItemAt = { [unowned self] collectionView, path in
            build(collectionView, path, self.current.sections[path.section][path.row])
        }
    }

    func at(index: Int) -> T { return data[index] }
    var data: [T] { didSet {
        current = SectionedUpdates<T, K>(
            fromSorted: oldValue, toSorted: data,
            isEqual: isEqual, groupBy: groupBy)
        }}

    var current: SectionedUpdates<T, K> {
        didSet {

            if current.sectionKeys.count != oldValue.sectionKeys.count {
                rebase()
            }

            let insertions = current.insertions.map(self.dataSource.absolutePathFrom)
            let deletions = current.deletions.map(self.dataSource.absolutePathFrom)
            assert(insertions.sorted() == insertions)
            assert(deletions.sorted() == deletions)

            // if this is the only section builder
            if totalSections() - current.sections.count == 0 {
                // and there were no previous entries
                if !oldValue.hasData {
                    if current.hasData {
                        self.collectionView.reloadData()
                    }
                    return
                }
            }

            guard current.hasChanges else { return }
            self.collectionView.performBatchUpdates({
                self.collectionView.deleteItems(at: deletions)
                self.collectionView.deleteSections(IndexSet(current.deletedSections))
                self.collectionView.insertItems(at: insertions)
                self.collectionView.insertSections(IndexSet(current.insertedSections))
                self.prepare?(self.collectionView)
                //                    Logger.trace("Committing animations")
            }, completion: { done in
                //                    Logger.trace("Animations complete")
            })
        }
    }

    var isEqual: (T, T) -> Bool
    var groupBy: (T) -> K
    var prepare: ((UICollectionView)->())? = nil
    unowned var collectionView: UICollectionView
}

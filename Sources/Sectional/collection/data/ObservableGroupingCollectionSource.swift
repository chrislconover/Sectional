//
//  ObservableSectionGroupingSource.swift
//  Sectional
//
//  Created by Chris Conover on 10/10/18.
//  Copyright © 2018 Curious Applications. All rights reserved.
//

import UIKit
import RxSwift


// TODO: figure out how to unify grouping and non grouping sources, shouldn't need two hierarchies

/// ObservableCollectionSource: simplified collection data source that directly acts upon a RxSwift collection, eliminating the need for the intermediate Query Source.
class GroupingObservableSource<T, K>: GroupingCollectionSource<T, K>
    where K: Comparable & Hashable & CustomStringConvertible {

    fileprivate init(collectionView: UICollectionView,
                     defer source: Observable<[T]>,
                     isEqual: @escaping (T, T) -> Bool,
                     groupBy: @escaping (T) -> K,
                     prepare: ((UICollectionView)->())? = nil,
                     build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                     onError: ((Error) -> Void)?) {
        self.source = source
        super.init(collectionView: collectionView, data: [],
                   isEqual: isEqual, groupBy: groupBy,
                   prepare: prepare,
                   build: build)
    }

    func bind(_ source: Observable<[T]>) {
        disposeBag = DisposeBag()
        source.subscribe(
            onNext: { [unowned self] data in self.data = data },
            onError: { [unowned self] error in self.onError?(error) },
            onCompleted: {},
            onDisposed: {})
            .disposed(by: disposeBag)
    }

    func commit() {
        guard let source = source else { return }
        bind(source)
        self.source = nil
    }

    var onError: ((Error) -> Void)?
    var source: Observable<[T]>?
    var disposeBag: DisposeBag!
}

extension UICollectionView {

    func sectionData<T, K>(commit source: Observable<[T]>,
                           isEqual: @escaping (T, T) -> Bool,
                           groupBy: @escaping (T) -> K,
                           prepare: ((UICollectionView)->())? = nil,
                           build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                           viewForSupplementaryElementOfKind: @escaping ((GroupingObservableSource<T, K>, UICollectionView, String, IndexPathOffset) -> UICollectionReusableView),
                           referenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? = nil,
                           onError: ((Error) -> Void)? = nil,
                           configure: ((GroupingObservableSource<T, K>, UICollectionView) -> ())? = nil,
                           withDelegate: ((GroupingObservableSource<T, K>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> GroupingObservableSource<T, K> where K: Comparable & Hashable {
            let dataSource = self.sectionData(
                defer: source,
                isEqual: isEqual,
                groupBy: groupBy,
                prepare: prepare,
                build: build,
                viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind,
                referenceSizeForHeaderInSection: referenceSizeForHeaderInSection,
                onError: onError,
                configure: configure,
                withDelegate: withDelegate)
            dataSource.commit()
            return dataSource
    }

    func sectionData<T, K>(defer source: Observable<[T]>,
                        isEqual: @escaping (T, T) -> Bool,
                        groupBy: @escaping (T) -> K,
                        prepare: ((UICollectionView)->())? = nil,
                        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                        viewForSupplementaryElementOfKind: @escaping ((GroupingObservableSource<T, K>, UICollectionView, String, IndexPathOffset) -> UICollectionReusableView),
                        referenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? = nil,
                        onError: ((Error) -> Void)? = nil,
                        configure: ((GroupingObservableSource<T, K>, UICollectionView) -> ())? = nil,
                        withDelegate: ((GroupingObservableSource<T, K>, CollectionViewSectionDelegate) -> Void)? = nil) -> GroupingObservableSource<T, K>
        where K: Comparable & Hashable {

            let dataSource = GroupingObservableSource<T, K>(
                collectionView: self,
                defer: source,
                isEqual: isEqual,
                groupBy: groupBy,
                prepare: prepare,
                build: build,
                onError: onError)
            configure?(dataSource, self)

            // if the caller wants to override the delegate

            dataSource.viewForSupplementaryElementOfKind = { [unowned dataSource] in
                return viewForSupplementaryElementOfKind(dataSource, $0, $1, $2)
            }

            var existingDelegate: CollectionViewSectionDelegate?
            let lazyDelegate: () -> CollectionViewSectionDelegate = {
                if existingDelegate == nil { existingDelegate = CollectionViewSectionDelegate() }
                return existingDelegate!
            }

            if let referenceSizeForHeaderInSection = referenceSizeForHeaderInSection {
                lazyDelegate().referenceSizeForHeaderInSection = referenceSizeForHeaderInSection
            }

            if let withDelegate = withDelegate {
                // then initialize delegate override and call handler for configuration
                withDelegate(dataSource, lazyDelegate())
            }
            dataSource.delegate = existingDelegate

            return dataSource
    }
}

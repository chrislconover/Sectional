//
//  ObservableCollectionSection.swift
//  IQDashboard
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit
import RxSwift


/// ObservableCollectionSource: simplified collection data source that directly acts upon a RxSwift collection, eliminating the need for the intermediate Query Source.
class ObservableCollectionSource<T>: CollectionDiffingSource<T> {

    fileprivate init(collectionView: UICollectionView,
                     defer source: Observable<[T]>,
                     isEqual: @escaping (T, T) -> Bool,
                     build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                     onError: ((Error) -> Void)?) {
        self.source = source
        super.init(collectionView: collectionView, data: [], isEqual: isEqual, build: build)
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

    func sectionData<T>(commit source: Observable<[T]>,
                        isEqual: @escaping (T, T) -> Bool,
                        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                        onError: ((Error) -> Void)? = nil,
                        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                        withDelegate: ((ObservableCollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> ObservableCollectionSource<T> {

            let dataSource = ObservableCollectionSource<T>(
                collectionView: self,
                defer: source,
                isEqual: isEqual,
                build: build,
                onError: onError)
            configure?(dataSource, self)

            // if the caller wants to override the delegate
            if let withDelegate = withDelegate {

                // then initialize delegate override and call handler for configuration
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }

            dataSource.commit()
            return dataSource
    }

    func sectionData<T>(defer source: Observable<[T]>,
                        isEqual: @escaping (T, T) -> Bool,
                        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                        onError: ((Error) -> Void)? = nil,
                        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                        withDelegate: ((ObservableCollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> ObservableCollectionSource<T> {

            let dataSource = ObservableCollectionSource<T>(
                collectionView: self,
                defer: source,
                isEqual: isEqual,
                build: build,
                onError: onError)
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

//
//  ObservableCollectionSection.swift
//  Sectional
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit
import RxSwift


/// ObservableCollectionSource: simplified collection data source that directly acts upon a RxSwift collection, eliminating the need for the intermediate Query Source.
public class ObservableCollectionSource<T>: CollectionSource<T> {

    fileprivate init(collectionView: UICollectionView,
                     defer source: Observable<[T]>,
                     build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                     onUpdate: CollectionAnimationStrategy<T>,
                     onError: ((Error) -> Void)?) {
        self.source = source
        super.init(collectionView: collectionView, data: [],
                   build: build, onUpdate: onUpdate)
    }

    public func bind(_ source: Observable<[T]>) {
        disposeBag = DisposeBag()
        source.subscribe(
            onNext: { [unowned self] data in self.data = data },
            onError: { [unowned self] error in self.onError?(error) },
            onCompleted: {},
            onDisposed: {})
            .disposed(by: disposeBag)
    }

    public func commit() {
        guard let source = source else { return }
        bind(source)
        self.source = nil
    }

    var onError: ((Error) -> Void)?
    var source: Observable<[T]>?
    var disposeBag: DisposeBag!
}

extension UICollectionView {

    public func sectionData<T>(commit source: Observable<[T]>,
                               build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                               onUpdate: CollectionAnimationStrategy<T>,
                               onError: ((Error) -> Void)? = nil,
                               configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                               withDelegate: ((ObservableCollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> ObservableCollectionSource<T> {

            let dataSource = ObservableCollectionSource<T>(
                collectionView: self, defer: source, build: build,
                onUpdate: onUpdate, onError: onError)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }

            dataSource.commit()
            return dataSource
    }


    public func sectionData<T>(defer source: Observable<[T]>,
                               build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
                               onUpdate: CollectionAnimationStrategy<T>,
                               onError: ((Error) -> Void)? = nil,
                               configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
                               withDelegate: ((ObservableCollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> ObservableCollectionSource<T> {

            let dataSource = ObservableCollectionSource<T>(
                collectionView: self, defer: source, build: build,
                onUpdate: onUpdate, onError: onError)
            configure?(dataSource, self)

            if let withDelegate = withDelegate {
                let delegate = CollectionViewSectionDelegate()
                withDelegate(dataSource, delegate)
                dataSource.delegate = delegate
            }

            return dataSource
    }
}

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
                  onUpdate: CollectionAnimationStrategy<T>,
                  viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil) {
        self.collectionView = collectionView
        self.data = data
        self.onUpdate = onUpdate
        super.init()
        numberOfSections = { _ in return 1 }
        numberOfItemsInSection = { [unowned self] _, _ in self.data.count }
        cellForItemAt = { [unowned self] collectionView, path in
            build(collectionView, path, self.data[path.row]) }
    
        if let viewForSupplementaryElementOfKind = viewForSupplementaryElementOfKind {
            self.viewForSupplementaryElementOfKind = viewForSupplementaryElementOfKind
        }
    }

    public func at(_ index: Int) -> T { return data[index] }
    
    public private(set) var data: [T]
    public func update(data newValue: [T]) {
        onUpdate.update(collectionView,
                        offset: self.dataSource,
                        from: data, to: newValue,
                        updateState: { self.data = $0 })
    }
    
    var collectionView: UICollectionView
    fileprivate var onUpdate: CollectionAnimationStrategy<T>
}

public class CollectionAnimationStrategy<T> {

    func update(_ collectionView: UICollectionView,
                offset: CollectionOffset,
                from oldValue: [T],
                to data: [T],
                updateState: ([T]) -> Void,
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
                             updateState: ([T]) -> Void,
                             completion: ((Bool) -> Void)? = nil) {
            updateState(data)
            collectionView.reloadData()
        }
    }

    public static var none: CollectionAnimationStrategy { return None() }
}


extension CollectionAnimationStrategy {

    public static func animate(_ isEqual: @escaping (T, T) -> Bool)
        -> CollectionAnimationStrategy {
            return Animate(isEqual)
    }
    
    public class Animate: CollectionAnimationStrategy {

        var isEqual: (T, T) -> Bool
        init(_ isEqual: @escaping (T, T) -> Bool) {
            self.isEqual = isEqual
        }

        override func update(_ collectionView: UICollectionView,
                             offset: CollectionOffset,
                             from oldValue: [T],
                             to data: [T],
                             updateState: ([T]) -> Void,
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
                        updateState(data)
                        collectionView.reloadData()
                    }
                    return
                }
            }

            guard updates.hasChanges else {
                updateState(data)
                collectionView.reloadData()
                return
            }
            
            collectionView.performBatchUpdates({
                updateState(data)
                collectionView.deleteItems(at: deletions)
                collectionView.insertItems(at: insertions)
            }, completion: completion)
        }
    }
}

extension CollectionAnimationStrategy where T: IdentifiableType {
    public static var animate: CollectionAnimationStrategy {
        Animate { lhs, rhs in lhs.id == rhs.id} }
}


extension UICollectionView {

    public func section<T>(
        with data: [T],
        build: @escaping (UICollectionView, IndexPath, T) -> UICollectionViewCell,
        onUpdate: CollectionAnimationStrategy<T>,
        referenceSizeForHeader: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? = nil,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil,
        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
        withDelegate: ((CollectionSource<T>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionSource<T> {

            let dataSource = CollectionSource<T>(
                collectionView: self,
                data: data,
                build: build,
                onUpdate: onUpdate,
                viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind)
            configure?(dataSource, self)

            var sectionDelegate: CollectionViewSectionDelegate!
            let delegate: () -> CollectionViewSectionDelegate = {
                if sectionDelegate == nil { sectionDelegate = CollectionViewSectionDelegate() }
                return sectionDelegate!
            }
            
            if let referenceSizeForHeader = referenceSizeForHeader {
                delegate().referenceSizeForHeaderInSection = referenceSizeForHeader
            }
            withDelegate?(dataSource, delegate())
            dataSource.delegate = sectionDelegate
            
            self.dataSource = dataSource
            if let delegate = dataSource.delegate {
                self.delegate = delegate
            }
            
            return dataSource
    }

    /// Creates an implementation of a single section data source.
    ///
    /// Override for configuring custom cell type.  Provides default implementation for creation, defers to closure parameter for configuration.
    /// This method automatically registers the specified cell type with the collection view.
    ///
    /// ```
    /// collection.column(with: models, cellType: ModelViewCell<MyView>, onUpdate: .animate { $0.id == $1.id })
    /// ```
    ///
    /// - Parameter data: A variadic list of data elements conforming to `ViewModelType`
    /// - Parameter cellType: Class type for cell to use, overrides provide default values of ModelViewCell<V>
    /// - Parameter configureCell: Closure that takes parameters of `UICollectionView`, `IndexPath`, `M` (model type), and `C` (cell type),  returns a properly configured cell
    /// - Parameter onUpdate: Animation strategy to use for insertions or deletions.  Options are .none, .animated, and .animate(...)
    /// - Parameter referenceSizeForHeader: Optional closure that takes parameters of `UICollectionView`, and `UICollectionViewLayout`, and return section header size, if desired
    /// - Parameter viewForSupplementaryElementOfKind: Optional closure that takes parameters of `UICollectionView`,  `kind: String`,and `IndexPathOffset` and returns properly configured supplementary view. Used for section header support.
    /// - Parameter configure: Optional closure for use in additional confguration, normally used for registering cells, but that is done automatically
    /// - Parameter withDelegate: Optional closure for configuring a delegate (additional behaviors) for the section
    /// - Returns: An implementation of a single section data source, that can be combined with additional data sources for a multi-section data source via the `sections(...)` methods
    public func section<M, C: UICollectionViewCell>(
        with data: [M],
        cellType: C.Type = C.self,
        configureCell: @escaping (UICollectionView, IndexPath, M, C) -> Void,
        onUpdate: CollectionAnimationStrategy<M>,
        referenceSizeForHeader: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? = nil,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil,
        configure: ((CollectionSectionDataSourceBase, UICollectionView) -> ())? = nil,
        withDelegate: ((CollectionSource<M>, CollectionViewSectionDelegate) -> Void)? = nil)
        -> CollectionSource<M> {

            register(C.self)
            return section(
                with: data,
                build: { collection, path, model in
                    let cell = collection.dequeue(cellType, for: path)
                    configureCell(collection, path, model, cell)
                    return cell },
                onUpdate: onUpdate,
                referenceSizeForHeader: referenceSizeForHeader,
                viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind,
                configure: configure,
                withDelegate: withDelegate)
    }
}


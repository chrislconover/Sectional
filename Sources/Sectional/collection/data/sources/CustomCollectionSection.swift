//
//  CustomCollectionSection.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit

public protocol IdentifiableType: Equatable {
    associatedtype ID : Hashable

    /// The stable identity of the entity associated with `self`.
    var id: Self.ID { get }
}

extension CustomCellModel: IdentifiableType {
    public var id: String { identify() }
}

extension Equatable where Self: IdentifiableType {
    public static func ==(lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
}

public class CustomCellModel {
    init(register: @escaping (UICollectionView) -> Void,
         build: @escaping (UICollectionView, IndexPath) -> UICollectionViewCell,
         identify: @escaping () -> String,
         sizeForItem: ((UICollectionView, IndexPathOffset) -> CGSize)? = nil,
         shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
         didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil,
         shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
         didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil) {
        self.register = register
        self.build = build
        self.identify = identify
        self.sizeForItem = sizeForItem
        self.shouldSelectItemAt = shouldSelectItemAt
        self.didSelectItemAt = didSelectItemAt
        self.shouldDeselectItemAt = shouldDeselectItemAt
        self.didDeselectItemAt = didDeselectItemAt
    }

    var register: (UICollectionView) -> Void
    var build: (UICollectionView, IndexPath) -> UICollectionViewCell
    public var identify: () -> String
    var sizeForItem: ((UICollectionView, IndexPathOffset) -> CGSize)?
    var shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    var shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
}


public extension UICollectionViewCell {
    public static func custom<T: UICollectionViewCell>(
        type: T.Type,
        build: @escaping (UICollectionView, IndexPath) -> T,
        identify: @escaping @autoclosure () -> String,
        sizeForItem: ((UICollectionView, IndexPathOffset) -> CGSize)? = nil,
        shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
        didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil,
        shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
        didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil) -> CustomCellModel {

        CustomCellModel(
            register: { collection in collection.register(T.self) },
            build: build,
            identify: identify,
            sizeForItem: sizeForItem,
            shouldSelectItemAt: shouldSelectItemAt,
            didSelectItemAt: didSelectItemAt,
            shouldDeselectItemAt: shouldDeselectItemAt,
            didDeselectItemAt: didDeselectItemAt)
    }
}


public class CustomSectionSource: CollectionSource<CustomCellModel>, CollectionViewNestedDelegateType {

    fileprivate init(
        collectionView: UICollectionView,
        cells: [CustomCellModel],
        onUpdate: CollectionAnimationStrategy<CustomCellModel>,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil) {
        super.init(
            collectionView: collectionView, data: cells,
            build: { collection, indexPath, model in model.build(collection, indexPath) },
            onUpdate: onUpdate,
            viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind)
        cells.forEach { $0.register(collectionView) }
        self.delegate = self
    }
    
    override public var data: [CustomCellModel] {
        get { super.data }
        set {
            newValue.forEach { $0.register(collectionView) }
            super.data = newValue
        }
    }
    
    override public func responds(to aSelector: Selector!) -> Bool {
        if aSelector == Selector.sizeForItemAt {
            return data.contains() { $0.sizeForItem != nil }
        }
        
        return super.responds(to: aSelector)
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        guard let size = data[indexPath.item].sizeForItem?(collectionView, pathOffset(absolute: indexPath)) else {
            assert(false, "If size is specified for any cell, then it should be specified for all cells")
            return ((collectionViewLayout as? UICollectionViewFlowLayout)?.estimatedItemSize)
                ?? ((collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize)
                ?? .init(width: 39, height: 39) // to make it easier to search
        }
        
        return size
    }
    
    // MARK: selection
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return data[indexPath.item].shouldSelectItemAt?(
            collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        data[indexPath.item].didSelectItemAt?(collectionView, pathOffset(absolute: indexPath))
    }

    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        data[indexPath.item].shouldDeselectItemAt?(
            collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        data[indexPath.item].didDeselectItemAt?(collectionView, pathOffset(absolute: indexPath))
    }
}

extension UICollectionView {

    public func section(
        with cells: [CustomCellModel],
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        onUpdate: CollectionAnimationStrategy<CustomCellModel>,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {

        let section = CustomSectionSource(collectionView: self,
                                          cells: cells,
                                          onUpdate: onUpdate,
                                          viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind)
        configure?(section, self)

        // if the caller wants to override the delegate
        if let withDelegate = withDelegate {

            // then initialize delegate override and call handler for configuration
            let delegate = CollectionViewSectionDelegate()
            withDelegate(section, delegate)
            section.delegate = delegate
        }

        return section
    }

    public func section(
        with cells: CustomCellModel...,
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        onUpdate: CollectionAnimationStrategy<CustomCellModel>,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {
        return self.section(with: cells,
                            configure: configure,
                            onUpdate: onUpdate,
                            viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind,
                            withDelegate: withDelegate)
    }
}

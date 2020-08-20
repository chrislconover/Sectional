//
//  CustomCollectionSection.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit

public protocol IdentifiableType {
    associatedtype ID : Hashable

    /// The stable identity of the entity associated with `self`.
    var id: Self.ID { get }
}

extension CustomCellModel: IdentifiableType, Equatable {
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


extension CustomCellModel {
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


public class CustomSectionSource: CollectionSource<CustomCellModel> {

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
        self.delegate = customDelegate
    }
    
    override public var data: [CustomCellModel] {
        get { super.data }
        set {
            newValue.forEach { $0.register(collectionView) }
            super.update(data: newValue)
        }
    }
    
    override public func responds(to aSelector: Selector!) -> Bool {
        switch aSelector {
        case Selector.sizeForItemAt:
            return data.contains() { $0.sizeForItem != nil }
        case Selector.shouldSelectItemAt:
            return data.contains() { $0.shouldSelectItemAt != nil }
        case Selector.didSelectItemAt:
            return data.contains() { $0.didSelectItemAt != nil }
        case Selector.shouldDeselectItemAt:
            return data.contains() { $0.shouldDeselectItemAt != nil }
        case Selector.didDeselectItemAt:
            return data.contains() { $0.shouldDeselectItemAt != nil }
        default:
            return super.responds(to: aSelector)
        }
    }

    
    public lazy var customDelegate: CollectionViewSectionDelegate = {
        let delegate = CollectionViewSectionDelegate()
        delegate.sizeForItemWithLayoutAt = { [unowned self] collection, layout, path in
            guard let size = self.data[path.inSection.item].sizeForItem?(collection, path) else {
                fatalError("If size is specified for any cell, then it should be specified for all cells") }
            return size
        }
        
        delegate.shouldSelectItemAt = { [unowned self] collection, path in
            self.data[path.inSection.item].shouldSelectItemAt?(collection, path) ?? true }
        
        delegate.didSelectItemAt = { [unowned self] collection, path in
            self.data[path.inSection.item].didSelectItemAt?(collection, path) }
        
        delegate.shouldDeselectItemAt = { [unowned self] collection, path in
            self.data[path.inSection.item].shouldDeselectItemAt?(collection, path) ?? true }

        delegate.didDeselectItemAt = { [unowned self] collection, path in
            self.data[path.inSection.item].didDeselectItemAt?(collection, path) }

        return delegate }()
}

extension UICollectionView {

    public func section(
        with cells: [CustomCellModel],
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        onUpdate: CollectionAnimationStrategy<CustomCellModel>,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {
        
        let section = CustomSectionSource(
            collectionView: self,
            cells: cells,
            onUpdate: onUpdate,
            viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind)
        configure?(section, self)
        
        // if the caller wants to override the delegate
        if let withDelegate = withDelegate {
            
            // then initialize delegate override and call handler for configuration
            let delegate = CollectionSectionDefaultDelegate(withOverridingDelegate: section.delegate!)
            withDelegate(section, delegate)
            section.delegate = delegate
        }
        
        dataSource = section
        delegate = section.delegate
        
        return section
    }

    public func section(
        with cells: CustomCellModel...,
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        onUpdate: CollectionAnimationStrategy<CustomCellModel>,
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {
        section(with: cells,
                configure: configure,
                onUpdate: onUpdate,
                viewForSupplementaryElementOfKind: viewForSupplementaryElementOfKind,
                withDelegate: withDelegate)
    }
}

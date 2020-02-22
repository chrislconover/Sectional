//
//  CustomCollectionSection.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


public struct CustomCellModel {
    init(register: @escaping (UICollectionView) -> Void,
         build: @escaping (UICollectionView, IndexPathOffset) -> UICollectionViewCell,
         sizeForItem: ((UICollectionView, IndexPath) -> CGSize)? = nil,
         shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
         didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil,
         shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
         didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil) {
        self.register = register
        self.build = build
        self.sizeForItem = sizeForItem
        self.shouldSelectItemAt = shouldSelectItemAt
        self.didSelectItemAt = didSelectItemAt
        self.shouldDeselectItemAt = shouldDeselectItemAt
        self.didDeselectItemAt = didDeselectItemAt
    }

    var register: (UICollectionView) -> Void
    var build: (UICollectionView, IndexPathOffset) -> UICollectionViewCell
    var sizeForItem: ((UICollectionView, IndexPath) -> CGSize)?
    var shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    var shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
}


public extension UICollectionViewCell {
    public static func custom<T: UICollectionViewCell>(
        type: T.Type,
        build: @escaping (UICollectionView, IndexPathOffset) -> T,
        sizeForItem: ((UICollectionView, IndexPath) -> CGSize)? = nil,
        shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
        didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil,
        shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
        didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil) -> CustomCellModel {

        CustomCellModel(
            register: { (collection: UICollectionView) in collection.register(T.self) },
            build: build,
            sizeForItem: sizeForItem,
            shouldSelectItemAt: shouldSelectItemAt,
            didSelectItemAt: didSelectItemAt,
            shouldDeselectItemAt: shouldDeselectItemAt,
            didDeselectItemAt: didDeselectItemAt)
    }
}


public class CustomSectionSource: NSObject, CollectionViewNestedConfiguration, CollectionViewSectionDataSource, CollectionViewNestedDelegateType {

    public var dataSource: CollectionViewSectionDataSource { return self }
    public var delegate: CollectionViewNestedDelegateType?

    public var baseOffset: IndexPath = IndexPath(item: 0, section: 0)
    public var rebase: () -> Void = {}
    public var totalSections: () -> Int = { 1 }

    fileprivate init(
        cells: [CustomCellModel],
        viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)? = nil) {
        self.cells = cells
        self.viewForSupplementaryElementOfKind = viewForSupplementaryElementOfKind
        super.init()
        self.delegate = self
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cells.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return cells[indexPath.item].build(collectionView, pathOffset(absolute: indexPath))
    }


    // MARK: selection
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return cells[indexPath.item].shouldSelectItemAt?(
            collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        cells[indexPath.item].didSelectItemAt?(collectionView, pathOffset(absolute: indexPath))
    }

    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return cells[indexPath.item].shouldDeselectItemAt?(
            collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        cells[indexPath.item].didDeselectItemAt?(collectionView, pathOffset(absolute: indexPath))
    }

    // MARK: header
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let viewForSupplementaryElementOfKind = viewForSupplementaryElementOfKind
            else { fatalError("Must return valid view if specified via layout") }
        return viewForSupplementaryElementOfKind(collectionView, kind, pathOffset(absolute: indexPath))
    }

    var viewForSupplementaryElementOfKind: ((UICollectionView, String, IndexPathOffset) -> UICollectionReusableView)?
    var cells: [CustomCellModel]
}

extension UICollectionView {

    public func section(
        with cells: [CustomCellModel],
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {

        for cell in cells {
            cell.register(self)
        }

        let section = CustomSectionSource(cells: cells)
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
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {
        return self.section(with: cells, configure: configure, withDelegate: withDelegate)
    }
}

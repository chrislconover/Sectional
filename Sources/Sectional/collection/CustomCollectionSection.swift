//
//  CustomCollectionSection.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


public struct CustomCellModel {
    init(build: @escaping (UICollectionView, IndexPathOffset) -> UICollectionViewCell,
         sizeForItem: ((UICollectionView, IndexPath) -> CGSize)? = nil,
         shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
         didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil,
         shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
         didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil) {
        self.build = build
        self.sizeForItem = sizeForItem
        self.shouldSelectItemAt = shouldSelectItemAt
        self.didSelectItemAt = didSelectItemAt
        self.shouldDeselectItemAt = shouldDeselectItemAt
        self.didDeselectItemAt = didDeselectItemAt
    }

    var build: (UICollectionView, IndexPathOffset) -> UICollectionViewCell
    var sizeForItem: ((UICollectionView, IndexPath) -> CGSize)?
    var shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    var shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?

    static func cell(
        build: @escaping (UICollectionView, IndexPathOffset) -> UICollectionViewCell,
        sizeForItem: ((UICollectionView, IndexPath) -> CGSize)? = nil,
        shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
        didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil,
        shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? = nil,
        didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? = nil) -> CustomCellModel {
        return CustomCellModel(
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

    public var baseOffset: IndexPath = IndexPath()
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

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
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

    public func dataSource(
        with cells: [CustomCellModel],
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {

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

    public func dataSource(
        with cells: CustomCellModel...,
        configure: ((CustomSectionSource, UICollectionView) -> Void)? = nil,
        withDelegate: ((CustomSectionSource, CollectionViewSectionDelegate) -> Void)? = nil) -> CustomSectionSource {
        return self.dataSource(with: cells, configure: configure, withDelegate: withDelegate)
    }
}

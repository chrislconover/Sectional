//
//  ModularCollectionView.swift
//  Curious Applications
//
//  Created by Chris Conover on 11/27/17.
//  Copyright © 2017 Curious Applications. All rights reserved.
//

import UIKit
import Differ // for query source
import RxSwift


protocol DataSection {

}

struct IndexPathOffset {
    var absolute: IndexPath
    var inSection: IndexPath
}

protocol CollectionOffset: class {
    var baseOffset: IndexPath { get set }
    var totalSections: () -> Int { get set }
    var rebase: () -> Void { get set }
    func relativePathFrom(absolute: IndexPath) -> IndexPath
    func absolutePathFrom(relative: IndexPath) -> IndexPath
    func pathOffset(absolute: IndexPath) -> IndexPathOffset
}


extension CollectionOffset {
    func relativePathFrom(absolute: IndexPath) -> IndexPath {
        return IndexPath(row: absolute.row, section: absolute.section - baseOffset.section)
    }

    func absolutePathFrom(relative: IndexPath) -> IndexPath {
        return IndexPath(
            row: relative.row,
            section: baseOffset.section + relative.section)
    }

    func pathOffset(absolute: IndexPath) -> IndexPathOffset {
        return IndexPathOffset(absolute: absolute, inSection: absolute.relativeTo(baseOffset))
    }
}


protocol CollectionViewSectionDataSource: UICollectionViewDataSource, CollectionOffset {}
protocol CollectionViewNestedDelegateType: UICollectionViewDelegateFlowLayout, CollectionOffset {}

protocol CollectionViewCompositeConfiguration {
    var dataSource: CompositeCollectionDataSource { get }
    var delegate: CollectionViewCompositeDelegate? { get }
}

protocol CollectionViewNestedConfiguration {
    var dataSource: CollectionViewSectionDataSource { get }
    var delegate: CollectionViewNestedDelegateType? { get }
}




protocol CollectionViewDelegateOverride: CollectionViewNestedDelegateType {

    var shouldHighlightItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? { get }
    var didHighlightItemAt: ((UICollectionView, IndexPathOffset) -> Void)? { get }
    var didUnhighlightItemAt: ((UICollectionView, IndexPathOffset) -> Void)? { get }

    var shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?  { get }
    var shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? { get }

    var didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? { get }
    var didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)? { get }

    var willDisplay: ((UICollectionView, UICollectionViewCell, IndexPathOffset) -> Void)? { get }
    var willDisplaySupplementaryView: ((UICollectionView, UICollectionReusableView, String, IndexPathOffset) -> Void)? { get }
    var didEndDisplaying: ((UICollectionView, UICollectionViewCell, IndexPathOffset) -> Void)? { get }
    var didEndDisplayingSupplementaryView: ((UICollectionView, UICollectionReusableView, String, IndexPathOffset) -> Void)? { get }

    var shouldShowMenuForItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? { get }
    var canPerformAction: ((UICollectionView, Selector, IndexPathOffset, Any?) -> Bool)? { get }
    var performAction: ((UICollectionView, Selector, IndexPathOffset, Any?) -> Void)? { get }

    // Focus
    var canFocusItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? { get }

    var targetIndexPathForMoveFromItemAt: ((UICollectionView, IndexPathOffset, IndexPathOffset) -> IndexPath)? { get }

    var shouldSpringLoadItemAt: ((UICollectionView, IndexPathOffset, UISpringLoadedInteractionContext) -> Bool)? { get }
}















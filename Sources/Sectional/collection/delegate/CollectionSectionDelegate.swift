//
//  CollectionSectionDataSourceDelegate.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


public class CollectionViewSectionDelegate: NSObject,  CollectionViewNestedDelegateType {

    static func with(configure: (CollectionViewSectionDelegate) -> Void) -> CollectionViewSectionDelegate {
        let delegate = CollectionViewSectionDelegate()
        configure(delegate)
        return delegate
    }

    public var baseOffset: IndexPath = IndexPath(item: 0, section: 0)
    public var rebase: () -> Void = {}
    public var totalSections: () -> Int = { 1 }

    public var shouldHighlightItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    public var didHighlightItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    public var didUnhighlightItemAt: ((UICollectionView, IndexPathOffset) -> Void)?

    public var shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    public var shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? // called when the user taps on an already-selected item in multi-select mode
    public var didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    public var didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?

    public var willDisplay: ((UICollectionView, UICollectionViewCell, IndexPathOffset) -> Void)?
    public var willDisplaySupplementaryView: ((UICollectionView, UICollectionReusableView, String, IndexPathOffset) -> Void)?
    public var didEndDisplaying: ((UICollectionView, UICollectionViewCell, IndexPathOffset) -> Void)?
    public var didEndDisplayingSupplementaryView: ((UICollectionView, UICollectionReusableView, String, IndexPathOffset) -> Void)?

    public var shouldShowMenuForItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    public var canPerformAction: ((UICollectionView, Selector, IndexPathOffset, Any?) -> Bool)?
    public var performAction: ((UICollectionView, Selector, IndexPathOffset, Any?) -> Void)?

    // Focus
    public var canFocusItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? {
        didSet { supportedSelectors[.canFocusItemAt] = true }}
    
    public var shouldUpdateFocusIn: ((UICollectionView, UICollectionViewFocusUpdateContext) -> Bool)? {
        didSet { supportedSelectors[.shouldUpdateFocusIn] = true }}
    
    public var didUpdateFocusIn: ((UICollectionView, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void)? {
        didSet { supportedSelectors[.didUpdateFocusIn] = true }}
    
    public var targetIndexPathForMoveFromItemAt: ((UICollectionView, IndexPathOffset, IndexPathOffset) -> IndexPath)? {
        didSet { supportedSelectors[.targetIndexPathForMoveFromItemAt] = true }}
    
    public var shouldSpringLoadItemAt: ((UICollectionView, IndexPathOffset, UISpringLoadedInteractionContext) -> Bool)? {
        didSet { supportedSelectors[.shouldSpringLoadItemAt] = true }}
    
    // UICollectionViewDelegateFlowLayout
    public var sizeForItemWithLayoutAt: ((UICollectionView, UICollectionViewLayout, IndexPathOffset) -> CGSize)? {
        didSet { supportedSelectors[.sizeForItemAt] = true }}

    public var insetForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)? {
        didSet { supportedSelectors[.insetForSectionAt] = true }}

    public var minimumLineSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)? {
        didSet { supportedSelectors[.minimumLineSpacingForSectionAt] = true }}

    public var minimumInteritemSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)? {
        didSet { supportedSelectors[.minimumInteritemSpacingForSectionAt] = true }}

    public var referenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? {
        didSet { supportedSelectors[.referenceSizeForHeaderInSection] = true }}

    public var referenceSizeForFooterInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? {
        didSet { supportedSelectors[.referenceSizeForFooterInSection] = true }}

    private var supportedSelectors: [Selector: Bool] = [
        .sizeForItemAt: false,
        .insetForSectionAt: false,
        .minimumLineSpacingForSectionAt: false,
        .minimumInteritemSpacingForSectionAt: false,
        .referenceSizeForHeaderInSection: false,
        .referenceSizeForFooterInSection: false
    ]
}

extension CollectionViewSectionDelegate {

    // MARK: highlighting
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldHighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        didHighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) }
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        didUnhighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) }

    // MARK: selection
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return shouldSelectItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return shouldDeselectItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt?(collectionView, pathOffset(absolute: indexPath)) }
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectItemAt?(collectionView, pathOffset(absolute: indexPath)) }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplay?(collectionView, cell, pathOffset(absolute: indexPath)) }
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        willDisplaySupplementaryView?(collectionView, view, elementKind, pathOffset(absolute: indexPath)) }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        didEndDisplaying?(collectionView, cell, pathOffset(absolute: indexPath)) }
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        didEndDisplayingSupplementaryView?(collectionView, view, elementKind, pathOffset(absolute: indexPath)) }


    // These methods provide support for copy/paste actions on cells.
    // All three should be implemented if any are.
    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return shouldShowMenuForItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return canPerformAction?(collectionView, action, pathOffset(absolute: indexPath), sender) ?? false
    }
    
    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        performAction?(collectionView, action, pathOffset(absolute: indexPath), sender)
    }

    // Focus
    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        canFocusItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    public func collectionView(_ collectionView: UICollectionView,
                               shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        shouldUpdateFocusIn!(collectionView, context)
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                               with coordinator: UIFocusAnimationCoordinator) {
        didUpdateFocusIn!(collectionView, context, coordinator)
    }
        
    public func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return targetIndexPathForMoveFromItemAt?(collectionView,
                                                 pathOffset(absolute: originalIndexPath),
                                                 pathOffset(absolute: proposedIndexPath))
            ?? proposedIndexPath
    }

    // Spring Loading
    public func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return shouldSpringLoadItemAt?(collectionView, pathOffset(absolute: indexPath), context) ?? true
    }
}


extension CollectionViewSectionDelegate: UICollectionViewDelegateFlowLayout {

    override public func responds(to aSelector: Selector!) -> Bool {
        return supportedSelectors[aSelector] ?? super.responds(to: aSelector)
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        sizeForItemWithLayoutAt!(collectionView, collectionViewLayout, pathOffset(absolute: indexPath))
    }
    
    @objc public func collectionView(_ collectionView: UICollectionView,
                                     layout collectionViewLayout: UICollectionViewLayout,
                                     insetForSectionAt section: Int) -> UIEdgeInsets {
        insetForSectionAt!(collectionView, collectionViewLayout, section)
    }

    @objc public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        minimumLineSpacingForSectionAt!(collectionView, collectionViewLayout, section)
    }

    @objc public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        minimumInteritemSpacingForSectionAt!(collectionView, collectionViewLayout, section)
    }

    @objc public func collectionView(_ collectionView: UICollectionView,
                              layout collectionViewLayout: UICollectionViewLayout,
                              referenceSizeForHeaderInSection section: Int) -> CGSize {
        referenceSizeForHeaderInSection?(collectionView, collectionViewLayout, section) ?? .zero
    }

    @objc public func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        referenceSizeForFooterInSection?(collectionView, collectionViewLayout, section) ?? .zero
    }
}

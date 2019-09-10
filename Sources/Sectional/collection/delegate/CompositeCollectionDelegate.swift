//
//  CompositeCollectionDelegate.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


// MARK: UICollectionViewDelegate

class CollectionViewCompositeDelegate: NSObject, CollectionOffset, UICollectionViewDelegate {

    var baseOffset: IndexPath = IndexPath(item: 0, section: 0)
    var rebase: () -> Void = {}
    var totalSections: () -> Int = { 0 }

    var shouldHighlightItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var didHighlightItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    var didUnhighlightItemAt: ((UICollectionView, IndexPathOffset) -> Void)?

    var shouldSelectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var shouldDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Bool)? // called when the user taps on an already-selected item in multi-select mode
    var didSelectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?
    var didDeselectItemAt: ((UICollectionView, IndexPathOffset) -> Void)?

    var willDisplay: ((UICollectionView, UICollectionViewCell, IndexPathOffset) -> Void)?
    var willDisplaySupplementaryView: ((UICollectionView, UICollectionReusableView, String, IndexPathOffset) -> Void)?
    var didEndDisplaying: ((UICollectionView, UICollectionViewCell, IndexPathOffset) -> Void)?
    var didEndDisplayingSupplementaryView: ((UICollectionView, UICollectionReusableView, String, IndexPathOffset) -> Void)?

    var shouldShowMenuForItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var canPerformAction: ((UICollectionView, Selector, IndexPathOffset, Any?) -> Bool)?
    var performAction: ((UICollectionView, Selector, IndexPathOffset, Any?) -> Void)?

    // support for custom transition layout
    var transitionLayoutForOldLayout: ((UICollectionView, UICollectionViewLayout, UICollectionViewLayout) -> UICollectionViewTransitionLayout)?

    // Focus
    var canFocusItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?
    var shouldUpdateFocusIn: ((UICollectionView, UICollectionViewFocusUpdateContext) -> Bool)?
    var didUpdateFocusIn: ((UICollectionView, UICollectionViewFocusUpdateContext, UIFocusAnimationCoordinator) -> Void)?
    var indexPathForPreferredFocusedView: ((UICollectionView) -> IndexPath?)?

    var targetIndexPathForMoveFromItemAt: ((UICollectionView, IndexPath, IndexPath) -> IndexPath)?
    var targetContentOffsetForProposedContentOffset: ((UICollectionView, CGPoint) -> CGPoint)?

    var shouldSpringLoadItemAt: ((UICollectionView, IndexPathOffset, UISpringLoadedInteractionContext) -> Bool)?


    // UICollectionViewDelegateFlowLayout
    var sizeForItemWithLayoutAt: ((UICollectionView, UICollectionViewLayout, IndexPath) -> CGSize)? {
        didSet { supportedSelectors[Selector.sizeForItemAt] = true }
    }

    var insetForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)? {
        didSet { supportedSelectors[.insetForSectionAt] = true }
    }

    var minimumLineSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)? {
        didSet { supportedSelectors[.minimumLineSpacingForSectionAt] = true }
    }

    var minimumInteritemSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)? {
        didSet { supportedSelectors[.minimumInteritemSpacingForSectionAt] = true }
    }

    var referenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? {
        didSet { supportedSelectors[.referenceSizeForHeaderInSection] = true }
    }

    var referenceSizeForFooterInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? {
        didSet { supportedSelectors[.referenceSizeForFooterInSection] = true }
    }

    // MARK: highlighting
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return behavior(indexPath)?.collectionView?(collectionView, shouldHighlightItemAt: indexPath)
            ?? shouldHighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, didHighlightItemAt: indexPath)
            ?? didHighlightItemAt?(collectionView, pathOffset(absolute: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, didUnhighlightItemAt: indexPath)
            ?? didUnhighlightItemAt?(collectionView, pathOffset(absolute: indexPath))
    }


    // MARK: selection
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return behavior(indexPath)?.collectionView?(collectionView, shouldSelectItemAt: indexPath)
            ?? shouldSelectItemAt?(collectionView, pathOffset(absolute: indexPath))
            ?? true
    }

    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return behavior(indexPath)?.collectionView?(collectionView, shouldDeselectItemAt: indexPath)
            ?? shouldDeselectItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, didSelectItemAt: indexPath)
            ?? didSelectItemAt?(collectionView, pathOffset(absolute: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, didDeselectItemAt: indexPath)
            ?? didDeselectItemAt?(collectionView, pathOffset(absolute: indexPath))
    }

    // MARK: display
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
            ?? willDisplay?(collectionView, cell, pathOffset(absolute: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
            ?? willDisplaySupplementaryView?(collectionView, view, elementKind, pathOffset(absolute: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
            ?? didEndDisplaying?(collectionView, cell, pathOffset(absolute: indexPath))
    }

    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        behavior(indexPath)?.collectionView?(collectionView, didEndDisplayingSupplementaryView: view,
                                             forElementOfKind: elementKind, at: indexPath)
            ?? didEndDisplayingSupplementaryView?(collectionView, view, elementKind, pathOffset(absolute: indexPath))
    }

    // MARK: copy / paste
    // These methods provide support for copy/paste actions on cells.
    // All three should be implemented if any are.
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return behavior(indexPath)?.collectionView?(collectionView, shouldShowMenuForItemAt: indexPath)
            ?? shouldShowMenuForItemAt?(collectionView, pathOffset(absolute: indexPath))
            ?? false
    }

    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector,
                        forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return behavior(indexPath)?.collectionView?(
            collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
            ?? canPerformAction?(collectionView, action, pathOffset(absolute: indexPath), sender)
            ?? false
    }

    func collectionView(_ collectionView: UICollectionView, performAction action: Selector,
                        forItemAt indexPath: IndexPath, withSender sender: Any?) {
        behavior(indexPath)?.collectionView?(collectionView, performAction: action,
                                             forItemAt: indexPath, withSender: sender)
            ?? performAction?(collectionView, action, pathOffset(absolute: indexPath), sender)
    }

    // MARK: support for custom transition layout
    func collectionView(_ collectionView: UICollectionView,
                        transitionLayoutForOldLayout fromLayout: UICollectionViewLayout,
                        newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
        return transitionLayoutForOldLayout?(collectionView, fromLayout, toLayout)
            ?? UICollectionViewTransitionLayout(currentLayout: fromLayout, nextLayout: toLayout)
    }

    // MARK: focus
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return behavior(indexPath)?.collectionView?(collectionView, canFocusItemAt: indexPath)
            ?? canFocusItemAt?(collectionView, pathOffset(absolute: indexPath))
            ?? true
    }

    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return shouldUpdateFocusIn?(collectionView, context) ?? true }

    func collectionView(_ collectionView: UICollectionView,
                        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                        with coordinator: UIFocusAnimationCoordinator) {
        didUpdateFocusIn?(collectionView, context, coordinator)
    }

    func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
        guard let indexPathForPreferredFocusedView = indexPathForPreferredFocusedView else {
            fatalError("implement if remembersLastFocusedIndex is false") }
        return indexPathForPreferredFocusedView(collectionView)
    }

    // MARK: moving cell
    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {

        let ourCollectionLevelBehavior:() -> IndexPath = { [unowned self] in
            return self.targetIndexPathForMoveFromItemAt?(
                collectionView, originalIndexPath, proposedIndexPath)
                ?? proposedIndexPath }

        // if move is within the same section
        if let fromSection = behavior(originalIndexPath),
            let sameSection = behavior(proposedIndexPath),
            fromSection === sameSection {
            return sameSection.collectionView?(collectionView,
                                               targetIndexPathForMoveFromItemAt: originalIndexPath,
                                               toProposedIndexPath: proposedIndexPath)
                ?? ourCollectionLevelBehavior()
        }

        return ourCollectionLevelBehavior()
    }

    // customize the content offset to be applied during transition or update animations
    func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        return targetContentOffsetForProposedContentOffset?(collectionView, proposedContentOffset) ?? proposedContentOffset
    }

    // Spring Loading
    func collectionView(_ collectionView: UICollectionView,
                        shouldSpringLoadItemAt indexPath: IndexPath,
                        with context: UISpringLoadedInteractionContext) -> Bool {
        return behavior(indexPath)?.collectionView?(
            collectionView, shouldSpringLoadItemAt: indexPath, with: context)
            ?? shouldSpringLoadItemAt?(collectionView, pathOffset(absolute: indexPath), context)
            ?? true
    }

    internal init(collectionView: UICollectionView,
         models: [CollectionViewNestedConfiguration]) {
        self.collectionView = collectionView
        self.models = models
        super.init()
        configure()
    }

    func configure() {
        var totalSections = 0
        for model in models {
            let sectionsInModel = model.dataSource.numberOfSections?(in: collectionView) ?? 0
            guard let delegate = model.delegate else {
                totalSections += sectionsInModel
                continue
            }
            
            delegate.baseOffset = IndexPath(row: 0, section: totalSections)
            delegate.totalSections = { totalSections /* final total */ }
            delegate.rebase = configure

            for section in totalSections ..< totalSections + sectionsInModel {
                self.behaviors[section] = delegate // add index for this section
            }

            for selector in Selector.flowLayoutDelegate {
                // if any delegate supports a given selector
                if delegate.responds(to: selector) {
                    // then we must declare support
                    supportedSelectors[selector] = true
                }
            }

            totalSections += sectionsInModel
        }

        supportedSelectors[Selector.sizeForItemAt] =
            supportedSelectors[Selector.sizeForItemAt] ?? false
            || behaviors.contains { _, delegate in delegate.responds(to: Selector.sizeForItemAt) }
            || false
    }

    private func behavior(_ path: IndexPath) -> UICollectionViewDelegateFlowLayout? {
        return behaviors[path.section] ?? defaultBehavior
    }

    private func behavior(_ section: Int) -> UICollectionViewDelegateFlowLayout? {
        return behaviors[section] ?? defaultBehavior
    }

    // default selector support to false
    private var supportedSelectors: [Selector: Bool] =
        Dictionary(Selector.flowLayoutDelegate.map { ($0, false) },
                   uniquingKeysWith: { $1 })

    var defaultBehavior: UICollectionViewDelegateFlowLayout?
    private var behaviors = [Int: CollectionViewNestedDelegateType]()
    private var models = [CollectionViewNestedConfiguration]()
    private unowned var collectionView: UICollectionView
}

extension Selector {

    static let indexTitles =
        #selector(UICollectionViewDataSource.indexTitles(for:))

    static let indexPathForIndexTitleAt =
        #selector(UICollectionViewDataSource.collectionView(_:indexPathForIndexTitle:at:))

    static let sizeForItemAt =
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))

    static let insetForSectionAt =
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:insetForSectionAt:))

    static let minimumLineSpacingForSectionAt =
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumLineSpacingForSectionAt:))

    static let minimumInteritemSpacingForSectionAt =
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:minimumInteritemSpacingForSectionAt:))

    static let referenceSizeForHeaderInSection =
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForHeaderInSection:))

    static let referenceSizeForFooterInSection =
        #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:referenceSizeForFooterInSection:))

    static var flowLayoutDelegate: [Selector] {
        return [ sizeForItemAt,
                 insetForSectionAt,
                 minimumLineSpacingForSectionAt,
                 minimumInteritemSpacingForSectionAt,
                 referenceSizeForHeaderInSection,
                 referenceSizeForFooterInSection ]
    }
}


extension CollectionViewCompositeDelegate {
    override func responds(to aSelector: Selector!) -> Bool {
        return supportedSelectors[aSelector] ?? super.responds(to: aSelector)
    }
}


extension CollectionViewCompositeDelegate: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let error: () -> CGSize = { fatalError("If any section implements \(Selector.sizeForItemAt), it must be handled for all cases") }
        return behavior(indexPath)?
            .collectionView?(collectionView, layout: collectionViewLayout, sizeForItemAt: indexPath)
            ?? sizeForItemWithLayoutAt?(collectionView, collectionViewLayout, indexPath)
            ?? error()
    }

    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               insetForSectionAt section: Int) -> UIEdgeInsets {
        let error: () -> UIEdgeInsets = {
            fatalError("If any section implements \(Selector.insetForSectionAt), it must be handled for all cases")
        }
        return behavior(section)?
            .collectionView?(collectionView, layout: collectionViewLayout, insetForSectionAt: section)
            ?? insetForSectionAt?(collectionView, collectionViewLayout, section)
            ?? error()
    }

    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        let error: () -> CGFloat = { fatalError("If any section implements \(Selector.minimumLineSpacingForSectionAt), it must be handled for all cases") }
        return behavior(section)?
            .collectionView?(collectionView, layout: collectionViewLayout, minimumLineSpacingForSectionAt: section)
            ?? minimumLineSpacingForSectionAt?(collectionView, collectionViewLayout, section)
            ?? error()
    }


    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        let error: () -> CGFloat = { fatalError("If any section implements \(Selector.minimumInteritemSpacingForSectionAt), it must be handled for all cases") }
        return behavior(section)?
            .collectionView?(collectionView, layout: collectionViewLayout, minimumInteritemSpacingForSectionAt: section)
            ?? minimumInteritemSpacingForSectionAt?(collectionView, collectionViewLayout, section)
            ?? error()
    }


    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let error: () -> CGSize = { fatalError("If any section implements \(Selector.referenceSizeForHeaderInSection), it must be handled for all cases") }
        return behavior(section)?
            .collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForHeaderInSection: section)
            ?? referenceSizeForHeaderInSection?(collectionView, collectionViewLayout, section)
            ?? error()
    }


    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        let error: () -> CGSize = { fatalError("If any section implements \(Selector.referenceSizeForFooterInSection), it must be handled for all cases") }
        return behavior(section)?
            .collectionView?(collectionView, layout: collectionViewLayout, referenceSizeForFooterInSection: section)
            ?? referenceSizeForFooterInSection?(collectionView, collectionViewLayout, section)
            ?? error()
    }
}
//
//  CollectionSectionDataSourceDelegate.swift
//  Curious Applications
//
//  Created by Chris Conover on 9/17/18.
//

import UIKit


class CollectionViewSectionDelegate: NSObject,  CollectionViewNestedDelegateType {

    static func with(configure: (CollectionViewSectionDelegate) -> Void) -> CollectionViewSectionDelegate {
        let delegate = CollectionViewSectionDelegate()
        configure(delegate)
        return delegate
    }

    var baseOffset: IndexPath = IndexPath(item: 0, section: 0)
    var rebase: () -> Void = {}
    var totalSections: () -> Int = { 1 }

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

    // Focus
    var canFocusItemAt: ((UICollectionView, IndexPathOffset) -> Bool)?

    var targetIndexPathForMoveFromItemAt: ((UICollectionView, IndexPathOffset, IndexPathOffset) -> IndexPath)?

    var shouldSpringLoadItemAt: ((UICollectionView, IndexPathOffset, UISpringLoadedInteractionContext) -> Bool)?

    // UICollectionViewDelegateFlowLayout
    var sizeForItemWithLayoutAt: ((UICollectionView, UICollectionViewLayout, IndexPathOffset) -> CGSize)? {
        didSet { supportedSelectors[.sizeForItemAt] = true }}

    var insetForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> UIEdgeInsets)? {
        didSet { supportedSelectors[.insetForSectionAt] = true }}

    var minimumLineSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)? {
        didSet { supportedSelectors[.minimumLineSpacingForSectionAt] = true }}

    var minimumInteritemSpacingForSectionAt: ((UICollectionView, UICollectionViewLayout, Int) -> CGFloat)? {
        didSet { supportedSelectors[.minimumInteritemSpacingForSectionAt] = true }}

    var referenceSizeForHeaderInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? {
        didSet { supportedSelectors[.referenceSizeForHeaderInSection] = true }}

    var referenceSizeForFooterInSection: ((UICollectionView, UICollectionViewLayout, Int) -> CGSize)? {
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
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return shouldHighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        didHighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) }
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        didUnhighlightItemAt?(collectionView, pathOffset(absolute: indexPath)) }

    // MARK: selection
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return shouldSelectItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return shouldDeselectItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItemAt?(collectionView, pathOffset(absolute: indexPath)) }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        didDeselectItemAt?(collectionView, pathOffset(absolute: indexPath)) }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        willDisplay?(collectionView, cell, pathOffset(absolute: indexPath)) }
    func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        willDisplaySupplementaryView?(collectionView, view, elementKind, pathOffset(absolute: indexPath)) }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        didEndDisplaying?(collectionView, cell, pathOffset(absolute: indexPath)) }
    func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        didEndDisplayingSupplementaryView?(collectionView, view, elementKind, pathOffset(absolute: indexPath)) }


    // These methods provide support for copy/paste actions on cells.
    // All three should be implemented if any are.
    func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return shouldShowMenuForItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? false }
    func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return canPerformAction?(collectionView, action, pathOffset(absolute: indexPath), sender) ?? false }
    func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        performAction?(collectionView, action, pathOffset(absolute: indexPath), sender) }

    // Focus
    func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
        return canFocusItemAt?(collectionView, pathOffset(absolute: indexPath)) ?? true }

    func collectionView(_ collectionView: UICollectionView,
                        targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath,
                        toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        return targetIndexPathForMoveFromItemAt?(collectionView,
                                                 pathOffset(absolute: originalIndexPath),
                                                 pathOffset(absolute: proposedIndexPath))
            ?? proposedIndexPath
    }

    // Spring Loading
    func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool {
        return shouldSpringLoadItemAt?(collectionView, pathOffset(absolute: indexPath), context) ?? true
    }
}


extension CollectionViewSectionDelegate: UICollectionViewDelegateFlowLayout {

    override func responds(to aSelector: Selector!) -> Bool {
        return supportedSelectors[aSelector] ?? super.responds(to: aSelector)
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        return sizeForItemWithLayoutAt!(collectionView, collectionViewLayout, pathOffset(absolute: indexPath))
    }
}

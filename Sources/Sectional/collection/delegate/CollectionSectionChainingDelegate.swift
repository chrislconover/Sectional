//
//  DelegatingCollectionDelegate.swift
//  Differ
//
//  Created by Chris Conover on 7/31/20.
//

import UIKit


public class CollectionSectionDefaultDelegate: CollectionViewSectionDelegate {
    
    override public func responds(to aSelector: Selector!) -> Bool {
        overridingDelegate.responds(to: aSelector) || super.responds(to: aSelector)
    }

    // MARK: highlighting
    override public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        overridingDelegate.collectionView?(collectionView, shouldHighlightItemAt: indexPath)
            ?? super.collectionView(collectionView, shouldHighlightItemAt: indexPath)
    }
    
    override public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, didHighlightItemAt: indexPath)
            ?? super.collectionView(collectionView, didHighlightItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, didUnhighlightItemAt: indexPath)
            ?? super.collectionView(collectionView, didUnhighlightItemAt: indexPath)
    }


    // MARK: selection
    public override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        overridingDelegate.collectionView?(collectionView, shouldSelectItemAt: indexPath)
            ?? super.collectionView(collectionView, shouldSelectItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        overridingDelegate.collectionView?(collectionView, shouldDeselectItemAt: indexPath)
            ?? super.collectionView(collectionView, shouldDeselectItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, didSelectItemAt: indexPath)
            ?? super.collectionView(collectionView, didSelectItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, didDeselectItemAt: indexPath)
            ?? super.collectionView(collectionView, didDeselectItemAt: indexPath)
    }

    // MARK: display
    public override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, willDisplay: cell, forItemAt: indexPath)
            ?? super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
            ?? super.collectionView(collectionView, willDisplaySupplementaryView: view, forElementKind: elementKind, at: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
            ?? super.collectionView(collectionView, didEndDisplaying: cell, forItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView,
                                        didEndDisplayingSupplementaryView view: UICollectionReusableView,
                                        forElementOfKind elementKind: String,
                                        at indexPath: IndexPath) {
        overridingDelegate.collectionView?(collectionView,
                                           didEndDisplayingSupplementaryView: view,
                                           forElementOfKind: elementKind, at: indexPath)
            ?? super.collectionView(collectionView,
                                    didEndDisplayingSupplementaryView: view,
                                    forElementOfKind: elementKind,
                                    at: indexPath)
    }

    // MARK: copy / paste
    // These methods provide support for copy/paste actions on cells.
    // All three should be implemented if any are.
    public override func collectionView(_ collectionView: UICollectionView,
                                        shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        overridingDelegate.collectionView?(collectionView, shouldShowMenuForItemAt: indexPath)
            ?? super.collectionView(collectionView, shouldShowMenuForItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView,
                                        canPerformAction action: Selector,
                                        forItemAt indexPath: IndexPath,
                                        withSender sender: Any?) -> Bool {
        overridingDelegate.collectionView?(collectionView, canPerformAction: action,
                                           forItemAt: indexPath, withSender: sender)
            ?? super.collectionView(collectionView, canPerformAction: action,
                                    forItemAt: indexPath, withSender: sender)
    }

    public override func collectionView(_ collectionView: UICollectionView,
                                        performAction action: Selector,
                                        forItemAt indexPath: IndexPath,
                                        withSender sender: Any?) {
        overridingDelegate.collectionView?(collectionView, performAction: action,
                                           forItemAt: indexPath, withSender: sender)
            ?? super.collectionView(collectionView, performAction: action,
                                    forItemAt: indexPath, withSender: sender)
    }

    // MARK: focus
    public override func collectionView(_ collectionView: UICollectionView,
                                        canFocusItemAt indexPath: IndexPath) -> Bool {
        overridingDelegate.collectionView?(collectionView, canFocusItemAt: indexPath)
            ?? super.collectionView(collectionView, canFocusItemAt: indexPath)
    }

    public override func collectionView(_ collectionView: UICollectionView,
                                        shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        overridingDelegate.collectionView?(collectionView, shouldUpdateFocusIn: context)
            ?? super.collectionView(collectionView, shouldUpdateFocusIn: context)
    }

    public override func collectionView(_ collectionView: UICollectionView,
                        didUpdateFocusIn context: UICollectionViewFocusUpdateContext,
                        with coordinator: UIFocusAnimationCoordinator) {
        overridingDelegate.collectionView?(collectionView, didUpdateFocusIn: context, with: coordinator)
            ?? super.collectionView(collectionView, didUpdateFocusIn: context, with: coordinator)
    }

    // Spring Loading
    public override func collectionView(_ collectionView: UICollectionView,
                                        shouldSpringLoadItemAt indexPath: IndexPath,
                                        with context: UISpringLoadedInteractionContext) -> Bool {
        overridingDelegate.collectionView?(collectionView, shouldSpringLoadItemAt: indexPath, with: context)
            ?? super.collectionView(collectionView, shouldSpringLoadItemAt: indexPath, with: context)
    }
    
    // UICollectionViewDelegateFlowLayout
    public override func collectionView(_ collectionView: UICollectionView,
                                        layout: UICollectionViewLayout,
                                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        overridingDelegate.collectionView?(collectionView, layout: layout, sizeForItemAt: indexPath)
            ?? super.collectionView(collectionView, layout: layout, sizeForItemAt: indexPath)
    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        layout: UICollectionViewLayout,
                                        insetForSectionAt section: Int) -> UIEdgeInsets {
        overridingDelegate.collectionView?(collectionView, layout: layout, insetForSectionAt: section)
            ?? super.collectionView(collectionView, layout: layout, insetForSectionAt: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        layout: UICollectionViewLayout,
                                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        overridingDelegate.collectionView?(collectionView, layout: layout, minimumLineSpacingForSectionAt: section)
            ?? super.collectionView(collectionView, layout: layout, minimumLineSpacingForSectionAt: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        layout: UICollectionViewLayout,
                                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        overridingDelegate.collectionView?(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section)
            ?? super.collectionView(collectionView, layout: layout, minimumInteritemSpacingForSectionAt: section)
    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        layout: UICollectionViewLayout,
                                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        overridingDelegate.collectionView?(collectionView, layout: layout, referenceSizeForHeaderInSection: section)
            ?? super.collectionView(collectionView, layout: layout, referenceSizeForHeaderInSection: section)

    }
    
    public override func collectionView(_ collectionView: UICollectionView,
                                        layout: UICollectionViewLayout,
                                        referenceSizeForFooterInSection section: Int) -> CGSize {
        overridingDelegate.collectionView?(collectionView, layout: layout, referenceSizeForFooterInSection: section)
            ?? super.collectionView(collectionView, layout: layout, referenceSizeForFooterInSection: section)

    }

    internal init(withOverridingDelegate: UICollectionViewDelegateFlowLayout) {
        self.overridingDelegate = withOverridingDelegate
        super.init()
    }

    var overridingDelegate: UICollectionViewDelegateFlowLayout
}

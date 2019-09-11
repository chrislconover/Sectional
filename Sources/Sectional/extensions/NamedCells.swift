//
//  NamedCells.swift
//  Sectional
//
//  Created by Chris Conover on 12/1/17.
//  Copyright © 2017 Methodist Le Bonheur Healthcare. All rights reserved.
//

import UIKit


protocol NamedCell {
    static var name: String { get }
}

extension UICollectionReusableView: NamedCell {}
extension NamedCell where Self: UITableViewCell {
    static var name: String { return String(describing: Self.self) }
}

extension UITableViewCell: NamedCell {}
extension NamedCell where Self: UICollectionReusableView {
    static var name: String { return String(describing: Self.self) }
}

extension UICollectionView {

    func register<T:UICollectionViewCell>(_ t: T.Type) {
        register(t.self, forCellWithReuseIdentifier: t.name)
    }

    func registerHeader<T:UICollectionReusableView>(_ t: T.Type) {
        self.register(
            t.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: t.name)
    }

    func registerFooter<T:UICollectionReusableView>(_ t: T.Type) {
        self.register(
            t.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: t.name)
    }

    func register<T:UICollectionReusableView>(_ t: T.Type, kind: String) {
        self.register(t.self, forSupplementaryViewOfKind: kind, withReuseIdentifier: t.name)
    }

    func cell<T:UICollectionViewCell>(_ type: T.Type = T.self, at path: IndexPath) -> T? {
        let cell = cellForItem(at: path) as? T
        assert(cell != nil)
        return cell
    }

    func cell<T:UICollectionViewCell>(_ type: T.Type = T.self, at path: IndexPathOffset) -> T? {
        return cell(type, at: path.absolute)
    }

    func dequeue<T:UICollectionViewCell>(_ type: T.Type = T.self, for path: IndexPath) -> T {
        return dequeueReusableCell(withReuseIdentifier: T.name, for: path) as! T
    }

    func dequeue<T:UICollectionReusableView>(_ type: T.Type = T.self, ofKind kind: String,
                                                for path: IndexPath) -> T {
        return dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: T.name, for: path) as! T
    }
}

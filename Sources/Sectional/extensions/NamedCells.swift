//
//  NamedCells.swift
//  Sectional
//
//  Created by Chris Conover on 12/1/17.
//  Copyright © 2017 Chris Conover. All rights reserved.
//

import UIKit


public protocol NamedCell {
    static var name: String { get }
}

extension UICollectionReusableView: NamedCell {}
public extension NamedCell where Self: UITableViewCell {
    static var name: String { return String(describing: Self.self) }
}

extension UITableViewCell: NamedCell {}
extension NamedCell where Self: UICollectionReusableView {
    public static var name: String { String(reflecting: Self.self) }
}

public extension UICollectionView {

    func register<T:UICollectionViewCell>(_ t: T.Type) {
        register(t.self, forCellWithReuseIdentifier: t.name)
    }

    func registerHeader<T:UICollectionReusableView>(_ t: T.Type) {
        self.register(t.self, kind: UICollectionView.elementKindSectionHeader)
    }

    func registerFooter<T:UICollectionReusableView>(_ t: T.Type) {
        self.register(t.self, kind: UICollectionView.elementKindSectionFooter)
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
        cell(type, at: path.absolute)
    }

    func dequeue<T:UICollectionViewCell>(_ type: T.Type = T.self, for path: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.name, for: path) as! T
    }

    func dequeue<T:UICollectionReusableView>(_ type: T.Type = T.self, ofKind kind: String,
                                             for path: IndexPath) -> T {
        dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: T.name, for: path) as! T
    }
}

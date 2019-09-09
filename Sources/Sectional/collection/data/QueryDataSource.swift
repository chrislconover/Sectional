//
//  QueryDataSource.swift
//  IQDashboard
//
//  Created by Chris Conover on 12/18/17.
//  Copyright © 2017 Curious Applications. All rights reserved.
//

import Foundation
import RxSwift



class QueryDataSource<T> {

    init(_ source: Observable<[T]>, isEqual: @escaping (T, T) -> Bool) {
        self.source = source
        self.isEqual = isEqual
        self.publishSubject = PublishSubject<[T]>()
        self.diffedOutput = self.publishSubject.asObservable()
            .withDiffsOfPreviousOrInitial(seed: [], isEqual: self.isEqual)
    }

    var onChanged: ((Updates<T>) -> ())? {
        didSet {
            guard let _ = onChanged else { return }
            resetDiff()
        }
    }

    func resetDiff() {
        print("\(#function)")
        lifetimeOfOnChanged = DisposeBag()
        diffedOutput
            .subscribe(onNext: { [unowned self] in self.onChanged?($0)})
            .disposed(by: lifetimeOfOnChanged)
    }

    func commit() -> Bool {
        print("\(#function)")
        guard let _ = onChanged else {
            assert(false, "committing datasource without handler!")
            return false
        }

        lifetimeOfSource = DisposeBag()
        source
            .subscribe(onNext: { [unowned self] updates in
                self.publishSubject.on(.next(updates)) })
            .disposed(by: lifetimeOfSource)
        return true
    }

    var source: Observable<[T]> { didSet { print("\(#function)") }}

    var publishSubject = PublishSubject<[T]>()
    var diffedOutput: Observable<Updates<T>>
    var isEqual: (T, T) -> Bool
    var lifetimeOfOnChanged: DisposeBag!
    var lifetimeOfSource = DisposeBag()
}

extension QueryDataSource where T: Equatable {

    convenience init(_ updates: Observable<[T]>) {
        self.init(updates, isEqual: { $0 == $1 })
    }
}


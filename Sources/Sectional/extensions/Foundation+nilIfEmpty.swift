//
//  Foundation.swift
//  Curious Applications
//
//  Created by Chris Conover on 2/1/18.
//  Copyright © 2018 Curious Applications. All rights reserved.
//

import Foundation

extension String {
    var nilIfEmpty: String? {
        return !isEmpty ? self : nil
    }
}

extension Collection {
    var nilIfEmpty: Self? {
        return !isEmpty ? self : nil
    }
}

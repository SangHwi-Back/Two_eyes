//
//  Data+Extensions.swift
//  iosApp
//
//  Created by SangHwiBack on 4/28/26.
//

import Foundation

extension Data {
    var utf8String: String? {
        String(data: self, encoding: .utf8)
    }
}

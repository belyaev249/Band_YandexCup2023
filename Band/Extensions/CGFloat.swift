//
//  CGFloat.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import Foundation

extension FloatingPoint {
    func bound(l: Self, r: Self, side: (Self) -> Self = { _ in 0 }) -> Self {
        let i = min(max(l, self), r)
        let s = side(abs(self - i))
        return min(max(l - s, self), r + s)
    }
}

extension FloatingPoint {
    var isNegative: Bool {
        self < 0
    }
}

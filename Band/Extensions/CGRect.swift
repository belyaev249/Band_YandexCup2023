//
//  CGRect.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import Foundation

extension CGRect {
    func scaled(by value: CGFloat) -> Self {
        .init(
            x: origin.x - ((width * (value - 1)) / 2),
            y: origin.y - ((height * (value - 1)) / 2),
            width: width * value,
            height: height * value
        )
    }
}

extension CGRect {
    func center() -> CGPoint {
        .init(
            x: origin.x + (width / 2.0),
            y: origin.y + (height / 2.0)
        )
    }
}

extension CGRect {
    init(center: CGPoint, size: CGSize) {
        self.init(
            x: center.x - size.width / 2.0,
            y: center.y - size.height / 2.0,
            width: size.width,
            height: size.height
        )
    }
}

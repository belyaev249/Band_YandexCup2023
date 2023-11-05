//
//  AnimationFunction.swift
//  Band
//
//  Created by Egor on 01.11.2023.
//

import UIKit

struct AnimationFunction {
    let duration: Double
    let timingFunction: CAMediaTimingFunctionName
}

extension AnimationFunction {
    static let immediately = AnimationFunction(duration: 0, timingFunction: .default)
}

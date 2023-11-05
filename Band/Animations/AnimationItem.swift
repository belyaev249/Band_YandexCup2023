//
//  AnimationItem.swift
//  Band
//
//  Created by Egor on 01.11.2023.
//

import UIKit

struct AnimationItem {
    let completion: (() -> Void)?
    let description: AnimationDescription
    let function: AnimationFunction
    init(
        description: AnimationDescription,
        function: AnimationFunction,
        completion: (() -> Void)? = nil
    ) {
        self.description = description
        self.function = function
        self.completion = completion
    }
}

struct AnimationDescription {
    struct AnimationProperties {
        let isRemovedOnCompletion: Bool
        let fillMode: CAMediaTimingFillMode
    }
    let keyPath: String
    let values: [Any]
    let properties: AnimationProperties?
    init(keyPath: String,
         values: [Any],
         properties: AnimationProperties? = AnimationProperties(isRemovedOnCompletion: false, fillMode: .forwards)) {
        self.keyPath = keyPath
        self.values = values
        self.properties = properties
    }
}

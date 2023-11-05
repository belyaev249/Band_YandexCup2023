//
//  Floar.swift
//  Band
//
//  Created by Egor on 05.11.2023.
//

import Foundation

extension Float {
    static func optional<Source>(_ value: Optional<Source>) -> Optional<Float> where Source: BinaryFloatingPoint {
        if let value {
            return Self(value)
        }
        return nil
    }
}

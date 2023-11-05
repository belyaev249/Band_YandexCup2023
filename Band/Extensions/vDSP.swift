//
//  vDSP.swift
//  Band
//
//  Created by Egor on 04.11.2023.
//

import Accelerate

extension vDSP {
    static func linearInterpolate(values: UnsafeBufferPointer<Float>, between lenght: Int) -> [Float] {
        guard !values.isEmpty else { return [] }
        if values.count == 1 { return [values[0] ]}
        var indices: [Float] = Array(repeating: Float(0), count: values.count)
        let d = Float(lenght) / Float(values.count - 1)
        for index in 0..<indices.count {
            indices[index] = Float(index) * d
        }
        return vDSP.linearInterpolate(values: values, atIndices: indices)
    }
    static func linearInterpolate(values: [Float], between lenght: Int) -> [Float] {
        guard !values.isEmpty else { return [] }
        if values.count == 1 { return [values[0] ]}
        var indices: [Float] = Array(repeating: Float(0), count: values.count)
        let d = Float(lenght) / Float(values.count - 1)
        for index in 0..<indices.count {
            indices[index] = Float(index) * d
        }
        return vDSP.linearInterpolate(values: values, atIndices: indices)
    }
}

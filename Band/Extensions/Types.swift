//
//  Types.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import simd

protocol Sizable {
    static func size(_ count: Int) -> Int
    static func stride(_ count: Int) -> Int
}

extension Sizable {
    static var size: Int {
        MemoryLayout<Self>.size
    }
    
    static var stride: Int {
        MemoryLayout<Self>.stride
    }
    
    static func size(_ count: Int) -> Int {
        count * size
    }

    static func stride(_ count: Int) -> Int {
        count * stride
    }
}

extension float3: Sizable {}
extension Float: Sizable {}

struct Vertex: Sizable {
    var position: float3
    var color: float4
}

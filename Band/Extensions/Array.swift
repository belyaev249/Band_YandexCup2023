//
//  Array.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import Foundation

extension Array {
    subscript (safe index: Index) -> Element? {
        if index >= 0 && index < count {
            return self[index]
        }
        return nil
    }
}

extension Array {
    init(repeating: [Element], count: Int) {
        var arr: [Element] = []
        for index in 0..<count {
            let value = repeating[index % repeating.count]
            arr.append(value)
        }
        self.init(arr)
    }
}


func convert<T>(count: Int, data: UnsafePointer<T>) -> [T] {
    let buffer = UnsafeBufferPointer(start: data, count: count)
    return Array(buffer)
}

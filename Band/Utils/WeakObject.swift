//
//  WeakObject.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import Foundation

final class WeakObject<T: AnyObject> {
    weak var value: T?
    private let id: ObjectIdentifier
    init(_ value: T) {
        self.id = ObjectIdentifier(value)
        self.value = value
    }
}

extension WeakObject: Hashable {
    static func == (lhs: WeakObject<T>, rhs: WeakObject<T>) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

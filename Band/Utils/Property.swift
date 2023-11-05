//
//  Property.swift
//  Band
//
//  Created by Egor on 03.11.2023.
//

import Combine

struct Property<T> {
    private let get: () -> T?
    private let set: (T?) -> Void
    
    var value: T? {
        get { get() }
        set { set(newValue) }
    }
        
    init(_ get: @escaping () -> T?, _ set: @escaping (T?) -> Void) {
        self.get = get
        self.set = set
    }
}

extension Property {
    init(_ get: @autoclosure () -> T) {
        let g = get()
        self.init({ g }, { _ in })
    }
}

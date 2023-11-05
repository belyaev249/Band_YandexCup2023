//
//  DataSource.swift
//  Band
//
//  Created by Egor on 03.11.2023.
//

import UIKit

final class DataSource<Value, Object> where Value: Hashable, Value: Identifiable, Object: UIView {
    
    func value(_ value: Value) -> Value? {
        _objects[value.id]?.1
    }
    
    func updateValue(
        _ newValue: Value,
        changeObject: @escaping (Object?) -> Void
    ) {
        if let object = _objects[newValue.id] {
            _objects[newValue.id]?.1 = newValue
            changeObject(object.0.value)
        }
    }
    func updateValues(
        _ newValues: [Value],
        createObject: @escaping (Value) -> Object?,
        addObject: @escaping (Object) -> Void,
        removeObject: @escaping (Object) -> Void,
        completion: @escaping () -> Void
    ) {
        var newObjects: [Value.ID: (WeakObject<Object>, Value)] = [:]
        var newObjectsArr: [WeakObject<Object>] = []
        newObjectsArr.reserveCapacity(newValues.count)
        
        for index in newValues.indices {
                        
            let value = newValues[index]
            var object = _objects[value.id]?.0.value
            
            if object == nil {
                object = createObject(value)
            }
                        
            if let object {
                
                let weakObject = WeakObject(object)
                
                newObjectsArr.append(weakObject)
                
                newObjects[value.id] = (weakObject, value)
                
                if object.superview == nil {
                    addObject(object)
                }
                
            }
            
        }
        
        for (value, object) in _objects {
            if newObjects[value] == nil {
                guard let object = object.0.value else { break }
                removeObject(object)
            }
        }
        
        self.objects = newObjectsArr
        self._objects = newObjects
        completion()
    }
    private var _objects: [Value.ID: (WeakObject<Object>, Value)] = [:]
    private(set) var objects: [WeakObject<Object>] = []
}

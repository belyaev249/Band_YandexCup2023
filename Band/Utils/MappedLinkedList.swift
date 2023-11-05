//
//  MappedLinkedList.swift
//  Band
//
//  Created by Egor on 03.11.2023.
//

import Foundation

struct MappedLinkedList<T> where T: Equatable, T: Identifiable {
    var dict: [T.ID : Node] = [:]
    var head: Node?
    var tail: Node?
    init(head: Node? = nil, tail: Node? = nil) {
        self.head = head
        self.tail = tail
    }
}

extension MappedLinkedList {
    final class Node {
        var value: T
        var next: Node?
        weak var prev: Node?
        init(value: T) {
            self.value = value
        }
    }
}

extension MappedLinkedList.Node: Equatable {
    static func == (lhs: MappedLinkedList.Node, rhs: MappedLinkedList.Node) -> Bool {
        return lhs.value == rhs.value
    }
}

extension MappedLinkedList {
    func update(value: T, toValue: T) {
        let node = dict[value.id]
        node?.value = toValue
    }
    
    mutating func remove(value: T) {
        let node = dict[value.id]
        
        let prev = node?.prev
        let next = node?.next
        
        if head === node { head = next }
        if tail === node { tail = prev }
        
        node?.prev?.next = next
        node?.next?.prev = prev
        
        node?.prev = nil
        node?.next = nil
        
        dict[value.id] = nil
    }
    
    mutating func append(value: T) {
        let node = Node(value: value)
        
        dict[value.id] = node
        
        guard
            dict.count > 1
        else {
            self.head = node
            self.tail = node
            return
        }
        
        let prevtail = tail
        
        tail?.next = node
        tail = node
        node.prev = prevtail
    }
}

extension MappedLinkedList {
    func array() -> [T] {
        var array: [T] = []

        guard let head else { return array }

        array.append(head.value)

        guard let tail else { return array }

        var node: Node = head

        while node.value != tail.value {
            if let next = node.next {
                node = next
            }
            array.append(node.value)
        }
        return array
    }
}

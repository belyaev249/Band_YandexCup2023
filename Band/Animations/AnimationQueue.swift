//
//  AnimationQueue.swift
//  Band
//
//  Created by Egor on 01.11.2023.
//

import UIKit

final class AnimationQueue: NSObject {
    private let function: AnimationFunction
    private var items: [WeakObject<CALayer>: [AnimationItem]] = [:]
    init(function: AnimationFunction) {
        self.function = function
    }
}

extension AnimationQueue {
    func commit() {
        for (key, value) in items {
            if let animationGroup = key.value?.makeAnimation(items: value) {
                key.value?.removeAllAnimations()
                CATransaction.begin()
                CATransaction.setDisableActions(true)
                key.value?.add(animationGroup, forKey: UUID().uuidString)
                let completion = {
                    for v in value {
                        v.completion?()
                    }
                }
                CATransaction.setCompletionBlock(completion)
                CATransaction.commit()
            }
        }
        items = [:]
    }
    
    private func insert(_ layer: CALayer, item: AnimationItem) {
        let l_obj = WeakObject(layer)
        if items[l_obj] == nil {
            items[l_obj] = []
        }
        items[l_obj]?.append(item)
    }
}

// MARK: - Scale

extension AnimationQueue {
    func animateScale(
        _ layer: CALayer,
        from s1: CGFloat,
        to s2: CGFloat,
        isRemovedOnCompletion: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        guard s1 != s2 else { return }
        let item = AnimationItem(
            description: .init(
                keyPath: #keyPath(CALayer.transform),
                values: [
                    CATransform3DMakeScale(s1, s1, 1),
                    CATransform3DMakeScale(s2, s2, 1)
                ]
            ),
            function: self.function,
            completion: { [weak layer] in
                if !isRemovedOnCompletion {
                    layer?.transform = CATransform3DMakeScale(s2, s2, 1)
                }
                completion?()
            }
        )
        insert(layer, item: item)
    }
}

// MARK: - Alpha

extension AnimationQueue {
    func animateAlpha(
        _ layer: CALayer,
        from a1: CGFloat,
        to a2: CGFloat,
        isRemovedOnCompletion: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        guard a1 != a2 else { return }
        let item = AnimationItem(
            description: .init(
                keyPath: #keyPath(CALayer.opacity),
                values: [a1, a2]
            ),
            function: self.function,
            completion: { [weak layer] in
                if !isRemovedOnCompletion {
                    layer?.opacity = Float(a2)
                }
                completion?()
            }
        )
        insert(layer, item: item)
    }
}

// MARK: - Frame

extension AnimationQueue {
    func animateBounds(
        _ layer: CALayer,
        to rect: CGRect = .zero,
        skipZero: Bool = true,
        isRemovedOnCompletion: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let fromRect = layer.presentation()?.frame ?? .zero
        animateFrame(
            layer,
            from: .init(origin: .zero, size: fromRect.size),
            to: .init(origin: .zero, size: rect.size),
            skipZero: skipZero,
            isRemovedOnCompletion: isRemovedOnCompletion,
            completion: completion
        )
    }
    func animateFrame(
        _ layer: CALayer,
        to rect: CGRect = .zero,
        skipZero: Bool = true,
        isRemovedOnCompletion: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        let fromRect = layer.presentation()?.frame ?? .zero
        animateFrame(
            layer, from: fromRect,
            to: rect, skipZero: skipZero,
            isRemovedOnCompletion: isRemovedOnCompletion,
            completion: completion
        )
    }
    func animateFrame(
        _ layer: CALayer,
        from rect1: CGRect = .zero,
        to rect2: CGRect = .zero,
        skipZero: Bool = true,
        isRemovedOnCompletion: Bool = false,
        completion: (() -> Void)? = nil
    ) {
        guard rect2 != rect1 else { return }
        let f: AnimationFunction = skipZero && rect1 == .zero ? .immediately : function
        let item1 = AnimationItem(
            description: .init(
                keyPath: #keyPath(CALayer.bounds),
                values: [
                    CGRect(origin: .zero, size: rect1.size),
                    CGRect(origin: .zero, size: rect2.size)
                ]
            ),
            function: f,
            completion: {}
        )
        let item2 = AnimationItem(
            description: .init(
                keyPath: #keyPath(CALayer.position),
                values: [
                    rect1.center(),
                    rect2.center()
                ]
            ),
            function: f,
            completion: { [weak layer] in
                if !isRemovedOnCompletion {
                    layer?.frame = rect2
                }
                completion?()
            }
        )
        
        insert(layer, item: item1)
        insert(layer, item: item2)
    }
}

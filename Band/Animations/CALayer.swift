//
//  CALayer.swift
//  Band
//
//  Created by Egor on 01.11.2023.
//

import UIKit

extension CALayer {
    func makeAnimation(items: [AnimationItem]) -> CAAnimationGroup {
        let group = CAAnimationGroup()
        
        group.repeatCount = repeatCount
        group.autoreverses = autoreverses
        
        var anims = [CAAnimation]()
        for item in items {
            if let properties = item.description.properties {
                group.isRemovedOnCompletion = group.isRemovedOnCompletion && properties.isRemovedOnCompletion
                if properties.fillMode == .forwards {
                    group.fillMode = .forwards
                }
            }
            group.duration = max(group.duration, item.function.duration)
            anims.append(makeAnimation(description: item.description, function: item.function))
        }
        group.animations = anims
        return group
    }
    
    private func makeAnimation(description: AnimationDescription, function: AnimationFunction) -> CAAnimation {
        let anim = CAKeyframeAnimation()

        anim.duration = function.duration
        anim.timingFunction = CAMediaTimingFunction(name: function.timingFunction)

        anim.keyPath = description.keyPath
        anim.values = description.values
        if function.duration == 0.0 {
            anim.values = [anim.values?.last as Any]
        }

        if let properties = description.properties {
            anim.isRemovedOnCompletion = properties.isRemovedOnCompletion
            anim.fillMode = properties.fillMode
        }

        return anim
    }
}

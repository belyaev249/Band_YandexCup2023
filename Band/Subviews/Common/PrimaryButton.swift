//
//  PrimaryButton.swift
//  Band
//
//  Created by Egor on 01.11.2023.
//

import UIKit

class PrimaryButton: UIButton {
    private let scaleEffect: CGFloat
    private let alphaEffect: CGFloat
    private let animationDurartion: CGFloat
    init(
        scaleEffect: CGFloat = 0.95,
        alphaEffect: CGFloat = 0.95,
        animationDurartion: CGFloat = 0.1
    ) {
        self.scaleEffect = scaleEffect
        self.alphaEffect = alphaEffect
        self.animationDurartion = animationDurartion
        super.init(frame: .zero)
        let l = UILongPressGestureRecognizer()
        l.addTarget(self, action: #selector(h))
        l.minimumPressDuration = 0.0
        addGestureRecognizer(l)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func h(_ sender: UILongPressGestureRecognizer) {
        let q = AnimationQueue(
            function: .init(
                duration: animationDurartion,
                timingFunction: .easeIn
            )
        )
        if sender.state == .began {
            q.animateScale(layer, from: 1, to: scaleEffect, isRemovedOnCompletion: true)
            q.animateAlpha(layer, from: 1, to: alphaEffect, isRemovedOnCompletion: true)
        } else if sender.state == .ended {
            q.animateScale(layer, from: scaleEffect, to: 1, isRemovedOnCompletion: true)
            q.animateAlpha(layer, from: alphaEffect, to: 1, isRemovedOnCompletion: true)
            sendActions(for: .touchUpInside)
        }
        q.commit()
    }
    
}

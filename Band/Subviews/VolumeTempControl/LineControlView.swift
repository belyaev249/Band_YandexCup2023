//
//  LineControlView.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit
import Darwin

final class LineControlContentView: CALayer {
    
    private var contentType: LineControlView.ContentType?

    init(_ contentType: LineControlView.ContentType = .temp) {
        self.contentType = contentType
        super.init()
    }
    
    override init() {
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(in ctx: CGContext) {
        super.draw(in: ctx)
        switch contentType {
        case .volume:
            drawVolume(in: ctx)
        default:
            drawTemp(in: ctx)
        }
    }
    
    override func layoutSublayers() {
        super.layoutSublayers()
        setNeedsDisplay()
    }
    
}

extension LineControlContentView {
    func drawVolume(
        in ctx: CGContext,
        count: Int = 20,
        lineColor: UIColor = .white
    ) {
        let h = bounds.height
        let w = bounds.width
        let lineWidth: CGFloat = 2
                
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(lineColor.cgColor)
        
        for i in 1...count {
            let x = pow(Double(i) / Double(count), 0.7) * w - lineWidth / 2.0
            ctx.move(to: .init(x: x, y: 0))
            ctx.addLine(to: .init(x: x, y: h))
            ctx.drawPath(using: .fillStroke)
        }
        
        ctx.closePath()
    }
    
    func drawTemp(
        in ctx: CGContext,
        partsCount: Int = 5,
        childCount: Int = 5,
        lineColor: UIColor = .white
    ) {
        let h = bounds.height
        let w = bounds.width
        let lineWidth: CGFloat = 2
        
        ctx.setLineWidth(lineWidth)
        ctx.setStrokeColor(lineColor.cgColor)
        
        let pw = (w - 2 * lineWidth) / CGFloat(partsCount)
        let cw = pw / CGFloat(childCount + 1)
        
        for p in 0...partsCount {
            let px = CGFloat(p) * pw + lineWidth
            ctx.move(to: .init(x: px, y: h))
            ctx.addLine(to: .init(x: px, y: 0))
            ctx.drawPath(using: .fillStroke)
            
            if p == partsCount {
                return
            }
            
            for c in 1...childCount {
                let x = px + CGFloat(c) * cw
                ctx.move(to: .init(x: x, y: h))
                ctx.addLine(to: .init(x: x, y: h/2.5))
                ctx.drawPath(using: .fillStroke)
            }
        }
        
        ctx.closePath()
    }
}

private let inset = 40.0

final class LineControlView: UIView {
        
    var onValueChanged: ((Float) -> Void)?
        
    var value: Double = 1 {
        didSet {
            onValueChanged?(Float(value))
            updateLayout()
        }
    }
    
    var onTouch = false {
        didSet {
            if !onTouch {
                value = value.bound(l: 0, r: 1)
            }
            updateLayout()
        }
    }
    
    private var badgeView: BadgeControlView
    private let contentView: CALayer
        
    init(_ contentType: ContentType = .temp, badgeText: String = String()) {
        
        contentView = LineControlContentView(contentType)
        badgeView = BadgeControlView(badgeText)
        badgeView.backgroundColor = CoreColors.green
        
        super.init(frame: .zero)
                
        layer.addSublayer(self.contentView)
        addSubview(self.badgeView)
        
        let dragGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDragGestureRecognizer)
        )
        addGestureRecognizer(dragGestureRecognizer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
                
        let aq: AnimationQueue
        
        if onTouch {
            aq = AnimationQueue(function: .immediately)
        } else {
            aq = AnimationQueue(function: .init(duration: 0.2, timingFunction: .easeOut))
        }
                
        let effect = value.bound(l: 0.0, r: 1, side: { sqrt($0) / 20.0 })
        
        let badgeViewSize = badgeView.updateLayout(onTouch: onTouch, value: value)
        var badgeViewX: CGFloat = bounds.width - 2 * inset
        
        if onTouch {
            badgeViewX *= effect
        } else {
            badgeViewX *= value
        }
        
        let badgeViewCenter = CGPoint(
            x: badgeViewX + inset,
            y: bounds.height - badgeViewSize.height / 2.0
        )
        
        let badgeViewRect = CGRect(center: badgeViewCenter, size: badgeViewSize)
        aq.animateFrame(badgeView.layer, to: badgeViewRect)
        badgeView.layer.cornerRadius = 8
        
        
        let contentViewRect = CGRect(
            x: inset,
            y: bounds.height / 2.0,
            width: bounds.width - 2 * inset,
            height: bounds.height / 2.0
        )
        
        contentView.frame = contentViewRect
        
        aq.commit()
        
    }
    
    @objc
    func handleDragGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        let pos = sender.location(in: self)
        let scaledRect = badgeView.frame.scaled(by: 4)
        
        if scaledRect.contains(pos) && sender.state == .began {
            onTouch = true
        }
        
        if sender.state == .ended {
            onTouch = false
        }
        
        guard onTouch else { return }
        
        value = (pos.x - inset) / contentView.bounds.width
        
    }
    
}

extension LineControlView {
    enum ContentType {
        case volume
        case temp
    }
}

#if DEBUG
import SwiftUI
struct Provider_LineControlView: PreviewProvider {
    static var previews: some View {
        AnyView(LineControlView(.volume))
            .frame(height: 100)
            .background(Color.green)
    }
}
#endif

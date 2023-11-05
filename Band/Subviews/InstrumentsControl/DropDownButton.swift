//
//  DropDownButton.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

private enum Constants {
    static let labelHeight: CGFloat = 40
    static let imagePadding: CGFloat = 15
    static let labelViewTopInset: CGFloat = 10
}

final class DropDownButton: UIView, UIGestureRecognizerDelegate {
    var onFocus: ((Sample?) -> Void)?
    var onSelect: (() -> Void)?
    var onChoose: ((Sample?) -> Void)?
    private lazy var onAction: (() -> Void)? = { [weak self] in self?.onSelect?() }
    private var focusedItem: Sample?

    private let values: [Sample]
    private var labels: [WeakObject<UILabel>] = []
    
    private var onStartTouch = false {
        didSet {
            guard oldValue != onStartTouch else { return }
            updateLayout()
        }
    }
    
    private var onDrop = false {
        didSet {
            guard oldValue != onDrop else { return }
            updateLayout()
        }
    }
    
    private var highlightView: CAGradientLayer = {
        var v = CAGradientLayer()
        v.colors = [
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.cgColor,
            UIColor.white.withAlphaComponent(0).cgColor,
        ]
        return v
    }()
            
    private lazy var contentView: UIButton = {
        var v = PrimaryButton(alphaEffect: 1.0)
        v.backgroundColor = CoreColors.green
        return v
    }()
    
    private lazy var imageView: UIImageView = {
        var v = UIImageView()
        v.contentMode = .scaleAspectFit
        return v
    }()
    
    private lazy var labelView: UILabel = {
        var v = UILabel()
        v.textColor = CoreColors.textPrimary
        v.textAlignment = .center
        v.textColor = .white
        return v
    }()
    
    private lazy var dropDownView: UIView = {
        var v = UIView()
        v.backgroundColor = CoreColors.green
        v.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        return v
    }()
    
    private lazy var dropDownMask: CALayer = {
        var v = CALayer()
        v.backgroundColor = UIColor.green.cgColor
        v.actions = [
            #keyPath(CALayer.bounds): NSNull(),
            #keyPath(CALayer.position): NSNull(),
        ]
        return v
    }()
    
    init(
        _ values: [Sample],
        contentImage: UIImage?,
        text: String = String()
    ) {
        self.values = values
        super.init(frame: .zero)
        
        addSubview(labelView)
        labelView.text = text
                
        addSubview(dropDownView)
        dropDownView.layer.mask = dropDownMask

        addSubview(contentView)
        contentView.addSubview(imageView)
        
        contentView.addTarget(self, action: #selector(didButtonTouched), for: .touchUpInside)
        
        self.imageView.image = contentImage
        
        dropDownView.layer.addSublayer(highlightView)
                
        for value in values {
            let v = UILabel()
            v.text = "\(value.name)"
            v.textAlignment = .center
            dropDownView.addSubview(v)
            labels.append(.init(v))
        }
        
        let longGestureRecognizer = UILongPressGestureRecognizer(
            target: self,
            action: #selector(handleLongGestureRecognizer)
        )
        longGestureRecognizer.delegate = self
        longGestureRecognizer.minimumPressDuration = 0.2
        addGestureRecognizer(longGestureRecognizer)
        
        let panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePanGestureRecognizer)
        )
        panGestureRecognizer.delegate = self
        addGestureRecognizer(panGestureRecognizer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        
        let aq = AnimationQueue(function: .init(duration: 0.3, timingFunction: .easeOut))
        
        if onDrop {
            highlightView.frame = .zero
        }
        
        let contentViewRect = bounds
        contentView.frame = contentViewRect
        contentView.layer.cornerRadius = min(contentView.bounds.width, contentView.bounds.height) / 2.0
                
        let imageViewRect = CGRect(
            x: Constants.imagePadding,
            y: Constants.imagePadding,
            width: contentView.bounds.width - 2 * Constants.imagePadding,
            height: contentView.bounds.height - 2 * Constants.imagePadding
        )
        imageView.frame = imageViewRect
        
        
        let labelViewY = bounds.height + Constants.labelViewTopInset
        let labelViewRect = CGRect(x: 0, y: labelViewY, width: bounds.width, height: 20)
        let labelViewAlpha: CGFloat
        if onDrop {
            labelViewAlpha = 0.0
        } else {
            labelViewAlpha = 1.0
        }
        labelView.frame = labelViewRect
        aq.animateAlpha(labelView.layer, from: labelView.alpha, to: labelViewAlpha)
        
        
        var prevY: CGFloat? = contentView.bounds.height / 2.0
        for labelObj in labels {
            labelObj.value?.frame.size.width = bounds.width
            labelObj.value?.frame.size.height = Constants.labelHeight
            labelObj.value?.frame.origin = .init(x: 0, y: (prevY ?? 0))
            prevY = labelObj.value?.frame.maxY
        }
        
        let dropDownViewHeight = Constants.labelHeight * CGFloat(labels.count) + bounds.height * 0.9
        let dropDownViewOffset: CGFloat
        let dropDownViewAlpha: CGFloat

        if onDrop {
            dropDownViewOffset =  contentView.bounds.height / 2.0
            dropDownViewAlpha = 1
        } else {
            dropDownViewOffset = contentView.bounds.height / 2.0 - dropDownViewHeight
            dropDownViewAlpha = 0
        }
        
        let dropDownViewWidth = bounds.width * 0.95
        let dropDownViewRect = CGRect(
            center: .init(
                x: bounds.width / 2,
                y: dropDownViewOffset + dropDownViewHeight / 2.0
            ),
            size: .init(width: dropDownViewWidth, height: dropDownViewHeight)
        )

        aq.animateFrame(dropDownView.layer, to: dropDownViewRect)
        aq.animateAlpha(dropDownView.layer, from: dropDownView.alpha, to: dropDownViewAlpha)
        
        dropDownView.layer.cornerRadius = min(bounds.width, bounds.height) / 2.0
        
        let dropDownMaskHeight: CGFloat
        if onDrop {
            dropDownMaskHeight = dropDownViewHeight
        } else {
            dropDownMaskHeight = 0
        }
        let dropDownMaskRect = CGRect(
            x: 0,
            y: dropDownView.bounds.height - dropDownMaskHeight,
            width: dropDownView.bounds.width,
            height: dropDownMaskHeight
        )
        aq.animateFrame(dropDownMask, to: dropDownMaskRect)
        
        aq.commit()
        
    }
    
    @objc
    private func handleLongGestureRecognizer(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            onDrop = true
        }
        if sender.state == .ended {
            onDrop = false
        }
    }
        
    @objc
    private func handlePanGestureRecognizer(_ sender: UILongPressGestureRecognizer) {
        let offset = bounds.height
        var pos = sender.location(in: self)
        pos.y -= offset
        
        let index = Int(pos.y / Constants.labelHeight)
        let highlightedLabelRect = labels[safe: index]?.value?.frame
        
        if let highlightedLabelRect, let sample = values[safe: index], sample != focusedItem {
            highlightView.frame = highlightedLabelRect
            onFocus?(sample)
            focusedItem = sample
            onAction = { [weak self] in self?.onChoose?(sample) }
        }
        
        if sender.state == .ended {
            focusedItem = nil
        }
        
    }
    
    @objc
    private func didButtonTouched(_ sender: UIButton) {
        onAction?()
        onAction = { [weak self] in self?.onSelect?() }
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
    
}

#if DEBUG
import SwiftUI
struct Provider_DropDownButton: PreviewProvider {
    static var previews: some View {
        AnyView(DropDownButton([.guitar1, .guitar2, .guitar3], contentImage: UIImage(systemName: "plus")))
            .frame(width: 80, height: 80)
    }
}
#endif

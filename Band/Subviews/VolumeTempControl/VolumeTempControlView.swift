//
//  VolumeTempControlView.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

struct VolumeTempData: Equatable {
    let volume: Double
    let temp: Double
}

final class VolumeTempControlView: UIView {
    
    var onValueChanged: ((VolumeTempData) -> Void)?
    
    var value: VolumeTempData {
        get {
            .init(
                volume: hLineControl.value,
                temp: vLineControl.value
            )
        }
        set {
            onValueChanged?(newValue)
            vLineControl.value = newValue.temp
            hLineControl.value = newValue.volume
        }
    }
    
    private lazy var vLineControl: LineControlView = {
        var v = LineControlView(.temp, badgeText: "Скорость")
        v.transform = CGAffineTransform(rotationAngle: .pi/2)
        return v
    }()
    
    private lazy var hLineControl: LineControlView = {
        var v = LineControlView(.volume, badgeText: "Громкость")
        return v
    }()
    
    private lazy var controlAreaView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(controlAreaView)
        
        addSubview(vLineControl)
        vLineControl.onValueChanged = { [weak self] _ in
            guard let value = self?.value else { return }
            self?.onValueChanged?(value)
        }
        
        addSubview(hLineControl)
        hLineControl.onValueChanged = { [weak self] _ in
            guard let value = self?.value else { return }
            self?.onValueChanged?(value)
        }
        
        let dragGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(handleDragGestureRecognizer)
        )
        controlAreaView.addGestureRecognizer(dragGestureRecognizer)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        
        let controlHeight = Constants.controlHeight
        
        controlAreaView.frame = .init(
            x: controlHeight,
            y: 0,
            width: bounds.width - controlHeight,
            height: bounds.height - controlHeight
        )
        
        hLineControl.frame = .init(
            x: controlHeight,
            y: bounds.height - controlHeight,
            width: bounds.width - 2 * controlHeight,
            height: controlHeight
        )
        
        vLineControl.frame = .init(
            x: 0,
            y: 0,
            width: controlHeight,
            height: bounds.height - controlHeight
        )
        
    }
    
}

@objc
private extension VolumeTempControlView {
    func handleDragGestureRecognizer(_ sender: UIPanGestureRecognizer) {
        let pos = sender.location(in: controlAreaView)
        
        let hValue = pos.x / bounds.width
        let vValue = pos.y / bounds.height
        
        value = .init(volume: hValue, temp: vValue)
        if sender.state == .began {
            hLineControl.onTouch = true
            vLineControl.onTouch = true
        }
        if sender.state == .ended {
            hLineControl.onTouch = false
            vLineControl.onTouch = false
        }
    }
}

private enum Constants {
    static let controlHeight: CGFloat = 30
    static let spacing: CGFloat = 40
}

#if DEBUG
import SwiftUI
struct Provider_VolumeTempControlView: PreviewProvider {
    static var previews: some View {
        AnyView(VolumeTempControlView())
            .frame(height: 400)
            .background(Color.green)
    }
}
#endif

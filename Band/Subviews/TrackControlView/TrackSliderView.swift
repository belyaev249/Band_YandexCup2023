//
//  TrackSliderView.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

private enum Constants {
    static let cornerRadius: CGFloat = 8
    static let labelViewLeadingPadding: CGFloat = 10
}

final class TrackSliderView: UIView {
    
    var onDelete: (() -> Void)?
    
    var volume: Double {
        didSet {
            updateLayout()
        }
    }
    private let name: String
    
    private lazy var sliderView: UIView = {
        var v = UIView()
        v.backgroundColor = CoreColors.green
        v.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return v
    }()

    private lazy var labelView: UILabel = {
        var v = UILabel()
        v.text = name
        return v
    }()
    
    private lazy var actionButtonView: UIButton = {
        var v = PrimaryButton()
        v.imageEdgeInsets = .init(8)
        v.setImage(CoreAssets.play_icon.image, for: .normal)
        return v
    }()
    
    private lazy var volumeButtonView: UIButton = {
        var v = PrimaryButton()
        v.imageEdgeInsets = .init(7)
        v.setImage(CoreAssets.audioOff_icon.image, for: .normal)
        return v
    }()
    
    private lazy var deleteButtonView: UIButton = {
        var v = PrimaryButton()
        v.backgroundColor = CoreColors.bgSecondary
        v.imageEdgeInsets = .init(15)
        v.setImage(CoreAssets.cross_icon.image, for: .normal)
        return v
    }()
    
    init(name: String, volume: Double) {
        
        self.name = name
        self.volume = volume
        
        super.init(frame: .zero)
        
        clipsToBounds = true
        
        backgroundColor = CoreColors.bgPrimary
        
        addSubview(sliderView)
        addSubview(labelView)
        addSubview(deleteButtonView)
        
        addSubview(actionButtonView)
        addSubview(volumeButtonView)
                
        deleteButtonView.onTap { [weak self] in
            self?.onDelete?()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
                        
        let normalHeight = min(bounds.width, bounds.height)
        
        
        let deleteButtonViewCenter = CGPoint(
            x: bounds.width - normalHeight / 2.0,
            y: bounds.height - normalHeight / 2.0
        )
        
        let deleteButtonViewHeight = normalHeight
        
        let deleteButtonViewRect = CGRect(
            center: deleteButtonViewCenter,
            size: .init(width: deleteButtonViewHeight, height: deleteButtonViewHeight)
        )
        
        deleteButtonView.frame = deleteButtonViewRect
        deleteButtonView.layer.cornerRadius = Constants.cornerRadius
            
        
        let volumeButtonViewHeight = normalHeight * 0.7
        let volumeButtonViewX = bounds.width - volumeButtonViewHeight - 10 - deleteButtonViewHeight
        
        let volumeButtonViewRect = CGRect(
            x: volumeButtonViewX,
            y: (bounds.height - volumeButtonViewHeight) / 2.0,
            width: volumeButtonViewHeight,
            height: volumeButtonViewHeight
        )
        
        volumeButtonView.frame = volumeButtonViewRect
        volumeButtonView.layer.cornerRadius = Constants.cornerRadius
                
        
        let actionButtonViewHeight = volumeButtonViewHeight
        let actionButtonViewX = volumeButtonViewX - actionButtonViewHeight - 10
        
        let actionButtonViewRect = CGRect(
            x: actionButtonViewX,
            y: (bounds.height - actionButtonViewHeight) / 2.0,
            width: actionButtonViewHeight,
            height: actionButtonViewHeight
        )
        
        actionButtonView.frame = actionButtonViewRect
        actionButtonView.layer.cornerRadius = Constants.cornerRadius
        
        
        let labelViewRect = CGRect(
            x: Constants.labelViewLeadingPadding,
            y: 0,
            width: bounds.width - normalHeight,
            height: normalHeight
        )
        
        labelView.frame = labelViewRect
        
        
        let sliderViewWidth = bounds.width * volume
        let sliderViewRect = CGRect(
            x: 0,
            y: 0,
            width: sliderViewWidth,
            height: bounds.height
        )
        
        sliderView.frame = sliderViewRect
        sliderView.layer.cornerRadius = Constants.cornerRadius
        
        
    }
    
}

#if DEBUG
import SwiftUI
struct Provider_TrackSliderView: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            AnyView(TrackSliderView(name: "dewedw", volume: 0.5))
                .frame(height: 60)
        }
    }
}
#endif

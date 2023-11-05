//
//  ActionControlView.swift
//  Band
//
//  Created by Egor on 03.11.2023.
//

import UIKit

final class ActionControlView: UIView {
    private var isAudioPlaying = false {
        didSet {
            let image: UIImage?
            if isAudioPlaying {
                image = CoreAssets.pause_icon.image
            } else {
                image = CoreAssets.play_icon.image
            }
            playButtonView.setImage(image, for: .normal)
            micButtonView.isEnabled = isMicButtonEnabled
        }
    }
    private var isAudioRecording = false {
        didSet {
            let image: UIImage?
            if isAudioRecording {
                image = CoreAssets.rec_icon.image?.withTintColor(.red, renderingMode: .alwaysTemplate)
            } else {
                image = CoreAssets.rec_icon.image
            }
            recordButtonView.setImage(image, for: .normal)
            micButtonView.isEnabled = isMicButtonEnabled
        }
    }
    var isRecording = false {
        didSet {
            recordButtonView.isEnabled = isAudioButtonsEnabled
            playButtonView.isEnabled = isAudioButtonsEnabled
        }
    }
    
    private var isMicButtonEnabled: Bool {
        !isAudioPlaying && !isAudioRecording
    }
    
    private var isAudioButtonsEnabled: Bool {
        !isRecording
    }
    
    var onLayersTouch: (() -> Void)?
    var onMicTouch: ((Bool) -> Void)?
    var onRecordTouch: ((Bool) -> Void)?
    var onPlayTouch: ((Bool) -> Void)?
    
    private lazy var layersView: UIButton = {
        var v = PrimaryButton()
        v.backgroundColor = CoreColors.bgPrimary
        return v
    }()
    
    private lazy var playButtonView: UIButton = {
        var v = PrimaryButton()
        v.backgroundColor = CoreColors.bgPrimary
        let insets: CGFloat = 12
        v.imageEdgeInsets = .init(top: insets, left: insets, bottom: insets, right: insets)
        v.setImage(CoreAssets.play_icon.image, for: .normal)
        return v
    }()
    
    private lazy var recordButtonView: UIButton = {
        var v = PrimaryButton()
        v.backgroundColor = CoreColors.bgPrimary
        let insets: CGFloat = 13
        v.imageEdgeInsets = .init(top: insets, left: insets, bottom: insets, right: insets)
        v.setImage(CoreAssets.rec_icon.image, for: .normal)
        v.imageView?.tintColor = .red
        return v
    }()
    
    lazy var micButtonView: UIButton = {
        var v = PrimaryButton()
        v.backgroundColor = CoreColors.bgPrimary
        let insets: CGFloat = 11
        v.imageEdgeInsets = .init(top: insets, left: insets, bottom: insets, right: insets)
        v.setImage(CoreAssets.mic_icon.image, for: .normal)
        v.setImage(CoreAssets.mic_icon.image, for: .normal)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(layersView)
        addSubview(micButtonView)
        addSubview(recordButtonView)
        addSubview(playButtonView)
        
        layersView.onTap { [weak self] in
            self?.onLayersTouch?()
        }
        
        micButtonView.onTap { [weak self] in
            guard let self else { return }
            self.isRecording.toggle()
            self.onMicTouch?(self.isRecording)
        }
        
        recordButtonView.onTap { [weak self] in
            guard let self else { return }
            self.isAudioRecording.toggle()
            self.onRecordTouch?(self.isAudioRecording)
        }
        
        playButtonView.onTap { [weak self] in
            guard let self else { return }
            self.isAudioPlaying.toggle()
            self.onPlayTouch?(self.isAudioPlaying)
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
        
        let buttonHeight = bounds.height
        
        let layersViewRect = CGRect(
            x: 0,
            y: 0,
            width: Constants.layersViewWidth,
            height: bounds.height
        )
        layersView.frame = layersViewRect
        layersView.layer.cornerRadius = Constants.cornerRadius
                
        let playButtonViewRect = CGRect(
            x: bounds.width - buttonHeight,
            y: 0,
            width: buttonHeight,
            height: buttonHeight
        )
        playButtonView.frame = playButtonViewRect
        playButtonView.layer.cornerRadius = Constants.cornerRadius
        
        let recordButtonViewRect = CGRect(
            x: bounds.width - 2 * buttonHeight - Constants.spacing,
            y: 0,
            width: buttonHeight,
            height: bounds.height
        )
        recordButtonView.frame = recordButtonViewRect
        recordButtonView.layer.cornerRadius = Constants.cornerRadius
        
        let micButtonViewRect = CGRect(
            x: bounds.width - 3 * buttonHeight - 2 * Constants.spacing,
            y: 0,
            width: buttonHeight,
            height: bounds.height
        )
        micButtonView.frame = micButtonViewRect
        micButtonView.layer.cornerRadius = Constants.cornerRadius
        
    }

}

private enum Constants {
    static let cornerRadius: CGFloat = 8
    static let layersViewWidth: CGFloat = 100
    static let spacing: CGFloat = 5
}

#if DEBUG
import SwiftUI
struct Provider_ActionControlView: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.gray
            AnyView(ActionControlView())
                .frame(height: 40)
                .background(Color.green)
        }
    }
}
#endif


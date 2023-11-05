//
//  BandView.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import UIKit
import Combine

private enum Constants {
    static let padding: CGFloat = 15
    static let instrumentsControlViewHeight: CGFloat = 80
    static let volumeTempControlViewTopInset: CGFloat = 40
    static let bottomViewHeight: CGFloat = 120
    static let trackControlViewHeight: CGFloat = 200
    
    static let maxVolume: Float = 3.0
    static let minVolume: Float = 0.5
    
    static let maxTemp: Float = 3.0
    static let minTemp: Float = 0.5
}

final class BandViewController: UIViewController {
    
    private let trackLineGenerator = TrackLineGenerator()
    
    private let player = Player()
    private let recorder = Recorder()
    
    private lazy var _view = BandView()
    
    override func loadView() {
        view = _view
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        _view.onPlay = { [weak self] in
            self?.player.all($0)
        }
        
        _view.onRecord = { [weak self] in
            $0
        }
        
        _view.onStartRecord = { [weak self] in
            self?.recorder.record(UUID().uuidString, $0)
        }
        
        _view.onFinishRecord = { [weak self] in
            self?.recorder.stop($0)
        }
        
        _view.onTrackChanged = { [weak self] (track) in
            self?.trackLineGenerator.updateTrack(track: track) { max, values in
                self?._view.setupLine(max: CGFloat(max), values: values)
            }
        }
        
        _view.onTrackDeleted = { [weak self] (track) in
            guard let track else { return }
            self?.player.remove(forTrack: track)
            self?.trackLineGenerator.removeTrack(track: track) { max, values in
                self?._view.setupLine(max: CGFloat(max), values: values)
            }
        }
        
        _view.onTrackSelected = { [weak self] (track) in
            guard
                let self,
                let volumeTemp = track.volumeTemp,
                let url = track.sample.url
            else {
                return
            }
            let volume = self.mappedVolume(Float(volumeTemp.volume))
            let temp = self.mappedTemp(Float(volumeTemp.temp))
            self.player.set(url, volume: volume, temp: temp, isLoop: true, forTrack: track)
        }
        
        _view.onSampleSelected = { [weak self] (sample) in
            guard let url = sample.url  else { return }
            self?.player.set(url, volume: 1.0, temp: 1.0, isLoop: false, forTrack: nil)
        }
        
        _view.onTempChanged = { [weak self] (value, track) in
            guard let self else { return }
            let t = self.mappedTemp(value)
            self.player.temp(t, forTrack: track)
        }
        
        _view.onVolumeChanged = { [weak self] (value, track) in
            guard let self else { return }
            let v = self.mappedVolume(value)
            self.player.volume(v, forTrack: track)
        }
        
    }
    
    private func mappedVolume(_ value: Float) -> Float {
        let v = (Constants.maxVolume * value.bound(l: 0, r: 1) / 1.0)
            .bound(
                l: Constants.minVolume,
                r: Constants.maxVolume
            )
        return v
    }
    
    private func mappedTemp(_ value: Float) -> Float {
        let t = (Constants.maxTemp * (1 - value) / 1.0)
            .bound(
                l: Constants.minTemp,
                r: Constants.maxTemp
            )
        return t
    }
    
}

final class BandViewState: ObservableObject {
    
    var isLayersShowing = false
    var isRecording: Property<Bool>?
    
    var isAudioRecording = false
    var isAudioPlaying = false
    
    var isBlurShowing: Bool {
        isLayersShowing || (isRecording?.value == true) || isAudioRecording || isAudioPlaying
    }
    
    @Published
    var tracks = MappedLinkedList<TrackData>()
    
    @Published
    var currentTrack: TrackData?
    
    var volumeTemp: Property<VolumeTempData>?
}

final class BandView: UIView {
    
    var onPlay: ((Bool) -> Void)?
    var onRecord: ((Bool) -> Void)?
    
    var onStartRecord: ((@escaping (Bool) -> Void) -> Void)?
    var onFinishRecord: ((@escaping (URL?) -> Void) -> Void)?
    
    var onTrackSelected: ((TrackData) -> Void)?
    var onTrackChanged: ((TrackData) -> Void)?
    var onTrackDeleted: ((TrackData?) -> Void)?

    var onSampleSelected: ((Sample) -> Void)?
    
    var onVolumeChanged: ((Float, TrackData) -> Void)?
    var onTempChanged: ((Float, TrackData) -> Void)?
    
    var state = BandViewState()
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var instrumentsControlView: InstrumentsControlView = {
        var v = InstrumentsControlView([
            .init(image: CoreAssets.guitar_icon.image, text: "Гитара", current: .guitar1, items: [.guitar1, .guitar2, .guitar3]),
            .init(image: CoreAssets.drum_icon.image, text: "Ударные", current: .drum1, items: [.drum1, .drum2, .drum3]),
            .init(image: CoreAssets.wind_icon.image, text: "Духовые", current: .w1, items: [.w1, .w2, .w3]),
        ])
        return v
    }()
    
    private lazy var volumeTempControlView: VolumeTempControlView = {
        var v = VolumeTempControlView()
        return v
    }()
    
    private lazy var trackControlView: TrackControlView = {
        var v = TrackControlView()
        return v
    }()
    
    private lazy var actionControlView: ActionControlView = {
        var v = ActionControlView()
        return v
    }()
    
    private lazy var audioPreviewView: UIImageView = {
        var v = UIImageView()
        return v
    }()
    
    private lazy var blurView: UIView = {
        var v = UIView()
        v.backgroundColor = CoreColors.bgTertiary.withAlphaComponent(0.6)
        return v
    }()
    
    private lazy var contentView: UIView = {
        var v = BackgrounGradientView()
        return v
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: .zero)
        
        state.isRecording = .init(
            { [weak self] in
                guard let self else { return false }
                return self.actionControlView.isRecording
            },
            { [weak self] in
                guard let self else { return }
                self.actionControlView.isRecording = $0 == true
            }
        )
                
        backgroundColor = CoreColors.bgTertiary
        
        addSubview(contentView)
        contentView.addSubview(volumeTempControlView)
        contentView.addSubview(instrumentsControlView)
        
        addSubview(audioPreviewView)
        addSubview(actionControlView)
        addSubview(trackControlView)
        contentView.addSubview(blurView)
        
        setupBlur()
        
        setupInstrumentsControl()
        
        setupVolumeTempControl()
        
        setupTrackControl()
        
        setupActionControl()
        
    }
        
    private func setupBlur() {
        blurView.onTap { [weak self] in
            self?.state.isLayersShowing = false
            self?.updateLayout()
        }
    }
    
    private func setupActionControl() {
        actionControlView.onLayersTouch = { [weak self] in
            self?.state.isLayersShowing.toggle()
            self?.updateLayout()
        }
        
        actionControlView.onMicTouch = { [weak self] (isRecording) in
            guard let self else { return }
            self.onTrackDeleted?(nil)
            self.state.currentTrack = nil
            self.state.volumeTemp?.value = .init(volume: 0.5, temp: 0.5)
            if isRecording {
                self.onStartRecord? { isStarted in
                    if !isStarted {
                        self.state.isRecording?.value = false
                    }
                    self.state.isRecording?.value = isStarted
                    self.updateLayout()
                }
            } else {
                self.onFinishRecord? { url in
                    let sample = Sample(name: UUID().uuidString, url: url)
                    self.setupTrack(sample: sample)
                    guard let track = self.state.currentTrack else { return }
                    self.onTrackSelected?(track)
                }
                self.state.isRecording?.value = isRecording
                self.updateLayout()
            }
        }
        
        actionControlView.onPlayTouch = { [weak self] (a) in
            self?.state.isAudioPlaying = a
            self?.updateLayout()
            self?.onPlay?(a)
        }
        
        actionControlView.onRecordTouch = { [weak self] (a) in
            self?.state.isAudioRecording = a
            self?.updateLayout()
            self?.onRecord?(a)
        }
    }
    
    private func setupVolumeTempControl() {
        volumeTempControlView.onValueChanged = { [weak self] in
            self?.state.currentTrack?.volumeTemp = $0
            guard let track = self?.state.currentTrack else { return }
            self?.onVolumeChanged?(Float($0.volume), track)
            self?.onTempChanged?(Float($0.temp), track)
        }
    }
    
    func setupLine(max: CGFloat, values: [Float]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.audioPreviewView.image = waveImage(
                values,
                max,
                .init(
                    width: self.audioPreviewView.bounds.width,
                    height: self.audioPreviewView.bounds.height
                ),
                2.0,
                .white
            )
        }
    }
    
    private func setupTrack(sample: Sample) {
        let track: TrackData = .init(
            name: "\(Int.random(in: 0...1000))",
            sample: sample,
            volumeTemp: .init(volume: 0.5, temp: 0.5)
        )
        self.state.tracks.append(value: track)
        self.state.currentTrack = track
        
        let volumeTemp: Property<VolumeTempData> = .init(
            { [weak self] in
                self?.volumeTempControlView.value
            },
            { [weak self] in
                guard let volumeTemp = $0 else { return }
                self?.volumeTempControlView.value = volumeTemp
                self?.state.currentTrack?.volumeTemp = volumeTemp
            }
        )
        
        self.state.volumeTemp = volumeTemp
        self.state.volumeTemp?.value = track.volumeTemp
    }
    
    private func setupInstrumentsControl() {
        instrumentsControlView.onSelectItem = { [weak self] in
            guard let sample = $0 else { return }
            self?.setupTrack(sample: sample)
            guard let track = self?.state.currentTrack else { return }
            self?.onTrackSelected?(track)
        }
        
        instrumentsControlView.onChooseItem = { [weak self] (sample) in
            guard let sample else { return }
            if self?.state.currentTrack == nil {
                self?.setupTrack(sample: sample)
            }
            self?.state.currentTrack?.sample = sample
            guard let track = self?.state.currentTrack else { return }
            self?.onTrackSelected?(track)
        }
        
        instrumentsControlView.onFocusItem = { [weak self] (sample) in
            guard let sample else { return }            
            self?.onSampleSelected?(sample)
        }
    }
    
    private func setupTrackControl() {
        trackControlView.onTrackSelected = { [weak self] (track) in
            self?.state.currentTrack = track
            
            let volumeTemp: Property<VolumeTempData> = .init(
                { [weak self] in
                    self?.volumeTempControlView.value
                },
                { [weak self] in
                    guard let volumeTemp = $0 else { return }
                    self?.volumeTempControlView.value = volumeTemp
                    self?.state.currentTrack?.volumeTemp = volumeTemp
                }
            )
            
            self?.state.volumeTemp = volumeTemp
            self?.state.volumeTemp?.value = track.volumeTemp
            self?.state.isLayersShowing = false
            self?.updateLayout()
            
            self?.onTrackSelected?(track)
        }

        trackControlView.onTrackDeleted = { [weak self] (track) in
            if track == self?.state.currentTrack {
                self?.state.currentTrack = nil
                self?.state.volumeTemp?.value = .init(volume: 0.5, temp: 0.5)
            }
            self?.onTrackDeleted?(track)
            self?.state.tracks.remove(value: track)
        }
        
        state.$tracks
            .sink { [weak self] in
                self?.trackControlView.updateTracks($0.array())
            }
            .store(in: &cancellables)
        
        state.$currentTrack
            .sink {[weak self] (track) in
                guard let track = track else { return }
                self?.onTrackChanged?(track)
                self?.state.tracks.update(value: track, toValue: track)
                self?.trackControlView.updateTrack(track)
            }
            .store(in: &cancellables)
        
        setupLine(max: 1.0, values: Array(repeating: [0.1], count: 60))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        let aq = AnimationQueue(function: .init(duration: 0.2, timingFunction: .easeOut))
        
        let padding = Constants.padding
        let bottomViewHeight = Constants.bottomViewHeight
        
        contentView.frame = CGRect(
            x: padding,
            y: padding + safeAreaInsets.top,
            width: bounds.width - 2 * padding,
            height: bounds.height - 2 * padding - safeAreaInsets.top - safeAreaInsets.bottom - bottomViewHeight
        )
        
        var blurViewAlpha = 1.0
        if state.isBlurShowing != true {
            blurViewAlpha = 0.0
        }
        aq.animateAlpha(blurView.layer, from: blurView.alpha, to: blurViewAlpha)
        blurView.frame = contentView.bounds
        
        instrumentsControlView.frame = .init(
            x: 0,
            y: 0,
            width: contentView.bounds.width,
            height: Constants.instrumentsControlViewHeight
        )
        
        let volumeTempControlViewHeight = contentView.bounds.height - Constants.instrumentsControlViewHeight - Constants.volumeTempControlViewTopInset
        volumeTempControlView.frame = .init(
            x: 0,
            y: Constants.instrumentsControlViewHeight + Constants.volumeTempControlViewTopInset,
            width: contentView.bounds.width,
            height: volumeTempControlViewHeight
        )
        
        actionControlView.frame = .init(
            x: padding,
            y: bounds.height - padding - safeAreaInsets.bottom - 40.0,
            width: contentView.bounds.width,
            height: 40.0
        )
        
        audioPreviewView.frame = .init(
            x: padding,
            y: contentView.frame.maxY + 13,
            width: contentView.bounds.width,
            height: 50
        )
        
        var trackSliderViewY = audioPreviewView.frame.maxY - 200
        var trackSliderViewAlpha = 1.0
        if state.isLayersShowing != true {
            trackSliderViewY += 60
            trackSliderViewAlpha = 0.0
        }
        let trackSliderViewRect = CGRect(
            x: padding,
            y: trackSliderViewY,
            width: contentView.bounds.width,
            height: 200
        )
        
        aq.animateFrame(trackControlView.layer, to: trackSliderViewRect)
        aq.animateAlpha(trackControlView.layer, from: trackControlView.alpha, to: trackSliderViewAlpha)
        aq.commit()
        
    }
    
}

#if DEBUG
import SwiftUI
struct Provider_BandView: PreviewProvider {
    static var previews: some View {
        AnyView(BandView())
            .background(Color.black)
    }
}
#endif

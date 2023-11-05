//
//  TrackControlView.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

private enum Constants {
    static let sliderHeight: CGFloat = 50
    static let spacing: CGFloat = 10
    static let scrollViewMaxHeight = 300
}

struct TrackData: Identifiable {
    var id = UUID()
    var name: String
    var sample: Sample
    var volumeTemp: VolumeTempData?
}

extension TrackData: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension TrackData {
    func update(name: String? = nil, sample: Sample? = nil, volumeTemp: VolumeTempData? = nil) -> TrackData {
        return .init(id: id, name: name ?? self.name, sample: sample ?? self.sample, volumeTemp: volumeTemp ?? self.volumeTemp)
    }
}

final class TrackControlView: UIView {
    
    var onTrackSelected: ((TrackData) -> Void)?
    var onTrackDeleted: ((TrackData) -> Void)?
    
    private func _sliderView(_ t: TrackData) -> TrackSliderView {
        let v = TrackSliderView(name: t.name, volume: t.volumeTemp?.volume ?? 0)
        v.transform = CGAffineTransform(rotationAngle: .pi)
        v.onDelete = { [weak self] in
            if let value = self?.dataSource.value(t) {
                self?.onTrackDeleted?(value)
            }
        }
        v.onTap { [weak self] in
            if let value = self?.dataSource.value(t) {
                self?.onTrackSelected?(value)
            }
        }
        return v
    }
    
    func updateTrack(_ track: TrackData) {
        self.dataSource.updateValue(
            track,
            changeObject: { object in
                if let volume = track.volumeTemp?.volume {
                    object?.volume = volume
                }
            }
        )
    }
    
    func updateTracks(_ tracks: [TrackData]) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.dataSource.updateValues(
                tracks,
                createObject: { track in
                    self._sliderView(track)
                },
                addObject: { slider in
                    self.scrollView.addSubview(slider)
                },
                removeObject: { slider in
                    slider.removeFromSuperview()
                },
                completion: {
                    self.updateLayout()
                }
            )
        }
    }
    
    private let dataSource: DataSource<TrackData, TrackSliderView> = DataSource()
    private lazy var scrollView = UIScrollView()
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(scrollView)
        scrollView.transform = CGAffineTransform(rotationAngle: .pi)
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
        
        let sliderWidth = bounds.width
        let sliderHeight = Constants.sliderHeight
        let spacing = Constants.spacing
        
        scrollView.frame = bounds
        
        let scrollViewHeight = CGFloat(dataSource.objects.count) * (sliderHeight + spacing) - spacing
        scrollView.contentSize = .init(width: sliderWidth, height: scrollViewHeight)
                
        for i in dataSource.objects.indices {
            guard let slider = dataSource.objects[safe: i]?.value else { continue }
            let sliderY = scrollViewHeight - CGFloat(i + 1) * (sliderHeight + spacing) + spacing
            let sliderRect = CGRect(x: 0, y: sliderY, width: sliderWidth, height: sliderHeight)
            aq.animateFrame(slider.layer, to: sliderRect)
            slider.layer.cornerRadius = 8
            aq.commit()
        }
                        
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let rect = CGRect(
            x: 0,
            y: max(0, scrollView.bounds.height - scrollView.contentSize.height),
            width: scrollView.contentSize.width,
            height: scrollView.contentSize.height
        )
        return rect.contains(point) ? super.hitTest(point, with: event) : nil
    }
    
}

#if DEBUG
import SwiftUI
struct Provider_TrackControlView: PreviewProvider {
    static var previews: some View {
        AnyView(TrackControlView())
            .frame(height: 400)
            .background(Color.gray)
    }
}
#endif

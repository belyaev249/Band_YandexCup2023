//
//  DemoBand.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import AVFoundation
import UIKit

final class Player: ObservableObject {
    private let queue = DispatchQueue(label: "queue.player.\(UUID().uuidString)", qos: .userInitiated, attributes: .concurrent)
    private var players: [TrackData.ID: AVAudioPlayer] = [:]
    private var currentPlayer: AVAudioPlayer?
    
    func reset() {
        currentPlayer?.stop()
        currentPlayer = nil
        for (_, p) in players {
            p.stop()
        }
    }
    
    func volume(_ value: Float, forTrack: TrackData) {
        queue.async {[weak self] in
            self?.players[forTrack.id]?.volume = value
        }
    }
    
    func temp(_ value: Float, forTrack: TrackData) {
        queue.async {[weak self] in
            self?.players[forTrack.id]?.rate = value
        }
    }
    
    func remove(forTrack: TrackData) {
        players[forTrack.id]?.stop()
        players[forTrack.id] = nil
    }
    
    func set(_ url: URL, volume: Float?, temp: Float?, isLoop: Bool = false, forTrack: TrackData?) {
        reset()
        
        guard let data = try? Data(contentsOf: url) else { return }
        
        queue.async {[weak self] in
            
            do {
                let player = try AVAudioPlayer(data: data)
                player.volume = volume ?? 1.0
                player.enableRate = true
                player.rate = temp ?? 1.0
                player.numberOfLoops = isLoop ? -1 : 1
                player.play()
                if let forTrack {
                    self?.players[forTrack.id] = player
                } else {
                    self?.currentPlayer = player
                }
            } catch {
                print(error)
            }
            
        }
        
    }
    
    func all(_ isPlay: Bool) {
        for (_, p) in players {
            if isPlay {
                p.stop()
                p.currentTime = 0
                p.play()
            } else {
                p.stop()
            }
        }
    }
    
}

final class Recorder {
    private var recorder: AVAudioRecorder?
    
    func stop(_ c: @escaping (URL?) -> Void) {
        recorder?.stop()
        c(recorder?.url)
        recorder = nil
    }
    
    func record(_ fileName: String, _ c: @escaping (Bool) -> Void) {
        checkPermission { [weak self] allowed in
            let url = FileManager.default.getFileUrl(fileName)
            c(allowed == true)
            if allowed, allowed == true {
                let session = AVAudioSession.sharedInstance()
                do {
                    try session.setCategory(AVAudioSession.Category.record, options: .defaultToSpeaker)
                    try session.setActive(true)
                    let settings = [
                        AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 44100,
                        AVNumberOfChannelsKey: 2,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                    ]
                    self?.recorder = try AVAudioRecorder(url: url, settings: settings)
                    self?.recorder?.record()
                } catch {
                    
                }
            }
        }
    }
    
    private func checkPermission(_ c: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                c(true)
            case AVAudioSession.RecordPermission.denied:
                c(false)
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            case AVAudioSession.RecordPermission.undetermined:
                AVAudioSession.sharedInstance().requestRecordPermission({ (allowed) in
                    c(allowed)
                })
            default:
                break
            }
        }
    }
    
}

#if DEBUG
import SwiftUI
struct Provider_DemoBand: PreviewProvider {
    static var previews: some View {
        AnyView(BandView())
            .background(Color.green)
    }
}
#endif

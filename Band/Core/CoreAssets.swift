//
//  CoreAssets.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import UIKit

enum CoreAssets {
    struct CoreImage {
        let name: String
    }
    static let drum_icon: CoreImage = .init(name: "drum_icon")
    static let guitar_icon: CoreImage = .init(name: "guitar_icon")
    static let wind_icon: CoreImage = .init(name: "wind_icon")
    
    static let rec_icon: CoreImage = .init(name: "rec_icon")
    static let play_icon: CoreImage = .init(name: "play_icon")
    static let mic_icon: CoreImage = .init(name: "mic_icon")
    
    static let audioOn_icon: CoreImage = .init(name: "audioon_icon")
    static let audioOff_icon: CoreImage = .init(name: "audiooff_icon")
    
    static let pause_icon: CoreImage = .init(name: "pause_icon")
    
    static let cross_icon: CoreImage = .init(name: "cross_icon")
    static let chevron_icon: CoreImage = .init(name: "chevron_icon")
}

extension CoreAssets.CoreImage {
    var image: UIImage? {
        UIImage(named: self.name)
    }
}

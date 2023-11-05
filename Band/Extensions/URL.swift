//
//  URL.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import Foundation

extension URL {
    enum Extension {
        static let mp3 = "mp3"
        static let wav = "wav"
    }
}

extension URL.Extension {
    static let audio: [String] = [Self.mp3, Self.wav]
}

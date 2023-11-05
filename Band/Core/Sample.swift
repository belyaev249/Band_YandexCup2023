//
//  Sample.swift
//  Band
//
//  Created by Egor on 02.11.2023.
//

import Foundation

struct Sample: Equatable {
    var url: URL?
    let path: String
    let name: String
    init(path: String, name: String) {
        self.path = path
        self.name = name
        self.url = _url
    }
    init(name: String, url: URL?) {
        self.name = name
        self.url = url
        self.path = ""
    }
}

extension Sample {
    static let guitar1 = Sample(path: "acoustic_134_BPM", name: "Гитара 1")
    static let guitar2 = Sample(path: "summer_guitar_104_BPM", name: "Гитара 2")
    static let guitar3 = Sample(path: "pop rock guitar_60bpm", name: "Гитара 3")
    
    static let drum1 = Sample(path: "boom bap drums_94bpm", name: "Ударные 1")
    static let drum2 = Sample(path: "retro pop drums 120bpm", name: "Ударные 2")
    static let drum3 = Sample(path: "true school drums_84bpm", name: "Ударные 3")
    
    static let w1 = Sample(path: "eastern flute_80bpm", name: "Духовые 1")
    static let w2 = Sample(path: "dope vinyl flute_60bpm", name: "Духовые 2")
    static let w3 = Sample(path: "hardcore trap synths 66bpm", name: "Духовые 3")
    
    static let m1 = Sample(path: "m1", name: "Другое1")
    static let m2 = Sample(path: "m2", name: "Другое2")
}

private extension Sample {
    var _url: URL? {
        for ext in URL.Extension.audio {
            if let url = Bundle.main.url(forResource: path, withExtension: ext) {
                return url
            }
        }
        return nil
    }
}

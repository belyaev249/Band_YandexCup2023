//
//  UIColor.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

extension UIColor {
    convenience init(light: UIColor, dark: UIColor) {
        self.init { tc in
            if tc.userInterfaceStyle == .light {
                return light
            }
            return dark
        }
    }
}

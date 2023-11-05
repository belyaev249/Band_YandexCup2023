//
//  UIScrollView.swift
//  Band
//
//  Created by Egor on 01.11.2023.
//

import UIKit

extension UIScrollView {
    func scrollToBottom(_ animated: Bool = false) {
        setContentOffset(.init(x: 0, y: contentSize.height - bounds.height), animated: animated)
    }
}

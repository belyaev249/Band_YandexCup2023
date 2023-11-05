//
//  NSObject.swift
//  Band
//
//  Created by Egor on 05.11.2023.
//

import UIKit

extension UIView {
    func copyView<T: UIView>() -> T? {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as? T
    }
}

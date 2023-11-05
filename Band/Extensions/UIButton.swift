//
//  UIButton.swift
//  Band
//
//  Created by Egor on 03.11.2023.
//

import UIKit

extension Selector {
    final class Perform: NSObject {
    public init(_ perform: @escaping () -> Void) {
      self.perform = perform
      super.init()
    }
    private let perform: () -> Void
  }
}

private final class TapGestureRecognizer: UITapGestureRecognizer {
    init(_ perform: @escaping () -> Void) {
        self.perform = .init(perform)
        super.init(target: self.perform, action: self.perform.selector)
    }
    let perform: Selector.Perform
}

extension Selector.Perform {
  @objc private func callAsFunction() { perform() }
  var selector: Selector { #selector(callAsFunction) }
}

extension UIButton {
    override func onTap(_ a: @escaping () -> Void) {
        addAction(.init(handler: { _ in a() }), for: .touchUpInside)
    }
}

extension UIView {
    @objc func onTap(_ a: @escaping () -> Void) {
        let g = TapGestureRecognizer(a)
        addGestureRecognizer(g)
    }
}

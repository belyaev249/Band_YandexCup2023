//
//  BadgeControlView.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

private enum Constants {
    static let padding: CGFloat = 7
}

final class BadgeControlView: UIView {
    
    lazy var labelView: UILabel = {
        var v = UILabel()
        v.text = "Громкость"
        return v
    }()
    
    init(_ text: String = String()) {
        super.init(frame: .zero)
        backgroundColor = .black
        addSubview(labelView)
        labelView.text = text
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLayout(onTouch: Bool, value: Double) -> CGSize {
        labelView.sizeToFit()
        let w = labelView.bounds.width + 2 * Constants.padding
        let h = labelView.bounds.height + Constants.padding / 2.0
        labelView.frame.origin = .init(
            x: Constants.padding,
            y: Constants.padding / 4.0
        )
        return .init(
            width: w,
            height: h
        )
    }
    
}

#if DEBUG
import SwiftUI
struct Provider_BadgeControlView: PreviewProvider {
    static var previews: some View {
        AnyView(LineControlView())
            .frame(height: 100)
            .background(Color.green)
    }
}
#endif


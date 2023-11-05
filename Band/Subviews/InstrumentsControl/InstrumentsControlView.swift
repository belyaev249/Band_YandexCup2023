//
//  InstrumentsControlView.swift
//  Band
//
//  Created by Egor on 31.10.2023.
//

import UIKit

private enum Constants {
    static let spacing: CGFloat = 50
}

final class InstrumentsControlView: UIView {
    var onFocusItem: ((Sample?) -> Void)?
    var onSelectItem: ((Sample?) -> Void)?
    var onChooseItem: ((Sample?) -> Void)?
    
    private var controls: [WeakObject<DropDownButton>] = []
    
    private lazy var scrollView: UIScrollView = {
        var v = UIScrollView()
        
        return v
    }()
    
    init(_ items: [Item]) {
        super.init(frame: .zero)
                
        for item in items {
            let v = DropDownButton(
                item.items,
                contentImage: item.image,
                text: item.text
            )
            
            v.onSelect = { [weak self] in
                self?.onSelectItem?(item.current)
            }
            
            v.onChoose = { [weak self] (sample) in
                self?.onChooseItem?(sample)
            }
            
            v.onFocus = { [weak self] (sample) in
                self?.onFocusItem?(sample)
            }
            
            addSubview(v)
            controls.append(.init(v))
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func updateLayout() {
        scrollView.frame = bounds
        
        let lenght = bounds.width - CGFloat(controls.count - 1) * Constants.spacing
        let side = min((lenght / CGFloat(controls.count)), bounds.height)
        let spacing = (bounds.width - CGFloat(controls.count) * side) / CGFloat(controls.count - 1)
        
        if !controls.isEmpty {
            for i in 0...controls.count - 1 {
                let controlObj = controls[i]
                controlObj.value?.frame = .init(
                    x: (side + spacing) * CGFloat(i),
                    y: 0,
                    width: side,
                    height: side
                )
            }
        }
        
        let scrollViewWidth = controls.last?.value?.frame.maxX ?? .zero
        scrollView.contentSize = .init(width: scrollViewWidth, height: bounds.height)
        
    }
    
}

extension InstrumentsControlView {
    struct Item {
        let image: UIImage?
        let text: String
        let current: Sample
        let items: [Sample]
    }
}

#if DEBUG
import SwiftUI
struct Provider_InstrumentsControlView: PreviewProvider {
    private static let items: [InstrumentsControlView.Item] = [
        .init(image: .init(systemName: "plus"), text: "dwqdwq", current: .m1, items: [.guitar1, .guitar2, .guitar3]),
        .init(image: .init(systemName: "paperplane"), text: "dqwdqw", current: .m1, items: [.guitar1, .guitar1, .guitar1]),
        .init(image: .init(systemName: "plus"), text: "swqsw", current: .m1, items: [.guitar1, .guitar1, .guitar1]),
    ]
    static var previews: some View {
        AnyView(InstrumentsControlView(items))
            .frame(height: 300)
            .background(Color.green)
    }
}
#endif

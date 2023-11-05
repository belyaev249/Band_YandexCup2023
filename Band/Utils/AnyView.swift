//
//  AnyView.swift
//  Band
//
//  Created by Egor on 30.10.2023.
//

#if DEBUG
import SwiftUI
struct AnyView: UIViewRepresentable {
    private let contentView: UIView
    init(_ contentView: UIView) {
        self.contentView = contentView
    }
    init(_ contentView: UIViewController) {
        self.contentView = contentView.view
    }
    func makeUIView(context: Context) -> UIView {
        contentView
    }
    func updateUIView(_ uiView: UIView, context: Context) {
    }
}
#endif

//
//  Shimmer.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay {
                GeometryReader { proxy in
                    let width = proxy.size.width
                    LinearGradient(
                        colors: [
                            .clear,
                            Color.white.opacity(0.6),
                            .clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .rotationEffect(.degrees(20))
                    .offset(x: phase * width)
                    .blendMode(.plusLighter)
                    .onAppear {
                        withAnimation(.linear(duration: 1.1).repeatForever(autoreverses: false)) {
                            phase = 1.2
                        }
                    }
                }
            }
            .clipped()
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}

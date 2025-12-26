//
//  RepoRowStyle.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

enum RepoRowStyle {
    static let cornerRadius: CGFloat = 18
    static let verticalPadding: CGFloat = 12
    static let horizontalPadding: CGFloat = 14

    static func cardFill(_ colorScheme: ColorScheme) -> Color {
        colorScheme == .dark
            ? Color(UIColor.secondarySystemBackground)
            : Color(UIColor.systemBackground)
    }

    static func accent(for fork: Bool?) -> Color {
        fork == true ? .orange : .blue
    }

    static func shadowSoft(_ colorScheme: ColorScheme) -> (Color, CGFloat, CGFloat) {
        colorScheme == .dark
            ? (.black.opacity(0.22), 6, 3)
            : (.black.opacity(0.04), 6, 3)
    }

    static func shadowCrisp(_ colorScheme: ColorScheme) -> (Color, CGFloat, CGFloat) {
        colorScheme == .dark
            ? (.black.opacity(0.14), 2, 1)
            : (.black.opacity(0.025), 2, 1)
    }
}

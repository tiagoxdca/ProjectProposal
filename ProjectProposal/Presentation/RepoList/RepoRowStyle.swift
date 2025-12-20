//
//  RepoRowStyle.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

enum RepoRowStyle {
    static func backgroundColor(for fork: Bool?) -> Color {
        // light green if fork is false OR missing
        if fork == true { return .white }
        return Color.green.opacity(0.12)
    }
}

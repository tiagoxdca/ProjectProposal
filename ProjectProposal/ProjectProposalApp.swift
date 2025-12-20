//
//  ProjectProposalApp.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI
import SwiftData

@main
struct ProjectProposalApp: App {
    private let root = AppCompositionRoot()

    var body: some Scene {
        WindowGroup {
            root.factory.makeRepoListView()
        }
        .modelContainer(root.container)
    }
}

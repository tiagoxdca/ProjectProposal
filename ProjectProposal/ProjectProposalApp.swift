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
    @State private var router = AppRouter()

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                root.factory.makeRepoListView(router: router)
                    .navigationDestination(for: AppRoute.self) { route in
                        switch route {
                        case .repoDetails(let repo):
                            RepoDetailsView(repo: repo)
                        }
                    }
            }
        }
        .modelContainer(root.container)
    }
}

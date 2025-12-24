//
//  RepoListLoadedScreen.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 24/12/2025.
//

import SwiftUI

struct RepoListLoadedScreen: View {
    let repos: [Repo]
    let showFooterLoading: Bool
    let hasMore: Bool
    let errorMessage: String?

    let onLoadNextPageIfPossible: @MainActor @Sendable () async -> Void
    let onTap: (Repo) -> Void
    let onLongPress: (Repo) -> Void
    let onDismissError: () -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                RepoListErrorBanner(message: errorMessage, onDismiss: onDismissError)

                RepoListRows(
                    repos: repos,
                    onTap: onTap,
                    onLongPress: onLongPress
                )

                if showFooterLoading {
                    ProgressView().padding()
                }

                if hasMore {
                    Color.clear
                        .frame(height: 1)
                        .task(id: repos.last?.id ?? -1) {
                            await onLoadNextPageIfPossible()
                        }
                }
            }
            .padding(.vertical, 12)
            .animation(.easeInOut, value: errorMessage)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}

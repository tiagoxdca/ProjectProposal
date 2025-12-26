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
            LazyVStack(spacing: 16) {
                RepoListRows(
                    repos: repos,
                    onTap: onTap,
                    onLongPress: onLongPress
                )

                if showFooterLoading {
                    ProgressView().padding()
                }
                
                RepoListErrorBanner(message: errorMessage, onDismiss: onDismissError)

                if hasMore {
                    Color.clear
                        .frame(height: 1)
                        .task(id: repos.last?.id ?? -1) {
                            await onLoadNextPageIfPossible()
                        }
                }
            }
            .padding(.vertical, 16)
            .animation(.easeInOut, value: errorMessage)
        }
        .background(Color(uiColor: .systemBackground))

    }
}

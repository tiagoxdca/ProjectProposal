//
//  RepoListScreen.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 23/12/2025.
//

import SwiftUI

struct RepoListScreen: View {
    let state: RepoListViewState
    let onRefreshTapped: @MainActor @Sendable () -> Void
    let onLoadNextPageIfPossible: @MainActor @Sendable () async -> Void
    let onTap: (Repo) -> Void
    let onLongPress: (Repo) -> Void
    let onDismissError: () -> Void
    
    @ViewBuilder var body: some View {
        switch state.uiState {
            
        case .loadingInitial:
            RepoListLoadingView()
            
        case .error(let message):
            RepoListErrorView(message: message, onRetry: onRefreshTapped)
            
        case .empty:
            RepoListEmptyView { onRefreshTapped() }
            
        case .content:
            RepoListLoadedScreen(
                repos: state.repos,
                showFooterLoading: state.phase == .loadingMore && state.hasMore,
                hasMore: state.hasMore,
                errorMessage: state.errorMessage,
                onLoadNextPageIfPossible: { @MainActor in
                    await onLoadNextPageIfPossible()
                },
                onTap: onTap,
                onLongPress: onLongPress,
                onDismissError: onDismissError
            )
        }
    }
}

#Preview("Loaded") {
    let samples: [Repo] = [
        Repo(
            id: 1,
            name: "swift",
            description: "The Swift Programming Language",
            fork: false,
            repoURL: URL(string: "https://github.com/apple/swift")!,
            ownerLogin: "apple",
            ownerURL: URL(string: "https://github.com/apple")!
        ),
        Repo(
            id: 2,
            name: "swift-nio",
            description: "Event-driven network application framework for high performance",
            fork: true,
            repoURL: URL(string: "https://github.com/apple/swift-nio")!,
            ownerLogin: "apple",
            ownerURL: URL(string: "https://github.com/apple")!
        )
    ]
    
    return RepoListScreen(
        state: RepoListViewState(repos: samples, phase: .idle, hasMore: false, errorMessage: nil),
        onRefreshTapped: { @MainActor in },
        onLoadNextPageIfPossible: { @MainActor in },
        onTap: { _ in },
        onLongPress: { _ in },
        onDismissError: {}
    )
}

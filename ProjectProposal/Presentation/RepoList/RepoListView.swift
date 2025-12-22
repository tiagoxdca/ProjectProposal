//
//  RepoListView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

struct RepoListView: View {
    @State private var selectedRepo: Repo?
    @State private var showOpenDialog = false

    @Environment(\.openURL) private var openURL

    let viewModel: RepoListViewModel
    let router: AppRouter

    var body: some View {
        RepoListScreen(
            state: viewModel.state,
            onRefresh: { await viewModel.refresh() },
            onLoadMoreIfNeeded: { repo in viewModel.loadMoreIfNeeded(currentItem: repo) },
            onTap: { repo in
                router.push(.repoDetails(repo))
            },
            onLongPress: { repo in
                selectedRepo = repo
                showOpenDialog = true
            }
        )
        .navigationTitle("Apple Repos")
        .task { viewModel.onAppear() }
        .refreshable { await viewModel.refresh() }
        .confirmationDialog("Open in browser", isPresented: $showOpenDialog, titleVisibility: .visible) {
            if let repo = selectedRepo {
                Button("Open repository") { openURL(repo.repoURL) }
                Button("Open owner") { openURL(repo.ownerURL) }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
}

// MARK: - Screen (render by state)

private struct RepoListScreen: View {
    let state: RepoListViewState
    let onRefresh: @Sendable () async -> Void
    let onLoadMoreIfNeeded: (Repo) -> Void
    let onTap: (Repo) -> Void
    let onLongPress: (Repo) -> Void

    var body: some View {
        switch state {
        case .idle, .loading:
            RepoListLoadingView()

        case .failed(let message):
            RepoListErrorView(message: message) {
                Task { await onRefresh() }
            }

        case .loaded(let loaded):
            if loaded.repos.isEmpty {
                RepoListEmptyView {
                    Task { await onRefresh() }
                }
            } else {
                RepoListContentView(
                    repos: loaded.repos,
                    showFooterLoading: loaded.isLoadingMore,
                    onLoadMoreIfNeeded: onLoadMoreIfNeeded,
                    onTap: onTap,
                    onLongPress: onLongPress
                )
            }
        }
    }
}

private struct RepoListLoadingView: View {
    var body: some View {
        RepoListSkeletonView()
    }
}

private struct RepoListErrorView: View {
    let message: String
    let onRetry: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("Something went wrong").font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Button("Try again", action: onRetry)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct RepoListContentView: View {
    let repos: [Repo]
    let showFooterLoading: Bool
    let onLoadMoreIfNeeded: (Repo) -> Void
    let onTap: (Repo) -> Void
    let onLongPress: (Repo) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 10) {
                ForEach(repos) { repo in
                    RepoRowView(repo: repo)
                        .onAppear { onLoadMoreIfNeeded(repo) }
                        .onTapGesture { onTap(repo) }
                        .onLongPressGesture { onLongPress(repo) }
                        .padding(.horizontal, 12)
                }

                if showFooterLoading {
                    ProgressView().padding()
                }
            }
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemGroupedBackground))
    }
}


// MARK: Previous

//#Preview("Loading") {
//    RepoListScreen(
//        state: .loading,
//        onRefresh: {},
//        onLoadMoreIfNeeded: { _ in },
//        onLongPress: { _ in }
//    )
//}
//
//#Preview("Empty") {
//    RepoListScreen(
//        state: .loaded(.init(repos: [], isLoadingMore: false)),
//        onRefresh: {},
//        onLoadMoreIfNeeded: { _ in },
//        onLongPress: { _ in }
//    )
//}

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
    
    RepoListScreen(
        state: .loaded(.init(repos: samples, isLoadingMore: false)),
        onRefresh: {},
        onLoadMoreIfNeeded: { _ in },
        onTap: { _ in },
        onLongPress: { _ in }
    )
}

//#Preview("Error") {
//    RepoListScreen(
//        state: .failed(message: "Network request failed."),
//        onRefresh: {},
//        onLoadMoreIfNeeded: { _ in },
//        onLongPress: { _ in }
//    )
//}

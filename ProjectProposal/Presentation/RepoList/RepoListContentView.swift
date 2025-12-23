//
//  RepoListContentView.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 23/12/2025.
//

import SwiftUI

struct RepoListContentView: View {
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
                errorBanner

                ForEach(repos) { repo in
                    RepoRowView(repo: repo)
                        .contentShape(Rectangle())
                        .onTapGesture { onTap(repo) }
                        .onLongPressGesture { onLongPress(repo) }
                        .padding(.horizontal, 12)
                }

                // Footer loading
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

    @ViewBuilder
    private var errorBanner: some View {
        if let errorMessage {
            HStack(alignment: .firstTextBaseline, spacing: 10) {
                Label(errorMessage, systemImage: "exclamationmark.triangle.fill")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer(minLength: 8)

                Button {
                    onDismissError()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Dismiss error")
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 12)
            .contentShape(Rectangle())
            .onTapGesture { onDismissError() }
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

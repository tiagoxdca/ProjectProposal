//
//  RepoListViewModel.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation
import Observation

@MainActor
@Observable
final class RepoListViewModel {
    private let useCases: RepoListUseCases

    private(set) var state: RepoListViewState = .idle

    init(useCases: RepoListUseCases) {
        self.useCases = useCases
    }

    func onAppear() async {
        await loadCachedThenRefreshIfNeeded()
    }

    func refresh() async {
        let hadContent: Bool
        let currentRepos: [Repo]

        switch state {
        case .loaded(let loaded):
            hadContent = true
            currentRepos = loaded.repos
        default:
            hadContent = false
            currentRepos = []
        }

        if !hadContent {
            await setState(.loading)
        }

        do {
            let fresh = try await useCases.refresh.execute()
            await setState(.loaded(.init(repos: fresh, isLoadingMore: false)))
        } catch {
            if hadContent {
                // Mantém conteúdo existente (não destrói UX)
                await setState(.loaded(.init(repos: currentRepos, isLoadingMore: false)))
            } else {
                await setState(.failed(message: error.localizedDescription))
            }
        }
    }

    func loadMoreIfNeeded(currentItem item: Repo?) {
        guard let item else { return }

        let repos = state.repos
        guard !repos.isEmpty else { return }

        let thresholdIndex = repos.index(repos.endIndex, offsetBy: -3, limitedBy: repos.startIndex) ?? repos.startIndex
        guard repos.firstIndex(where: { $0.id == item.id }) == thresholdIndex else { return }

        Task { await loadNextPageKeepingContent() }
    }

    // MARK: - Private

    private func loadCachedThenRefreshIfNeeded() async {
        // 1) Cache-first (não bloquear UI)
        do {
            let cached = try await useCases.getCached.execute()
            if !cached.isEmpty {
                await setState(.loaded(.init(repos: cached, isLoadingMore: false)))
            } else {
                await setState(.loading)
            }
        } catch {
            await setState(.loading)
        }

        // 2) Refresh sempre ao abrir
        await refresh()
    }

    private func loadNextPageKeepingContent() async {
        // Só carrega mais se já estivermos com conteúdo
        guard case .loaded(var loaded) = state else { return }
        guard loaded.isLoadingMore == false else { return }

        loaded.isLoadingMore = true
        await setState(.loaded(loaded))

        do {
            let updated = try await useCases.loadNext.execute()
            await setState(.loaded(.init(repos: updated, isLoadingMore: false)))
        } catch {
            // Volta para loaded sem loadingMore e mantém lista
            await setState(.loaded(.init(repos: loaded.repos, isLoadingMore: false)))
        }
    }

    private func setState(_ newState: RepoListViewState) async {
        guard state != newState else { return }
        state = newState
    }
}

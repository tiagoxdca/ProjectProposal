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

    private(set) var state = RepoListViewState(repos: [], phase: .loadingInitial, hasMore: true)
    private var hasAppeared = false

    init(useCases: RepoListUseCases) {
        self.useCases = useCases
    }

    func onAppear() async {
        guard !hasAppeared else { return }
        hasAppeared = true
        await loadCachedThenRefresh()
    }

    func refresh() async {
        let hasContent = !state.repos.isEmpty

        // Só mostra skeleton/full loading se ainda não houver conteúdo
        if !hasContent {
            setPhase(.loadingInitial)
        }

        do {
            let page = try await useCases.refresh.execute()
            state = RepoListViewState(
                repos: page.repos,
                phase: .idle,
                hasMore: page.hasMore
            )
        } catch {
            // Se já há conteúdo, mantém e só garante idle
            if hasContent {
                setPhase(.idle)
            } else {
                // Sem enum de error/empty neste modelo: fica idle com repos vazios
                // (A tua View pode mostrar Empty State quando repos.isEmpty && phase != loadingInitial)
                state = RepoListViewState(repos: [], phase: .idle, hasMore: true)
            }
        }
    }

    func loadMoreIfNeeded(currentItem item: Repo?) {
        guard let item else { return }
        guard state.phase == .idle else { return }
        guard state.hasMore else { return }
        guard !state.repos.isEmpty else { return }

        let repos = state.repos
        let thresholdIndex =
            repos.index(repos.endIndex, offsetBy: -3, limitedBy: repos.startIndex) ?? repos.startIndex

        guard repos.firstIndex(where: { $0.id == item.id }) == thresholdIndex else { return }

        Task { await loadNextPage() }
    }

    // MARK: - Private

    private func loadCachedThenRefresh() async {
        // 1) Cache-first (do not block UI)
        do {
            let cached = try await useCases.getCached.execute()
            if !cached.isEmpty {
                state = RepoListViewState(repos: cached, phase: .idle, hasMore: true)
            } else {
                setPhase(.loadingInitial)
            }
        } catch {
            setPhase(.loadingInitial)
        }

        // 2) Always refresh on open
        await refresh()
    }

    private func loadNextPage() async {
        guard state.phase == .idle else { return }
        guard state.hasMore else { return }

        let previous = state.repos
        state = RepoListViewState(repos: previous, phase: .loadingMore, hasMore: state.hasMore)

        do {
            let page = try await useCases.loadNext.execute()

            // Seatbelt: never allow the list to shrink
            let stableRepos = page.repos.count >= previous.count ? page.repos : previous

            state = RepoListViewState(
                repos: stableRepos,
                phase: .idle,
                hasMore: page.hasMore
            )
        } catch {
            // Keep content, stop footer loading
            state = RepoListViewState(repos: previous, phase: .idle, hasMore: state.hasMore)
        }
    }

    private func setPhase(_ phase: Phase) {
        state = RepoListViewState(repos: state.repos, phase: phase, hasMore: state.hasMore)
    }
}

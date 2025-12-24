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
    
    private(set) var state = RepoListViewState(repos: [], phase: .loadingInitial, hasMore: true, errorMessage: nil)
    private var hasAppeared = false
    
    init(useCases: RepoListUseCases) {
        self.useCases = useCases
    }
    
    func onAppear() async {
        guard !hasAppeared else { return }
        hasAppeared = true
        await loadCachedThenRefresh()
    }
    
    func loadNextPageIfPossible() async {
        guard canLoadNextPage else { return }
        await loadNextPage()
    }
    
    func refresh() async {
        let hadContent = !state.repos.isEmpty
        if !hadContent {
            setState(phase: .loadingInitial, errorMessage: .some(nil))
        }
        
        do {
            let page = try await useCases.refresh.execute()
            setState(repos: page.repos, phase: .idle, hasMore: page.hasMore, errorMessage: .some(nil))
        } catch {
            handleRefreshError(error, hadContent: hadContent)
        }
    }
    
    func dismissError() {
        setState(errorMessage: .some(nil))
    }
    
    // MARK: - Private
    
    private var canLoadNextPage: Bool {
        state.phase == .idle && state.hasMore
    }
    
    private func loadNextPage() async {
        let previous = state.repos
        setState(phase: .loadingMore, errorMessage: .some(nil))
        
        do {
            let page = try await useCases.loadNext.execute()
            let stable = page.repos.count >= previous.count ? page.repos : previous // Defensive: avoid UI regression if repository returns a shorter list
            setState(repos: stable, phase: .idle, hasMore: page.hasMore, errorMessage: .some(nil))
        } catch {
            await handlePaginationError(error, previous: previous)
        }
    }
    
    private func loadCachedThenRefresh() async {
        let cached = (try? await useCases.getCached.execute()) ?? []
        if !cached.isEmpty {
            setState(repos: cached, phase: .idle, hasMore: true, errorMessage: .some(nil))
        } else {
            setState(phase: .loadingInitial, errorMessage: .some(nil))
        }
        
        await refresh()
    }
    
    private func updateState(_ transform: (RepoListViewState) -> RepoListViewState) {
        let newState = transform(state)
        guard newState != state else { return } // removeDuplicates
        state = newState
    }
    
    private func setState(repos: [Repo]? = nil,
                          phase: Phase? = nil,
                          hasMore: Bool? = nil,
                          errorMessage: String?? = nil) {
        updateState { current in
            RepoListViewState(repos: repos ?? current.repos,
                phase: phase ?? current.phase,
                hasMore: hasMore ?? current.hasMore,
                errorMessage: errorMessage ?? current.errorMessage)
        }
    }
    
    private func handleRefreshError(_ error: Error, hadContent: Bool) {
        if hadContent {
            setState(phase: .idle, errorMessage: .some("Couldn’t refresh. Showing cached results."))
        } else {
            setState(repos: [],
                     phase: .idle,
                     hasMore: true,
                     errorMessage: .some("Couldn’t load repositories. Check your connection and try again."))
        }
    }
    
    private func handlePaginationError(_ error: Error, previous: [Repo]) async {
        if Task.isCancelled || (error as? URLError)?.code == .cancelled {
            // cancellation is not an error
            setState(repos: previous, phase: .idle)
            return
        }
        
        setState(repos: previous, phase: .idle, errorMessage: .some("Couldn’t load more."))
    }
}

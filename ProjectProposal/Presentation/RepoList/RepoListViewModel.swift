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
    
    func refresh() async {
        let hasContent = !state.repos.isEmpty
        
        // Só mostra skeleton/full loading se ainda não houver conteúdo
        if !hasContent {
            setPhase(.loadingInitial, error: nil)
        }
        
        do {
            let page = try await useCases.refresh.execute()
            
            updateState { _ in
                RepoListViewState(repos: page.repos,
                                  phase: .idle,
                                  hasMore: page.hasMore,
                                  errorMessage: nil)
            }
        } catch {
            // If content already exists, keep it and only ensure idle state.
            if hasContent {
                setPhase(.idle, error: "Couldn’t refresh. Showing cached results.")
            } else {
                // This model has no error/empty enum: it remains idle with empty repos
                // (Your View can display an Empty State when repos.isEmpty && phase != loadingInitial)
                updateState { _ in
                    RepoListViewState(
                        repos: [],
                        phase: .idle,
                        hasMore: true,
                        errorMessage: "Couldn’t load repositories. Check your connection and try again."
                    )
                }
            }
        }
    }
    
    @MainActor
    func loadNextPageIfPossible() async {
        guard state.phase == .idle else { return }
        guard state.hasMore else { return }
        await loadNextPage()
    }
    
    func dismissError() {
        updateState { current in
            RepoListViewState(
                repos: current.repos,
                phase: current.phase,
                hasMore: current.hasMore,
                errorMessage: nil
            )
        }
    }
    
    // MARK: - Private
    
    private func loadCachedThenRefresh() async {
        // 1) Cache-first (do not block UI)
        do {
            let cached = try await useCases.getCached.execute()
            if !cached.isEmpty {
                
                updateState { _ in
                    RepoListViewState(repos: cached, phase: .idle, hasMore: true, errorMessage: nil)
                }
            } else {
                setPhase(.loadingInitial, error: nil)
            }
        } catch {
            setPhase(.loadingInitial, error: nil)
        }
        
        // 2) Always refresh on open
        await refresh()
    }
    
    private func loadNextPage() async {
        guard state.phase == .idle else { return }
        guard state.hasMore else { return }
        
        let previous = state.repos
        
        updateState { current in
            RepoListViewState(repos: previous, phase: .loadingMore, hasMore: current.hasMore, errorMessage: nil)
        }
        
        do {
            let page = try await useCases.loadNext.execute()
            
            // Seatbelt: never allow the list to shrink
            let stableRepos = page.repos.count >= previous.count ? page.repos : previous
            
            
            updateState { _ in
                RepoListViewState(repos: stableRepos, phase: .idle, hasMore: page.hasMore, errorMessage: nil)
            }
        } catch {
            
            if Task.isCancelled || (error as? URLError)?.code == .cancelled {
                updateState { current in
                    RepoListViewState(
                        repos: previous,
                        phase: .idle,
                        hasMore: current.hasMore,
                        errorMessage: current.errorMessage
                    )
                }
                return
            }
            
            // Keep content, stop footer loading
            updateState { current in
                RepoListViewState(repos: previous, phase: .idle, hasMore: current.hasMore, errorMessage: "Couldn’t load more.")
            }
        }
    }
    
    private func updateState(_ transform: (RepoListViewState) -> RepoListViewState) {
        let newState = transform(state)
        guard newState != state else { return } // removeDuplicates
        state = newState
    }
    
    private func setPhase(_ phase: Phase, error: String?) {
        updateState { current in
            RepoListViewState(
                repos: current.repos,
                phase: phase,
                hasMore: current.hasMore,
                errorMessage: error
            )
        }
    }
}

//
//  RepoListViewModelTests.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
import Testing
@testable import ProjectProposal

struct RepoListViewModelTests {
    
    @Test
    @MainActor
    func onAppear_showsCachedFirst_thenUpdatesWithRefresh() async throws {
        let state = RepoListUseCasesFakeState()
        
        let cached = [makeRepo(id: 1), makeRepo(id: 2)]
        let refreshed = [makeRepo(id: 1), makeRepo(id: 2), makeRepo(id: 3)]
        
        await state.setCached(.success(cached), delayNanos: 0)
        // Add delay so we can observe intermediate cached state
        await state.setRefresh(.success(refreshed), delayNanos: 200_000_000) // 200ms
        await state.setNext(.success([]), delayNanos: 0)
        
        let useCases = makeRepoListUseCasesFake(state: state)
        let sut = RepoListViewModel(useCases: useCases)
        
        sut.onAppear()
        
        // Should quickly show cached (loaded) before refresh completes
        await eventually {
            if case .loaded(let loaded) = sut.state {
                return loaded.repos.map(\.id) == [1, 2]
            }
            return false
        }
        
        // Then should update to refreshed list
        await eventually {
            if case .loaded(let loaded) = sut.state {
                return loaded.repos.map(\.id) == [1, 2, 3]
            }
            return false
        }
        
        let calls = await state.getCalls()
        #expect(calls.cached == 1)
        #expect(calls.refresh == 1)
    }
    
    @Test
    @MainActor
    func refresh_whenAlreadyLoaded_doesNotSwitchToLoadingState() async throws {
        let state = RepoListUseCasesFakeState()
        
        let cached = [makeRepo(id: 1)]
        let refreshed = [makeRepo(id: 1), makeRepo(id: 2)]
        
        await state.setCached(.success(cached), delayNanos: 0)
        await state.setRefresh(.success(refreshed), delayNanos: 250_000_000) // slow refresh
        
        let sut = RepoListViewModel(useCases: makeRepoListUseCasesFake(state: state))
        
        // Drive VM into loaded state via onAppear (cache-first)
        sut.onAppear()
        await eventually {
            if case .loaded = sut.state { return true }
            return false
        }
        
        // Trigger refresh explicitly
        let refreshTask = Task { await sut.refresh() }
        
        // Immediately after starting refresh, it should remain loaded (not .loading)
        // This assumes you implemented the "keep content during refresh" logic.
        #expect(sut.state.isLoading == false)
        #expect(sut.state.repos.isEmpty == false)
        
        _ = await refreshTask.value
        
        await eventually {
            if case .loaded(let loaded) = sut.state {
                return loaded.repos.map(\.id) == [1, 2]
            }
            return false
        }
    }
    
    @Test
    @MainActor
    func loadMoreIfNeeded_setsIsLoadingMore_true_thenFalse_andKeepsContent() async throws {
        let state = RepoListUseCasesFakeState()
        
        let repos = [
            makeRepo(id: 1),
            makeRepo(id: 2),
            makeRepo(id: 3),
            makeRepo(id: 4),
            makeRepo(id: 5)
        ]
        let afterNext = repos + [makeRepo(id: 6)]
        
        await state.setCached(.success(repos), delayNanos: 0)
        // Make refresh return same data quickly so VM stabilizes
        await state.setRefresh(.success(repos), delayNanos: 0)
        // Slow next page so we can observe isLoadingMore = true
        await state.setNext(.success(afterNext), delayNanos: 200_000_000)
        
        let sut = RepoListViewModel(useCases: makeRepoListUseCasesFake(state: state))
        
        sut.onAppear()
        
        // Wait until stable loaded
        await eventually {
            if case .loaded(let loaded) = sut.state {
                return loaded.repos.count == 5 && loaded.isLoadingMore == false
            }
            return false
        }
        
        let loaded = try #require(
            { if case .loaded(let value) = sut.state { value } else { nil } }(),
            "Expected loaded state"
        )
        
        // Threshold item is endIndex - 3 (same logic as VM)
        let thresholdItem = loaded.repos[loaded.repos.count - 3] // id = 3
        
        sut.loadMoreIfNeeded(currentItem: thresholdItem)
        
        // Observe loadingMore becomes true (while keeping content)
        await eventually {
            if case .loaded(let s) = sut.state {
                return s.isLoadingMore == true && s.repos.count == 5
            }
            return false
        }
        
        // Then observe it becomes false and list is updated
        await eventually {
            if case .loaded(let s) = sut.state {
                return s.isLoadingMore == false && s.repos.map(\.id) == [1,2,3,4,5,6]
            }
            return false
        }
        
        let calls = await state.getCalls()
        #expect(calls.next == 1)
    }
}

// MARK: - Helpers

private func makeRepo(id: Int) -> Repo {
    Repo(id: id,
         name: "repo-\(id)",
         description: "desc-\(id)",
         fork: nil,
         repoURL: URL(string: "https://example.com/repo/\(id)")!,
         ownerLogin: "apple",
         ownerURL: URL(string: "https://example.com/owner")!)
}

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
        await state.setRefresh(.success(RepoPage(repos: refreshed, hasMore: true)),
                               delayNanos: 200_000_000) // 200ms

        await state.setNext(.success(RepoPage(repos: refreshed, hasMore: true)), delayNanos: 0)

        let useCases = makeRepoListUseCasesFake(state: state)
        let sut = RepoListViewModel(useCases: useCases)

        Task { await sut.onAppear() }

        // Should quickly show cached (repos) before refresh completes
        await eventually {
            sut.state.repos.map(\.id) == [1, 2] && sut.state.phase == .idle
        }

        // Then should update to refreshed list
        await eventually {
            sut.state.repos.map(\.id) == [1, 2, 3] && sut.state.phase == .idle
        }

        let calls = await state.getCalls()
        #expect(calls.cached == 1)
        #expect(calls.refresh == 1)
    }

    @Test
    @MainActor
    func refresh_whenAlreadyHasContent_doesNotSwitchToInitialLoading() async throws {
        let state = RepoListUseCasesFakeState()

        let cached = [makeRepo(id: 1)]
        let refreshed = [makeRepo(id: 1), makeRepo(id: 2)]

        await state.setCached(.success(cached), delayNanos: 0)

        // slow refresh so we can observe intermediate state
        await state.setRefresh(.success(RepoPage(repos: refreshed, hasMore: true)),
                               delayNanos: 250_000_000)

        let sut = RepoListViewModel(useCases: makeRepoListUseCasesFake(state: state))

        Task { await sut.onAppear() }

        // Wait until cache shown
        await eventually {
            sut.state.repos.map(\.id) == [1] && sut.state.phase == .idle
        }

        // Trigger refresh explicitly
        let refreshTask = Task { await sut.refresh() }

        // Immediately after starting refresh, it should keep existing content
        #expect(sut.state.repos.isEmpty == false)
        #expect(sut.state.phase != .loadingInitial)

        _ = await refreshTask.value

        await eventually {
            sut.state.repos.map(\.id) == [1, 2] && sut.state.phase == .idle
        }
    }

    @Test
    @MainActor
    func loadMoreIfNeeded_setsPhaseLoadingMore_thenIdle_andKeepsContent() async throws {
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
        await state.setRefresh(.success(RepoPage(repos: repos, hasMore: true)), delayNanos: 0)

        // Slow next page so we can observe phase = .loadingMore
        await state.setNext(.success(RepoPage(repos: afterNext, hasMore: true)),
                            delayNanos: 200_000_000)

        let sut = RepoListViewModel(useCases: makeRepoListUseCasesFake(state: state))

        Task { await sut.onAppear() }

        // Wait until stable idle with initial repos
        await eventually {
            sut.state.repos.count == 5 && sut.state.phase == .idle
        }

        // Threshold item is endIndex - 3 (same logic as VM)
        let thresholdItem = sut.state.repos[sut.state.repos.count - 3] // id = 3

        sut.loadMoreIfNeeded(currentItem: thresholdItem)

        // Observe loadingMore phase (while keeping content)
        await eventually {
            sut.state.phase == .loadingMore && sut.state.repos.count == 5
        }

        // Then observe it becomes idle and list is updated
        await eventually {
            sut.state.phase == .idle && sut.state.repos.map(\.id) == [1,2,3,4,5,6]
        }

        let calls = await state.getCalls()
        #expect(calls.next == 1)
    }
}

// MARK: - Helpers

private func makeRepo(id: Int) -> Repo {
    Repo(
        id: id,
        name: "repo-\(id)",
        description: "desc-\(id)",
        fork: nil,
        repoURL: URL(string: "https://example.com/repo/\(id)")!,
        ownerLogin: "apple",
        ownerURL: URL(string: "https://example.com/owner")!
    )
}

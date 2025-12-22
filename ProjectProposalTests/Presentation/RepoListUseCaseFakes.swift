//
//  RepoListUseCaseFakes.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
@testable import ProjectProposal

actor RepoListUseCasesFakeState {
    var cached: Result<[Repo], Error> = .success([])
    var refresh: Result<RepoPage, Error> = .success(.init(repos: [], hasMore: true))
    var next: Result<RepoPage, Error> = .success(.init(repos: [], hasMore: true))

    var cachedDelayNanos: UInt64 = 0
    var refreshDelayNanos: UInt64 = 0
    var nextDelayNanos: UInt64 = 0

    private(set) var cachedCalls = 0
    private(set) var refreshCalls = 0
    private(set) var nextCalls = 0

    func setCached(_ value: Result<[Repo], Error>, delayNanos: UInt64 = 0) {
        cached = value
        cachedDelayNanos = delayNanos
    }

    func setRefresh(_ value: Result<RepoPage, Error>, delayNanos: UInt64 = 0) {
        refresh = value
        refreshDelayNanos = delayNanos
    }

    func setNext(_ value: Result<RepoPage, Error>, delayNanos: UInt64 = 0) {
        next = value
        nextDelayNanos = delayNanos
    }

    func getCalls() -> (cached: Int, refresh: Int, next: Int) {
        (cachedCalls, refreshCalls, nextCalls)
    }

    func runCached() async throws -> [Repo] {
        cachedCalls += 1
        if cachedDelayNanos > 0 { try await Task.sleep(nanoseconds: cachedDelayNanos) }
        return try cached.get()
    }

    func runRefresh() async throws -> RepoPage {
        refreshCalls += 1
        if refreshDelayNanos > 0 { try await Task.sleep(nanoseconds: refreshDelayNanos) }
        return try refresh.get()
    }

    func runNext() async throws -> RepoPage {
        nextCalls += 1
        if nextDelayNanos > 0 { try await Task.sleep(nanoseconds: nextDelayNanos) }
        return try next.get()
    }
}

// Wrappers que implementam os protocols do Domain

struct GetCachedReposUseCaseFake: GetCachedReposUseCase {
    let state: RepoListUseCasesFakeState
    func execute() async throws -> [Repo] { try await state.runCached() }
}

struct RefreshReposUseCaseFake: RefreshReposUseCase {
    let state: RepoListUseCasesFakeState
    func execute() async throws -> RepoPage { try await state.runRefresh() }
}

struct LoadNextReposPageUseCaseFake: LoadNextReposPageUseCase {
    let state: RepoListUseCasesFakeState
    func execute() async throws -> RepoPage { try await state.runNext() }
}

// Convenience builder
func makeRepoListUseCasesFake(state: RepoListUseCasesFakeState) -> RepoListUseCases {
    RepoListUseCases(
        getCached: GetCachedReposUseCaseFake(state: state),
        refresh: RefreshReposUseCaseFake(state: state),
        loadNext: LoadNextReposPageUseCaseFake(state: state)
    )
}

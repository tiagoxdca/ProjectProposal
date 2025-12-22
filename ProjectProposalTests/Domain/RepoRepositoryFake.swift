//
//  RepoRepositoryFake.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
@testable import ProjectProposal

actor RepoRepositoryFake: RepoRepository {
    private var cachedResult: Result<[Repo], Error> = .success([])
    private var refreshResult: Result<RepoPage, Error> = .success(.init(repos: [], hasMore: true))
    private var nextResult: Result<RepoPage, Error> = .success(.init(repos: [], hasMore: true))

    private(set) var cachedCalls = 0
    private(set) var refreshCalls = 0
    private(set) var nextCalls = 0

    // MARK: - Configuration

    func setCachedResult(_ value: Result<[Repo], Error>) {
        cachedResult = value
    }

    func setRefreshResult(_ value: Result<RepoPage, Error>) {
        refreshResult = value
    }

    func setNextResult(_ value: Result<RepoPage, Error>) {
        nextResult = value
    }

    // MARK: - RepoRepository

    func cachedRepos() async throws -> [Repo] {
        cachedCalls += 1
        return try cachedResult.get()
    }

    func refresh() async throws -> RepoPage {
        refreshCalls += 1
        return try refreshResult.get()
    }

    func loadNextPage() async throws -> RepoPage {
        nextCalls += 1
        return try nextResult.get()
    }
}

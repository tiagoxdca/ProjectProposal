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
    private var refreshResult: Result<[Repo], Error> = .success([])
    private var nextResult: Result<[Repo], Error> = .success([])

    private(set) var cachedCalls = 0
    private(set) var refreshCalls = 0
    private(set) var nextCalls = 0

    // MARK: - Configuration (setters)

    func setCachedResult(_ value: Result<[Repo], Error>) {
        cachedResult = value
    }

    func setRefreshResult(_ value: Result<[Repo], Error>) {
        refreshResult = value
    }

    func setNextResult(_ value: Result<[Repo], Error>) {
        nextResult = value
    }

    // MARK: - RepoRepository

    func cachedRepos() async throws -> [Repo] {
        cachedCalls += 1
        return try cachedResult.get()
    }

    func refresh() async throws -> [Repo] {
        refreshCalls += 1
        return try refreshResult.get()
    }

    func loadNextPage() async throws -> [Repo] {
        nextCalls += 1
        return try nextResult.get()
    }
}

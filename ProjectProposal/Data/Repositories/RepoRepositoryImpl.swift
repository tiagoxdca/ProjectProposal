//
//  RepoRepositoryImpl.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public final actor RepoRepositoryImpl: RepoRepository {
    private let service: GitHubRepoServicing
    private let cache: RepoCacheStore
    private let user: String
    private let perPage: Int

    // Pagination state
    private var currentPage: Int = 1
    private var hasNext: Bool = true
    private var isLoading: Bool = false

    public init(service: GitHubRepoServicing,
        cache: RepoCacheStore,
        user: String = "apple",
        perPage: Int = 10) {
        self.service = service
        self.cache = cache
        self.user = user
        self.perPage = perPage
    }

    public func cachedRepos() async throws -> [Repo] {
        try await cache.fetchAll()
    }

    public func refresh() async throws -> [Repo] {
        // Reset paging and replace cache with the first page
        currentPage = 1
        hasNext = true

        let (dtos, next) = try await service.fetchRepos(user: user, page: currentPage, perPage: perPage)
        let repos = RepoMapper.map(dtos)

        try await cache.upsert(repos)

        hasNext = next
        currentPage = 2

        return repos
    }

    public func loadNextPage() async throws -> [Repo] {
        guard hasNext else { return try await cache.fetchAll() }
        guard !isLoading else { return try await cache.fetchAll() }

        isLoading = true
        defer { isLoading = false }

        let (dtos, next) = try await service.fetchRepos(user: user, page: currentPage, perPage: perPage)
        let repos = RepoMapper.map(dtos)

        // Append/update cache
        try await cache.upsert(repos)

        hasNext = next
        if next { currentPage += 1 }

        // Return full list from cache (single source of truth for UI)
        return try await cache.fetchAll()
    }
}

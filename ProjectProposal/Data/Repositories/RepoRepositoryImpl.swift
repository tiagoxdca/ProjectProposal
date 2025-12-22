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
    
    // Pagination state (repository responsibility)
    private var currentPage: Int = 1
    private var hasNext: Bool = true
    private var isLoading: Bool = false
    
    // In-memory accumulated list to preserve stable ordering
    private var accumulated: [Repo] = []
    
    public init(service: GitHubRepoServicing,
                cache: RepoCacheStore,
                user: String = "apple",
                perPage: Int = 10) {
        self.service = service
        self.cache = cache
        self.user = user
        self.perPage = perPage
    }
    
    // MARK: - Cache
    
    public func cachedRepos() async throws -> [Repo] {
        let cached = try await cache.fetchAll()
        // seed in-memory list once (preserve whatever order cache provides)
        if accumulated.isEmpty {
            accumulated = cached
        }
        return cached
    }
    
    // MARK: - Refresh
    
    public func refresh() async throws -> RepoPage {
        currentPage = 1
        hasNext = true

        let (dtos, next) = try await service.fetchRepos(
            user: user,
            page: currentPage,
            perPage: perPage
        )

        let repos = RepoMapper.map(dtos)

        try await cache.upsert(repos)

        // Replace in-memory list (stable order = API order)
        accumulated = repos

        hasNext = next
        currentPage = next ? 2 : 1

        return RepoPage(repos: accumulated, hasMore: hasNext)
    }
    
    // MARK: - Pagination
    
    public func loadNextPage() async throws -> RepoPage {
        guard hasNext else {
            return RepoPage(repos: accumulated, hasMore: false)
        }
        
        guard !isLoading else {
            return RepoPage(repos: accumulated, hasMore: hasNext)
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let (dtos, next) = try await service.fetchRepos(user: user,
                                                        page: currentPage,
                                                        perPage: perPage)
        let nextRepos = RepoMapper.map(dtos)
        
        // Persist (does not define ordering)
        try await cache.upsert(nextRepos)
        
        // ✅ Append unique while preserving existing order
        if !nextRepos.isEmpty {
            let existingIDs = Set(accumulated.map(\.id))
            let newOnes = nextRepos.filter { !existingIDs.contains($0.id) }
            accumulated.append(contentsOf: newOnes)
        }
        
        hasNext = next
        if next { currentPage += 1 }
        
        return RepoPage(repos: accumulated, hasMore: hasNext)
    }
}

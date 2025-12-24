//
//  RepoRepositoryImplTests.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
import Testing
@testable import ProjectProposal

struct RepoRepositoryImplTests {
    
    @Test
    func cachedRepos_returnsCacheContent() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()
        
        let seeded = [makeRepo(id: 1), makeRepo(id: 2)]
        await cache.seed(seeded)
        
        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)
        
        let result = try await sut.cachedRepos()
        
        #expect(result.map(\.id) == [1, 2])
        #expect(await cache.fetchCalls >= 1)
    }
    
    @Test
    func refresh_fetchesFirstPage_andUpsertsCache_andResetsPaging() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()
        
        await service.setPage(1, repos: [
            makeDTO(id: 101, name: "A"),
            makeDTO(id: 102, name: "B")
        ], hasNext: true)
        
        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)
        
        let fresh = try await sut.refresh()
        
        #expect(fresh.repos.map(\.id) == [101, 102])
        
        let cached = try await sut.cachedRepos()
        #expect(cached.map(\.id) == [101, 102])
        
        let calls = await service.calls
        #expect(calls.count == 1)
        #expect(calls.first?.page == 1)
    }
    
    @Test
    func loadNextPage_afterRefresh_fetchesSecondPage_andReturnsFullCache() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()
        
        await service.setPage(1, repos: [
            makeDTO(id: 1, name: "A")
        ], hasNext: true)
        
        await service.setPage(2, repos: [
            makeDTO(id: 2, name: "B")
        ], hasNext: false)
        
        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)
        
        _ = try await sut.refresh()
        let updated = try await sut.loadNextPage()
        
        #expect(updated.repos.map(\.id) == [1, 2])
        
        let calls = await service.calls
        #expect(calls.map(\.page) == [1, 2])
    }
    
    @Test
    func loadNextPage_whenNoNext_doesNotCallServiceAgain() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()
        
        await service.setPage(1, repos: [
            makeDTO(id: 1, name: "A")
        ], hasNext: false)
        
        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)
        
        _ = try await sut.refresh()
        _ = try await sut.loadNextPage()
        
        let calls = await service.calls
        #expect(calls.map(\.page) == [1]) // only refresh
    }
    
    @Test
    func refresh_replacesCacheAtomically_andPersistsNewRepos() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()

        // Seed cache with some existing data
        try await cache.upsert([makeRepo(id: 99)])

        // Remote returns a new page with a single repo
        await service.setPage(1, repos: [
            makeDTO(id: 1, name: "A")
        ], hasNext: true)

        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)

        _ = try await sut.refresh()

        // refresh now uses replaceAll -> should clear + upsert
        #expect(await cache.deleteAllCalls == 1)

        let cached = try await sut.cachedRepos()
        #expect(cached.map(\.id) == [1])
    }

    @Test
    func refresh_replacesReturnedRepos_evenWhenCacheHasOldData() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()

        // Cache has old/stale data
        try await cache.upsert([makeRepo(id: 1), makeRepo(id: 2)])

        // Remote returns a different dataset
        await service.setPage(1, repos: [
            makeDTO(id: 10, name: "X"),
            makeDTO(id: 11, name: "Y")
        ], hasNext: true)

        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)

        let refreshed = try await sut.refresh()

        #expect(refreshed.repos.map(\.id) == [10, 11])
        #expect(await cache.deleteAllCalls == 1)

        let cached = try await sut.cachedRepos()
        #expect(cached.map(\.id) == [10, 11])
    }
}

// MARK: - Helpers

private func makeDTO(id: Int, name: String) -> RepoDTO {
    RepoDTO(id: id,
            name: name,
            description: "desc-\(id)",
            fork: nil,
            html_url: "https://example.com/repo/\(id)",
            owner: .init(login: "apple", html_url: "https://example.com/owner"))
}

private func makeRepo(id: Int) -> Repo {
    Repo(id: id,
         name: "repo-\(id)",
         description: "desc-\(id)",
         fork: nil,
         repoURL: URL(string: "https://example.com/repo/\(id)")!,
         ownerLogin: "apple",
         ownerURL: URL(string: "https://example.com/owner")!)
}

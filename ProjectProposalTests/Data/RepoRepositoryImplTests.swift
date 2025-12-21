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
        
        #expect(fresh.map(\.id) == [101, 102])
        
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
        
        #expect(updated.map(\.id) == [1, 2])
        
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
    func refresh_doesNotClearCache_toAvoidEmptyStateFlicker() async throws {
        let service = GitHubRepoServiceStub()
        let cache = RepoCacheStoreInMemory()
        
        // Seed existing cache
        await cache.seed([makeRepo(id: 999)])
        
        await service.setPage(1, repos: [
            makeDTO(id: 1, name: "A")
        ], hasNext: false)
        
        let sut = RepoRepositoryImpl(service: service, cache: cache, user: "apple", perPage: 10)
        
        _ = try await sut.refresh()
        
        // The important signal: deleteAll should not be called (per our chosen policy)
        #expect(await cache.deleteAllCalls == 0)
        
        let cached = try await sut.cachedRepos()
        // Should at least contain the new repo; depending on your policy it may also keep older ones.
        #expect(cached.contains(where: { $0.id == 1 }))
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

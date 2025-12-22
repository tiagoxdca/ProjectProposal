//
//  RepoUseCasesTests.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
import Testing
@testable import ProjectProposal

struct RepoUseCasesTests {

    @Test
    func getCachedRepos_returnsRepositoryResult_andCallsOnce() async throws {
        let repo = makeRepo(id: 1)
        let repository = RepoRepositoryFake()
        await repository.setCachedResult(.success([repo]))

        let sut = DefaultGetCachedReposUseCase(repository: repository)

        let result = try await sut.execute()

        #expect(result == [repo])
        #expect(await repository.cachedCalls == 1)
        #expect(await repository.refreshCalls == 0)
        #expect(await repository.nextCalls == 0)
    }

    @Test
    func refreshRepos_returnsRepositoryResult_andCallsOnce() async throws {
        let repo = makeRepo(id: 10)
        let repository = RepoRepositoryFake()
        await repository.setRefreshResult(.success(.init(repos: [repo], hasMore: true)))

        let sut = DefaultRefreshReposUseCase(repository: repository)

        let result = try await sut.execute()

        #expect(result.repos == [repo])
        #expect(result.hasMore == true)
        #expect(await repository.refreshCalls == 1)
        #expect(await repository.cachedCalls == 0)
        #expect(await repository.nextCalls == 0)
    }

    @Test
    func loadNextReposPage_returnsRepositoryResult_andCallsOnce() async throws {
        let repo = makeRepo(id: 20)
        let repository = RepoRepositoryFake()
        await repository.setNextResult(.success(.init(repos: [repo], hasMore: true)))

        let sut = DefaultLoadNextReposPageUseCase(repository: repository)

        let result = try await sut.execute()

        #expect(result.repos == [repo])
        #expect(result.hasMore == true)
        #expect(await repository.nextCalls == 1)
        #expect(await repository.cachedCalls == 0)
        #expect(await repository.refreshCalls == 0)
    }

    @Test
    func refreshRepos_propagatesError() async {
        enum DummyError: Error { case any }

        let repository = RepoRepositoryFake()
        await repository.setRefreshResult(.failure(DummyError.any))

        let sut = DefaultRefreshReposUseCase(repository: repository)

        await #expect(throws: DummyError.self) {
            _ = try await sut.execute()
        }

        #expect(await repository.refreshCalls == 1)
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

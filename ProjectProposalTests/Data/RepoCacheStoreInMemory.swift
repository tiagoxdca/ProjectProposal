//
//  RepoCacheStoreInMemory.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
@testable import ProjectProposal

actor RepoCacheStoreInMemory: RepoCacheStore {
    private var storage: [Int: Repo] = [:]
    private(set) var deleteAllCalls = 0
    private(set) var upsertCalls = 0
    private(set) var fetchCalls = 0

    func seed(_ repos: [Repo]) {
        for repo in repos {
            storage[repo.id] = repo
        }
    }

    func fetchAll() async throws -> [Repo] {
        fetchCalls += 1
        return storage.values.sorted { $0.id < $1.id }
    }

    func upsert(_ repos: [Repo]) async throws {
        upsertCalls += 1
        for repo in repos {
            storage[repo.id] = repo
        }
    }
    
    func replaceAll(with repos: [Repo]) async throws {
        try await deleteAll()
        try await upsert(repos)
    }

    func deleteAll() async throws {
        deleteAllCalls += 1
        storage.removeAll()
    }
}

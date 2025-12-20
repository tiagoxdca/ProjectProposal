//
//  SwiftDataRepoCacheStore.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation
import SwiftData

public final class SwiftDataRepoCacheStore: RepoCacheStore {
    private let container: ModelContainer

    public init(container: ModelContainer) {
        self.container = container
    }

    @MainActor
    private var context: ModelContext { ModelContext(container) }

    @MainActor
    public func fetchAll() throws -> [Repo] {
        let descriptor = FetchDescriptor<CachedRepo>(
            sortBy: [SortDescriptor(\.id, order: .forward)]
        )
        let cached = try context.fetch(descriptor)
        return cached.compactMap(CachedRepoMapper.toDomain)
    }

    public func fetchAll() async throws -> [Repo] {
        try await MainActor.run { try fetchAll() }
    }

    @MainActor
    private func upsertSync(_ repos: [Repo]) throws {
        if repos.isEmpty { return }

        let ids = repos.map(\.id)
        let predicate = #Predicate<CachedRepo> { ids.contains($0.id) }
        let existing = try context.fetch(FetchDescriptor(predicate: predicate))

        var byId: [Int: CachedRepo] = Dictionary(uniqueKeysWithValues: existing.map { ($0.id, $0) })

        for repo in repos {
            if let model = byId[repo.id] {
                CachedRepoMapper.update(model, from: repo)
            } else {
                let new = CachedRepo(
                    id: repo.id,
                    name: repo.name,
                    repoDescription: repo.description,
                    fork: repo.fork,
                    repoURL: repo.repoURL.absoluteString,
                    ownerLogin: repo.ownerLogin,
                    ownerURL: repo.ownerURL.absoluteString
                )
                context.insert(new)
                byId[repo.id] = new
            }
        }

        try context.save()
    }

    public func upsert(_ repos: [Repo]) async throws {
        try await MainActor.run { try upsertSync(repos) }
    }

    @MainActor
    private func deleteAllSync() throws {
        try context.delete(model: CachedRepo.self)
        try context.save()
    }

    public func deleteAll() async throws {
        try await MainActor.run { try deleteAllSync() }
    }
}

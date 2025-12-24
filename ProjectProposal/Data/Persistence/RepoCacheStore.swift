//
//  RepoCacheStore.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol RepoCacheStore: Sendable {
    func fetchAll() async throws -> [Repo]
    func upsert(_ repos: [Repo]) async throws
    func replaceAll(with repos: [Repo]) async throws
}

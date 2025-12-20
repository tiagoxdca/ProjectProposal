//
//  RepoRepository.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol RepoRepository: Sendable {
    func cachedRepos() async throws -> [Repo]
    func refresh() async throws -> [Repo]
    func loadNextPage() async throws -> [Repo]
}

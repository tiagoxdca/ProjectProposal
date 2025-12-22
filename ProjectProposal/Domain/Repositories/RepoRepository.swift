//
//  RepoRepository.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol RepoRepository: Sendable {
    /// Returns cached repositories if available.
    func cachedRepos() async throws -> [Repo]

    /// Refreshes from the first page and returns the accumulated result.
    func refresh() async throws -> RepoPage

    /// Loads the next page (if any) and returns the accumulated result.
    func loadNextPage() async throws -> RepoPage
}

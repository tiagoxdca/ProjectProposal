//
//  RefreshReposUseCase.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol RefreshReposUseCase: Sendable {
    func execute() async throws -> RepoPage
}

public struct DefaultRefreshReposUseCase: RefreshReposUseCase {
    private let repository: RepoRepository

    public init(repository: RepoRepository) {
        self.repository = repository
    }

    public func execute() async throws -> RepoPage {
        try await repository.refresh()
    }
}

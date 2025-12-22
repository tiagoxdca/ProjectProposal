//
//  LoadNextReposPageUseCase.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol LoadNextReposPageUseCase: Sendable {
    func execute() async throws -> RepoPage
}

public struct DefaultLoadNextReposPageUseCase: LoadNextReposPageUseCase {
    private let repository: RepoRepository

    public init(repository: RepoRepository) {
        self.repository = repository
    }

    public func execute() async throws -> RepoPage {
        try await repository.loadNextPage()
    }
}

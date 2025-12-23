//
//  GetCachedReposUseCase.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol GetCachedReposUseCase {
    func execute() async throws -> [Repo]
}

public struct DefaultGetCachedReposUseCase: GetCachedReposUseCase {
    private let repository: RepoRepository

    public init(repository: RepoRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Repo] {
        try await repository.cachedRepos()
    }
}

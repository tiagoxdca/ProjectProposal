//
//  GitHubRepoServiceStub.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
@testable import ProjectProposal

actor GitHubRepoServiceStub: GitHubRepoServicing {
    struct Page {
        let repos: [RepoDTO]
        let hasNext: Bool
    }

    private var pages: [Int: Page] = [:]
    private(set) var calls: [(user: String, page: Int, perPage: Int)] = []

    func setPage(_ page: Int, repos: [RepoDTO], hasNext: Bool) {
        pages[page] = Page(repos: repos, hasNext: hasNext)
    }

    func fetchRepos(user: String, page: Int, perPage: Int) async throws -> (repos: [RepoDTO], hasNext: Bool) {
        calls.append((user: user, page: page, perPage: perPage))
        let result = pages[page] ?? Page(repos: [], hasNext: false)
        return (result.repos, result.hasNext)
    }
}

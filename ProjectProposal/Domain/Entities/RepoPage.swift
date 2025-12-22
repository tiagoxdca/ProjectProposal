//
//  RepoPage.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 22/12/2025.
//

import Foundation

public struct RepoPage: Sendable, Equatable {
    public let repos: [Repo]
    public let hasMore: Bool

    public init(repos: [Repo], hasMore: Bool) {
        self.repos = repos
        self.hasMore = hasMore
    }
}

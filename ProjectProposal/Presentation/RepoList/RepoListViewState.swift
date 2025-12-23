//
//  RepoListViewState.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

struct RepoListViewState: Equatable {
    let repos: [Repo]
    let phase: Phase
    let hasMore: Bool
    let errorMessage: String?
    
    init(repos: [Repo], phase: Phase, hasMore: Bool, errorMessage: String? = nil) {
        self.repos = repos
        self.phase = phase
        self.hasMore = hasMore
        self.errorMessage = errorMessage
    }
}


enum Phase: Equatable {
    case idle
    case loadingInitial
    case loadingMore
}

//
//  RepoListViewState.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

struct RepoListViewState {
    let repos: [Repo]
    let phase: Phase
    let hasMore: Bool
}


enum Phase {
    case idle
    case loadingInitial
    case loadingMore
}

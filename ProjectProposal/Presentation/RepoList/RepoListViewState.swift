//
//  RepoListViewState.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

enum RepoListViewState: Equatable {
    case idle
    case loading
    case loaded(Loaded)
    case failed(message: String)

    struct Loaded: Equatable {
        var repos: [Repo]
        var isLoadingMore: Bool
    }

    var repos: [Repo] {
        switch self {
        case .loaded(let loaded): return loaded.repos
        default: return []
        }
    }

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var isLoadingMore: Bool {
        if case .loaded(let loaded) = self { return loaded.isLoadingMore }
        return false
    }
}

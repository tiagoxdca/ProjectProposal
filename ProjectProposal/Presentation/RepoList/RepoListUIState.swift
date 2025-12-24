//
//  RepoListUIState.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 24/12/2025.
//

import Foundation

enum RepoListUIState: Equatable {
    case loadingInitial
    case empty
    case error(message: String)
    case content
}

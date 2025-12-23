//
//  RepoListUseCases.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

struct RepoListUseCases {
    let getCached: GetCachedReposUseCase
    let refresh: RefreshReposUseCase
    let loadNext: LoadNextReposPageUseCase
}

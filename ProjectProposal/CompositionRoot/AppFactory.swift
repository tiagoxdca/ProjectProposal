//
//  AppFactory.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import SwiftUI

protocol AppFactory {
    @MainActor
    func makeRepoListView(router: AppRouter) -> RepoListView
}

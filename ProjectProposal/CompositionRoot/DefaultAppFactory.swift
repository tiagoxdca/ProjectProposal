//
//  DefaultAppFactory.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation
import SwiftData

final class DefaultAppFactory: AppFactory {
    private let container: ModelContainer

    init(container: ModelContainer) {
        self.container = container
    }

    @MainActor
    func makeRepoListView(router: AppRouter) -> RepoListView {
        // HTTP stack
        let httpClient = URLSessionHTTPClient()

        let requestBuilder = DefaultRequestBuilder(defaultHeaders: [
            "Accept": "application/vnd.github+json"
        ])

        let apiClient = DefaultAPIClient(
            http: httpClient,
            builder: requestBuilder
        )

        // Services
        let gitHubService = GitHubRepoService(api: apiClient)

        // Cache
        let cacheStore = SwiftDataRepoCacheStore(container: container)

        // Repository
        let repository = RepoRepositoryImpl(
            service: gitHubService,
            cache: cacheStore,
            user: "apple",
            perPage: 10
        )

        // Use cases
        let useCases = RepoListUseCases(
            getCached: DefaultGetCachedReposUseCase(repository: repository),
            refresh: DefaultRefreshReposUseCase(repository: repository),
            loadNext: DefaultLoadNextReposPageUseCase(repository: repository)
        )

        // VM + View
        let viewModel = RepoListViewModel(useCases: useCases)
        return RepoListView(viewModel: viewModel, router: router)
    }
    
    @MainActor
    func makeRepoListView() -> RepoListView {
        makeRepoListView(router: AppRouter())
    }
}

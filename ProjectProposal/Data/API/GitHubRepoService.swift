//
//  GitHubRepoService.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol GitHubRepoServicing: Sendable {
    func fetchRepos(user: String, page: Int, perPage: Int) async throws -> (repos: [RepoDTO], hasNext: Bool)
}

public struct GitHubRepoService: GitHubRepoServicing {
    private let api: APIClient
    private let baseURL: URL
    
    public init(api: APIClient,
                baseURL: URL = URL(string: "https://api.github.com")!) {
        self.api = api
        self.baseURL = baseURL
    }
    
    public func fetchRepos(user: String, page: Int, perPage: Int) async throws -> (repos: [RepoDTO], hasNext: Bool) {
        let endpoint = Endpoint(baseURL: baseURL,
                                path: "/users/\(user)/repos",
                                method: .get,
                                queryItems: [
                                    URLQueryItem(name: "per_page", value: String(perPage)),
                                    URLQueryItem(name: "page", value: String(page))
                                ],
                                headers: [
                                    "Accept": "application/vnd.github+json"
                                ]
        )
        
        let (repos, response) = try await api.request(endpoint, as: [RepoDTO].self)
        let hasNext = HTTPLinkHeaderParser.hasNextPage(from: response)
        
        // Fallback: se não houver Link header, assume hasNext se vier cheio (perPage itens)
        let inferredHasNext = hasNext || repos.count == perPage
        
        return (repos: repos, hasNext: inferredHasNext)
    }
}

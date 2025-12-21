//
//   RepoMapper.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public enum RepoMapper {
    public static func map(_ dto: RepoDTO) -> Repo? {
        guard
            let repoURL = URL(string: dto.html_url),
            let ownerURL = URL(string: dto.owner.html_url),
            isValidHTTPURL(repoURL),
            isValidHTTPURL(ownerURL)
        else { return nil }

        return Repo(
            id: dto.id,
            name: dto.name,
            description: dto.description,
            fork: dto.fork,
            repoURL: repoURL,
            ownerLogin: dto.owner.login,
            ownerURL: ownerURL
        )
    }

    public static func map(_ dtos: [RepoDTO]) -> [Repo] {
        dtos.compactMap(map)
    }

    // MARK: - Validation

    private static func isValidHTTPURL(_ url: URL) -> Bool {
        guard
            let scheme = url.scheme?.lowercased(),
            (scheme == "http" || scheme == "https"),
            url.host != nil
        else { return false }

        return true
    }
}

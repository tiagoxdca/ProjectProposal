//
//  CachedRepoMapper.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public enum CachedRepoMapper {
    public static func toDomain(_ model: CachedRepo) -> Repo? {
        guard
            let repoURL = URL(string: model.repoURL),
            let ownerURL = URL(string: model.ownerURL)
        else { return nil }
        
        return Repo(id: model.id,
                    name: model.name,
                    description: model.repoDescription,
                    fork: model.fork,
                    repoURL: repoURL,
                    ownerLogin: model.ownerLogin,
                    ownerURL: ownerURL)
    }
    
    public static func update(_ model: CachedRepo, from repo: Repo) {
        model.name = repo.name
        model.repoDescription = repo.description
        model.fork = repo.fork
        model.repoURL = repo.repoURL.absoluteString
        model.ownerLogin = repo.ownerLogin
        model.ownerURL = repo.ownerURL.absoluteString
        model.updatedAt = .now
    }
}

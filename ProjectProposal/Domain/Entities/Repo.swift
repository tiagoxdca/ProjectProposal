//
//  Repo.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public struct Repo: Identifiable, Equatable, Sendable, Hashable {
    public let id: Int
    public let name: String
    public let description: String?
    public let fork: Bool?
    public let repoURL: URL
    public let ownerLogin: String
    public let ownerURL: URL
    
    public init(id: Int,
                name: String,
                description: String?,
                fork: Bool?,
                repoURL: URL,
                ownerLogin: String,
                ownerURL: URL) {
        self.id = id
        self.name = name
        self.description = description
        self.fork = fork
        self.repoURL = repoURL
        self.ownerLogin = ownerLogin
        self.ownerURL = ownerURL
    }
}

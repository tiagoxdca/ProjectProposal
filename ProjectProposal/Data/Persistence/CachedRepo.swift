//
//  CachedRepo.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation
import SwiftData

@Model
public final class CachedRepo {
    @Attribute(.unique) public var id: Int
    
    public var name: String
    public var repoDescription: String?
    public var fork: Bool?
    
    public var repoURL: String
    public var ownerLogin: String
    public var ownerURL: String
    
    public var updatedAt: Date
    
    public init(id: Int,
                name: String,
                repoDescription: String?,
                fork: Bool?,
                repoURL: String,
                ownerLogin: String,
                ownerURL: String,
                updatedAt: Date = .now) {
        self.id = id
        self.name = name
        self.repoDescription = repoDescription
        self.fork = fork
        self.repoURL = repoURL
        self.ownerLogin = ownerLogin
        self.ownerURL = ownerURL
        self.updatedAt = updatedAt
    }
}

//
//  RepoDTO.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public struct RepoDTO: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let description: String?
    public let fork: Bool?
    public let html_url: String
    public let owner: OwnerDTO

    public struct OwnerDTO: Decodable, Sendable {
        public let login: String
        public let html_url: String
    }
}

//
//  RepoMapperTests.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
import Testing
@testable import ProjectProposal

struct RepoMapperTests {
    
    @Test
    func map_validDTO_createsRepo() throws {
        let dto = RepoDTO(id: 1,
                          name: "swift",
                          description: "desc",
                          fork: nil,
                          html_url: "https://github.com/apple/swift",
                          owner: .init(login: "apple", html_url: "https://github.com/apple"))
        
        let repo = RepoMapper.map(dto)
        
        #expect(repo != nil)
        #expect(repo?.id == 1)
        #expect(repo?.fork == nil)
        #expect(repo?.ownerLogin == "apple")
    }
    
    @Test
    func map_invalidRepoURL_returnsNil() throws {
        let dto = RepoDTO(id: 1,
                          name: "swift",
                          description: nil,
                          fork: false,
                          html_url: "not a url",
                          owner: .init(login: "apple", html_url: "https://github.com/apple"))
        
        #expect(RepoMapper.map(dto) == nil)
    }
}

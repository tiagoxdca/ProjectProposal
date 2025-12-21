//
//  HTTPLinkHeaderParserTests.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 21/12/2025.
//

import Foundation
import Testing
@testable import ProjectProposal

struct HTTPLinkHeaderParserTests {

    @Test
    func hasNextPage_trueWhenRelNextExists() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.github.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [
                "Link": "<https://api.github.com/users/apple/repos?page=2>; rel=\"next\", <https://api.github.com/users/apple/repos?page=34>; rel=\"last\""
            ]
        )!

        #expect(HTTPLinkHeaderParser.hasNextPage(from: response) == true)
    }

    @Test
    func hasNextPage_falseWhenHeaderMissing() throws {
        let response = HTTPURLResponse(
            url: URL(string: "https://api.github.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: [:]
        )!

        #expect(HTTPLinkHeaderParser.hasNextPage(from: response) == false)
    }
}

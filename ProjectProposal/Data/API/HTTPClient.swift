//
//  HTTPClient.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol HTTPClient: Sendable {
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
}

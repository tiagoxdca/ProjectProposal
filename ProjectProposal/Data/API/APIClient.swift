//
//  APIClient.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol APIClient: Sendable {
    func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> (T, HTTPURLResponse)
    func request(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse)
}

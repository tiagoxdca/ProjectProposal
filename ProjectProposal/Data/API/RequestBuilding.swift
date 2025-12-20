//
//  RequestBuilding.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public protocol RequestBuilding: Sendable {
    func makeRequest(from endpoint: Endpoint) throws -> URLRequest
}

public enum RequestBuilderError: Error, Equatable {
    case invalidURLComponents
}

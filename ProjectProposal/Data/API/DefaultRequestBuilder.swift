//
//  DefaultRequestBuilder.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public struct DefaultRequestBuilder: RequestBuilding {
    private let defaultHeaders: [String: String]

    public init(defaultHeaders: [String: String] = [:]) {
        self.defaultHeaders = defaultHeaders
    }

    public func makeRequest(from endpoint: Endpoint) throws -> URLRequest {
        var components = URLComponents(url: endpoint.baseURL, resolvingAgainstBaseURL: false)
        let normalizedPath = endpoint.path.hasPrefix("/") ? endpoint.path : "/" + endpoint.path
        components?.path = (components?.path ?? "") + normalizedPath
        components?.queryItems = endpoint.queryItems.isEmpty ? nil : endpoint.queryItems

        guard let url = components?.url else { throw RequestBuilderError.invalidURLComponents }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        // headers default + endpoint (endpoint ganha)
        let merged = defaultHeaders.merging(endpoint.headers, uniquingKeysWith: { _, new in new })
        for (k, v) in merged { request.setValue(v, forHTTPHeaderField: k) }

        return request
    }
}

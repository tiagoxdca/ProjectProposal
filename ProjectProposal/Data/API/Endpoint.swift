//
//  Endpoint.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public struct Endpoint: Sendable {
    public var baseURL: URL
    public var path: String
    public var method: HTTPMethod
    public var queryItems: [URLQueryItem]
    public var headers: [String: String]
    public var body: Data?
    
    public init(baseURL: URL,
                path: String,
                method: HTTPMethod,
                queryItems: [URLQueryItem] = [],
                headers: [String: String] = [:],
                body: Data? = nil) {
        self.baseURL = baseURL
        self.path = path
        self.method = method
        self.queryItems = queryItems
        self.headers = headers
        self.body = body
    }
}

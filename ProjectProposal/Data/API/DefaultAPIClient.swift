//
//  DefaultAPIClient.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public final class DefaultAPIClient: APIClient {
    private let http: HTTPClient
    private let builder: RequestBuilding
    private let decoder: JSONDecoder
    
    public init(
        http: HTTPClient,
        builder: RequestBuilding,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.http = http
        self.builder = builder
        self.decoder = decoder
    }
    
    public func request(_ endpoint: Endpoint) async throws -> (Data, HTTPURLResponse) {
        let req = try builder.makeRequest(from: endpoint)
        let (data, response) = try await http.perform(req)
        guard (200...299).contains(response.statusCode) else {
            throw APIError.httpStatus(response.statusCode, body: data)
        }
        return (data, response)
    }
    
    public func request<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> (T, HTTPURLResponse) {
        let (data, response) = try await request(endpoint)
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return (decoded, response)
        } catch {
            throw APIError.decodingFailed
        }
    }
}

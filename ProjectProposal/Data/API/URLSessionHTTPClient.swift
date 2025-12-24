//
//  URLSessionHTTPClient.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public enum HTTPClientError: Error, Equatable {
    case nonHTTPResponse
}

public final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    public init(session: URLSession = .shared) {
        self.session = session
    }

    public func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw HTTPClientError.nonHTTPResponse
        }

        if http.statusCode == 304 {
            let cache = session.configuration.urlCache ?? URLCache.shared

            if let cached = cache.cachedResponse(for: request),
               let cachedHTTP = cached.response as? HTTPURLResponse {
                return (cached.data, cachedHTTP)
            } else {
                // 304 sem cache => erro real
                throw HTTPClientError.nonHTTPResponse
            }
        }
        return (data, http)
    }
}

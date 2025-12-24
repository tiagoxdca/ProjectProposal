//
//  URLSessionHTTPClientTests.swift
//  ProjectProposalTests
//
//  Created by (Admin) Tiago Cunha Almeida on 24/12/2025.
//

import Foundation
import Testing

@testable import ProjectProposal

@MainActor
struct URLSessionHTTPClientTests {

    @Test
    func perform_whenServerReturns304_returnsCachedResponseData() async throws {
        // Arrange
        let originalCache = URLCache.shared
        let testCache = URLCache(memoryCapacity: 1_000_000, diskCapacity: 0, diskPath: nil)
        URLCache.shared = testCache
        defer { URLCache.shared = originalCache }

        let url = URL(string: "https://example.com/resource?page=2")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.cachePolicy = .useProtocolCachePolicy

        // Put a cached 200 response in URLCache for this request
        let cachedBody = Data("CACHED_BODY".utf8)
        let cachedHTTP = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: ["Content-Type": "application/json"]
        )!
        let cached = CachedURLResponse(response: cachedHTTP, data: cachedBody)
        URLCache.shared.storeCachedResponse(cached, for: request)

        // Stub network to return 304 with empty body
        URLProtocolStub.requestHandler = { req in
            let http = HTTPURLResponse(
                url: req.url!,
                statusCode: 304,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            )!
            return (http, Data())
        }

        let session = makeSessionUsingURLProtocolStub()
        let sut = URLSessionHTTPClient(session: session)

        // Act
        let (data, response) = try await sut.perform(request)

        // Assert
        #expect(data == cachedBody)
        #expect(response.statusCode == 200)
    }

    // MARK: - Helpers

    private func makeSessionUsingURLProtocolStub() -> URLSession {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        // Not strictly needed because code uses URLCache.shared, but harmless:
        config.urlCache = URLCache.shared
        return URLSession(configuration: config)
    }
}

// MARK: - URLProtocol Stub

final class URLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = Self.requestHandler else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }

        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() { }
}

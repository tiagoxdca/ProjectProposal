//
//  HTTPLinkHeaderParser.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public enum HTTPLinkHeaderParser {
    /// Returns true if the Link header contains rel="next"
    public static func hasNextPage(from response: HTTPURLResponse) -> Bool {
        guard let link = response.value(forHTTPHeaderField: "Link"), !link.isEmpty else {
            return false
        }
        // Very small, robust-enough parser:
        // Link: <...>; rel="next", <...>; rel="last"
        return link.split(separator: ",").contains { part in
            part.contains("rel=\"next\"")
        }
    }
}

//
//  APIError.swift
//  ProjectProposal
//
//  Created by (Admin) Tiago Cunha Almeida on 20/12/2025.
//

import Foundation

public enum APIError: Error, Equatable {
    case invalidResponse
    case httpStatus(Int, body: Data)
    case decodingFailed
}

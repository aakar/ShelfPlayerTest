//
//  SnipService.swift
//  ShelfPlayerKit
//
//  Created on 15.03.26.
//

import Foundation

public protocol SnipService: Sendable {
    func createSnip(libraryItemId: String, chapterId: String?, anchorMs: Int64, startMs: Int64, endMs: Int64) async throws -> Snip
    func getSnip(id: String) async throws -> Snip
    func listSnips(libraryItemId: String) async throws -> [Snip]
    func updateSnip(id: String, tags: [String]) async throws -> Snip
    func deleteSnip(id: String) async throws
}

public enum SnipServiceError: Error, LocalizedError {
    case invalidURL
    case requestFailed(statusCode: Int)
    case decodingFailed
    case notConfigured

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            "Invalid snip service URL"
        case .requestFailed(let statusCode):
            "Snip request failed with status \(statusCode)"
        case .decodingFailed:
            "Failed to decode snip response"
        case .notConfigured:
            "Snip service is not configured"
        }
    }
}

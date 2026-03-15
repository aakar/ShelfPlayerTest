//
//  LiveSnipService.swift
//  ShelfPlayerKit
//
//  Created on 15.03.26.
//

import Foundation
import OSLog

// TODO: [Snip Backend] Configure the snip service base URL from user settings or server discovery
public final class LiveSnipService: SnipService {
    private let baseURL: URL
    private let session: URLSession
    private let logger = Logger(subsystem: "io.rfk.shelfPlayerKit", category: "LiveSnipService")

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    // TODO: [Snip Backend] Accept auth token or credential provider for authenticated requests
    public init(baseURL: URL) {
        self.baseURL = baseURL

        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 30
        session = URLSession(configuration: configuration)
    }

    // TODO: [Snip Backend] Verify request/response schema matches actual backend contract
    public func createSnip(libraryItemId: String, chapterId: String?, anchorMs: Int64, startMs: Int64, endMs: Int64) async throws -> Snip {
        let url = baseURL.appending(path: "v1/snips")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = CreateSnipRequest(libraryItemId: libraryItemId, chapterId: chapterId, anchorMs: anchorMs, startMs: startMs, endMs: endMs)
        request.httpBody = try encoder.encode(body)

        return try await perform(request)
    }

    public func getSnip(id: String) async throws -> Snip {
        let url = baseURL.appending(path: "v1/snips/\(id)")
        let request = URLRequest(url: url)

        return try await perform(request)
    }

    // TODO: [Snip Backend] Confirm query parameter name for filtering by library item
    public func listSnips(libraryItemId: String) async throws -> [Snip] {
        var url = baseURL.appending(path: "v1/snips")
        url.append(queryItems: [URLQueryItem(name: "libraryItemId", value: libraryItemId)])

        let request = URLRequest(url: url)

        return try await perform(request)
    }

    // TODO: [Snip Backend] Confirm PATCH body schema for updating snips
    public func updateSnip(id: String, tags: [String]) async throws -> Snip {
        let url = baseURL.appending(path: "v1/snips/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = UpdateSnipRequest(tags: tags)
        request.httpBody = try encoder.encode(body)

        return try await perform(request)
    }

    public func deleteSnip(id: String) async throws {
        let url = baseURL.appending(path: "v1/snips/\(id)")
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let (_, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SnipServiceError.requestFailed(statusCode: -1)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            logger.error("DELETE /v1/snips/\(id) failed with status \(httpResponse.statusCode)")
            throw SnipServiceError.requestFailed(statusCode: httpResponse.statusCode)
        }
    }

    private func perform<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SnipServiceError.requestFailed(statusCode: -1)
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            logger.error("Request to \(request.url?.absoluteString ?? "?") failed with status \(httpResponse.statusCode)")
            throw SnipServiceError.requestFailed(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            logger.error("Failed to decode response: \(error)")
            throw SnipServiceError.decodingFailed
        }
    }
}

// TODO: [Snip Backend] Verify these request body structures match the actual API
private struct CreateSnipRequest: Encodable {
    let libraryItemId: String
    let chapterId: String?
    let anchorMs: Int64
    let startMs: Int64
    let endMs: Int64
}

private struct UpdateSnipRequest: Encodable {
    let tags: [String]
}

//
//  MockSnipService.swift
//  ShelfPlayerKit
//
//  Created on 15.03.26.
//

import Foundation

#if DEBUG
public final class MockSnipService: SnipService, @unchecked Sendable {
    private let lock = NSLock()
    private var snips: [String: Snip]

    public init() {
        var store = [String: Snip]()
        for snip in Snip.fixtures {
            store[snip.id] = snip
        }
        snips = store
    }

    public func createSnip(libraryItemId: String, chapterId: String?, anchorMs: Int64, startMs: Int64, endMs: Int64) async throws -> Snip {
        try await Task.sleep(for: .milliseconds(300))

        let snip = Snip(
            id: UUID().uuidString,
            libraryItemId: libraryItemId,
            chapterId: chapterId,
            anchorMs: anchorMs,
            startMs: startMs,
            endMs: endMs,
            status: .queued,
            createdAt: Date(),
            updatedAt: Date())

        lock.lock()
        snips[snip.id] = snip
        lock.unlock()

        simulateProcessing(snip.id)

        return snip
    }

    public func getSnip(id: String) async throws -> Snip {
        try await Task.sleep(for: .milliseconds(100))

        lock.lock()
        let snip = snips[id]
        lock.unlock()

        guard let snip else {
            throw SnipServiceError.requestFailed(statusCode: 404)
        }

        return snip
    }

    public func listSnips(libraryItemId: String) async throws -> [Snip] {
        try await Task.sleep(for: .milliseconds(200))

        lock.lock()
        let result = snips.values.filter { $0.libraryItemId == libraryItemId }.sorted()
        lock.unlock()

        return result
    }

    public func updateSnip(id: String, tags: [String]) async throws -> Snip {
        try await Task.sleep(for: .milliseconds(150))

        lock.lock()
        guard let existing = snips[id] else {
            lock.unlock()
            throw SnipServiceError.requestFailed(statusCode: 404)
        }

        let updated = Snip(
            id: existing.id,
            libraryItemId: existing.libraryItemId,
            chapterId: existing.chapterId,
            anchorMs: existing.anchorMs,
            startMs: existing.startMs,
            endMs: existing.endMs,
            status: existing.status,
            transcript: existing.transcript,
            summary: existing.summary,
            translation: existing.translation,
            tags: tags,
            importanceScore: existing.importanceScore,
            error: existing.error,
            createdAt: existing.createdAt,
            updatedAt: Date())

        snips[id] = updated
        lock.unlock()

        return updated
    }

    public func deleteSnip(id: String) async throws {
        try await Task.sleep(for: .milliseconds(100))

        lock.lock()
        snips[id] = nil
        lock.unlock()
    }

    private func simulateProcessing(_ id: String) {
        Task {
            try await Task.sleep(for: .seconds(2))

            lock.lock()
            guard let snip = snips[id], snip.status == .queued else {
                lock.unlock()
                return
            }

            snips[id] = Snip(
                id: snip.id,
                libraryItemId: snip.libraryItemId,
                chapterId: snip.chapterId,
                anchorMs: snip.anchorMs,
                startMs: snip.startMs,
                endMs: snip.endMs,
                status: .processing,
                createdAt: snip.createdAt,
                updatedAt: Date())
            lock.unlock()

            try await Task.sleep(for: .seconds(3))

            lock.lock()
            guard let processing = snips[id], processing.status == .processing else {
                lock.unlock()
                return
            }

            snips[id] = Snip(
                id: processing.id,
                libraryItemId: processing.libraryItemId,
                chapterId: processing.chapterId,
                anchorMs: processing.anchorMs,
                startMs: processing.startMs,
                endMs: processing.endMs,
                status: .complete,
                transcript: "The telescreen received and transmitted simultaneously. Any sound that Winston made, above the level of a very low whisper, would be picked up by it.",
                summary: "Description of the telescreen's surveillance capabilities in Winston's apartment.",
                tags: ["surveillance", "telescreen"],
                importanceScore: 0.72,
                createdAt: processing.createdAt,
                updatedAt: Date())
            lock.unlock()
        }
    }
}
#endif

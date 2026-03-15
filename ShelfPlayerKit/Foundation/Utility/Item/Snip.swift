//
//  Snip.swift
//  ShelfPlayerKit
//
//  Created on 15.03.26.
//

import Foundation

public struct Snip {
    public let id: String

    public let libraryItemId: String
    public let chapterId: String?

    public let anchorMs: Int64
    public let startMs: Int64
    public let endMs: Int64

    public let status: SnipStatus

    public let transcript: String?
    public let summary: String?
    public let translation: String?
    public let tags: [String]
    public let importanceScore: Float?

    public let error: String?

    public let createdAt: Date
    public let updatedAt: Date

    public init(id: String, libraryItemId: String, chapterId: String?, anchorMs: Int64, startMs: Int64, endMs: Int64, status: SnipStatus, transcript: String? = nil, summary: String? = nil, translation: String? = nil, tags: [String] = [], importanceScore: Float? = nil, error: String? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.libraryItemId = libraryItemId
        self.chapterId = chapterId
        self.anchorMs = anchorMs
        self.startMs = startMs
        self.endMs = endMs
        self.status = status
        self.transcript = transcript
        self.summary = summary
        self.translation = translation
        self.tags = tags
        self.importanceScore = importanceScore
        self.error = error
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

extension Snip: Sendable {}
extension Snip: Hashable {}
extension Snip: Identifiable {}
extension Snip: Codable {}
extension Snip: Comparable {
    public static func <(lhs: Self, rhs: Self) -> Bool {
        lhs.anchorMs < rhs.anchorMs
    }
}

extension Snip {
    public var anchorSeconds: TimeInterval {
        TimeInterval(anchorMs) / 1000.0
    }

    public var isComplete: Bool {
        status == .complete
    }

    public var isPending: Bool {
        status == .queued || status == .processing
    }
}

public enum SnipStatus: String, Sendable, Hashable, Codable, CaseIterable {
    case queued
    case processing
    case complete
    case failed
}

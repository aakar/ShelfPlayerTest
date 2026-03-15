//
//  Snip+Fixture.swift
//  ShelfPlayerKit
//
//  Created on 15.03.26.
//

import Foundation

#if DEBUG
public extension Snip {
    static let fixture = Snip(
        id: "fixture-snip-1",
        libraryItemId: "fixture-audiobook",
        chapterId: "chapter-1",
        anchorMs: 3_600_000,
        startMs: 3_580_000,
        endMs: 3_640_000,
        status: .complete,
        transcript: "It was a bright cold day in April, and the clocks were striking thirteen. Winston Smith, his chin nuzzled into his breast in an effort to escape the vile wind, slipped quickly through the glass doors of Victory Mansions.",
        summary: "Opening scene describing Winston entering Victory Mansions on a cold April day.",
        translation: nil,
        tags: ["opening", "winston", "setting"],
        importanceScore: 0.85,
        createdAt: Date(),
        updatedAt: Date())

    static let fixtureProcessing = Snip(
        id: "fixture-snip-2",
        libraryItemId: "fixture-audiobook",
        chapterId: "chapter-3",
        anchorMs: 7_200_000,
        startMs: 7_180_000,
        endMs: 7_240_000,
        status: .processing,
        createdAt: Date().addingTimeInterval(-30),
        updatedAt: Date())

    static let fixtureQueued = Snip(
        id: "fixture-snip-3",
        libraryItemId: "fixture-audiobook",
        chapterId: nil,
        anchorMs: 10_800_000,
        startMs: 10_780_000,
        endMs: 10_840_000,
        status: .queued,
        createdAt: Date().addingTimeInterval(-5),
        updatedAt: Date().addingTimeInterval(-5))

    static let fixtureFailed = Snip(
        id: "fixture-snip-4",
        libraryItemId: "fixture-audiobook",
        chapterId: "chapter-2",
        anchorMs: 5_400_000,
        startMs: 5_380_000,
        endMs: 5_440_000,
        status: .failed,
        error: "Audio extraction failed: segment not available",
        createdAt: Date().addingTimeInterval(-120),
        updatedAt: Date().addingTimeInterval(-60))

    static let fixtures: [Snip] = [.fixture, .fixtureProcessing, .fixtureQueued, .fixtureFailed]
}
#endif

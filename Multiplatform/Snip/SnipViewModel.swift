//
//  SnipViewModel.swift
//  Multiplatform
//
//  Created on 15.03.26.
//

import Foundation
import SwiftUI
import OSLog
import ShelfPlayback

// TODO: [Snip Backend] Replace MockSnipService with LiveSnipService once backend is available
@Observable @MainActor
final class SnipViewModel {
    private let logger = Logger(subsystem: "io.rfk.shelfPlayer", category: "SnipViewModel")

    private(set) var snips: [Snip] = []

    private(set) var isCreatingSnip = false
    private(set) var isLoading = false

    private(set) var notifyError = false
    private(set) var notifySuccess = false

    private var pollingTask: Task<Void, Never>?

    #if DEBUG
    private let service: any SnipService = MockSnipService()
    #else
    // TODO: [Snip Backend] Initialize LiveSnipService with user-configured base URL
    private let service: any SnipService = {
        fatalError("Snip service not configured for production")
    }()
    #endif

    func loadSnips(libraryItemId: String) {
        Task {
            isLoading = true

            do {
                let loaded = try await service.listSnips(libraryItemId: libraryItemId)

                withAnimation {
                    snips = loaded.sorted()
                    isLoading = false
                }

                startPollingIfNeeded(libraryItemId: libraryItemId)
            } catch {
                logger.error("Failed to load snips: \(error)")

                withAnimation {
                    isLoading = false
                    notifyError.toggle()
                }
            }
        }
    }

    func createSnip(libraryItemId: String, chapterId: String?, anchorSeconds: TimeInterval) {
        Task {
            withAnimation {
                isCreatingSnip = true
            }

            let anchorMs = Int64(anchorSeconds * 1000)
            let startMs = max(0, anchorMs - 20_000)
            let endMs = anchorMs + 40_000

            do {
                let snip = try await service.createSnip(
                    libraryItemId: libraryItemId,
                    chapterId: chapterId,
                    anchorMs: anchorMs,
                    startMs: startMs,
                    endMs: endMs)

                withAnimation {
                    snips.append(snip)
                    snips.sort()
                    isCreatingSnip = false
                    notifySuccess.toggle()
                }

                startPollingIfNeeded(libraryItemId: libraryItemId)
            } catch {
                logger.error("Failed to create snip: \(error)")

                withAnimation {
                    isCreatingSnip = false
                    notifyError.toggle()
                }
            }
        }
    }

    func deleteSnip(_ snip: Snip) {
        Task {
            do {
                try await service.deleteSnip(id: snip.id)

                withAnimation {
                    snips.removeAll { $0.id == snip.id }
                }
            } catch {
                logger.error("Failed to delete snip: \(error)")
                notifyError.toggle()
            }
        }
    }

    func refreshSnip(_ snip: Snip) async -> Snip? {
        do {
            let updated = try await service.getSnip(id: snip.id)

            if let index = snips.firstIndex(where: { $0.id == snip.id }) {
                withAnimation {
                    snips[index] = updated
                }
            }

            return updated
        } catch {
            logger.error("Failed to refresh snip \(snip.id): \(error)")
            return nil
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }
}

private extension SnipViewModel {
    // TODO: [Snip Backend] Consider WebSocket or push notifications instead of polling
    func startPollingIfNeeded(libraryItemId: String) {
        let hasPending = snips.contains { $0.isPending }

        guard hasPending else {
            stopPolling()
            return
        }

        guard pollingTask == nil else {
            return
        }

        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(5))

                guard !Task.isCancelled else {
                    break
                }

                do {
                    let refreshed = try await service.listSnips(libraryItemId: libraryItemId)

                    withAnimation {
                        snips = refreshed.sorted()
                    }

                    let stillPending = snips.contains { $0.isPending }

                    if !stillPending {
                        break
                    }
                } catch {
                    logger.warning("Polling failed: \(error)")
                }
            }

            pollingTask = nil
        }
    }
}

//
//  SnipRow.swift
//  Multiplatform
//
//  Created on 15.03.26.
//

import SwiftUI
import ShelfPlayback

struct SnipRow: View {
    let snip: Snip

    var body: some View {
        HStack(spacing: 0) {
            ZStack {
                Text(verbatim: "00:00:00")
                    .hidden()

                Text(snip.anchorSeconds, format: .duration(unitsStyle: .positional, allowedUnits: [.hour, .minute, .second], maximumUnitCount: 3))
            }
            .font(.footnote)
            .fontDesign(.rounded)
            .foregroundStyle(Color.accentColor)
            .padding(.trailing, 12)

            VStack(alignment: .leading, spacing: 2) {
                if let transcript = snip.transcript {
                    Text(transcript)
                        .lineLimit(1)
                        .foregroundStyle(.primary)
                } else {
                    Text("snip.pending")
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                        .italic()
                }

                if let summary = snip.summary {
                    Text(summary)
                        .font(.caption)
                        .lineLimit(1)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer(minLength: 8)

            SnipStatusBadge(status: snip.status)
        }
        .contentShape(.rect)
    }
}

struct SnipStatusBadge: View {
    let status: SnipStatus

    private var label: LocalizedStringKey {
        switch status {
        case .queued:
            "snip.status.queued"
        case .processing:
            "snip.status.processing"
        case .complete:
            "snip.status.complete"
        case .failed:
            "snip.status.failed"
        }
    }

    private var icon: String {
        switch status {
        case .queued:
            "clock"
        case .processing:
            "arrow.trianglehead.2.clockwise"
        case .complete:
            "checkmark.circle.fill"
        case .failed:
            "exclamationmark.triangle.fill"
        }
    }

    private var tint: Color {
        switch status {
        case .queued:
            .secondary
        case .processing:
            .orange
        case .complete:
            .green
        case .failed:
            .red
        }
    }

    var body: some View {
        Label(label, systemImage: icon)
            .labelStyle(.iconOnly)
            .font(.caption)
            .foregroundStyle(tint)
            .symbolEffect(.pulse, isActive: status == .processing)
    }
}

#if DEBUG
#Preview {
    List {
        SnipRow(snip: .fixture)
        SnipRow(snip: .fixtureProcessing)
        SnipRow(snip: .fixtureQueued)
        SnipRow(snip: .fixtureFailed)
    }
    .listStyle(.plain)
    .previewEnvironment()
}
#endif

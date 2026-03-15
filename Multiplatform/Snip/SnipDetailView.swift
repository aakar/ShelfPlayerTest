//
//  SnipDetailView.swift
//  Multiplatform
//
//  Created on 15.03.26.
//

import SwiftUI
import ShelfPlayback

struct SnipDetailView: View {
    @Environment(Satellite.self) private var satellite

    let snip: Snip

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header

                if snip.isPending {
                    pendingSection
                } else if snip.status == .failed {
                    failedSection
                } else {
                    if let transcript = snip.transcript {
                        section("snip.transcript") {
                            Text(transcript)
                        }
                    }

                    if let summary = snip.summary {
                        section("snip.summary") {
                            Text(summary)
                        }
                    }

                    if let translation = snip.translation {
                        section("snip.translation") {
                            Text(translation)
                        }
                    }

                    if !snip.tags.isEmpty {
                        section("snip.tags") {
                            FlowLayout(spacing: 8) {
                                ForEach(snip.tags, id: \.self) { tag in
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 10)
                                        .padding(.vertical, 4)
                                        .background(.fill.tertiary, in: .capsule)
                                }
                            }
                        }
                    }

                    if let score = snip.importanceScore {
                        section("snip.importance") {
                            HStack(spacing: 4) {
                                Image(systemName: "gauge.with.dots.needle.33percent")
                                Text(score, format: .percent.precision(.fractionLength(0)))
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(20)
        }
        .navigationTitle("snip.detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("snip.jumpToAnchor", systemImage: "arrow.right.to.line") {
                    satellite.seek(to: snip.anchorSeconds, insideChapter: false) {}
                }
            }
        }
    }

    @ViewBuilder
    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                SnipStatusBadge(status: snip.status)

                Text(snip.status.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()

                Text(snip.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }

            HStack(spacing: 16) {
                Label {
                    Text(snip.anchorSeconds, format: .duration(unitsStyle: .positional, allowedUnits: [.hour, .minute, .second], maximumUnitCount: 3))
                } icon: {
                    Image(systemName: "bookmark.fill")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)

                Label {
                    let durationMs = snip.endMs - snip.startMs
                    let durationSeconds = TimeInterval(durationMs) / 1000.0
                    Text(durationSeconds, format: .duration(unitsStyle: .abbreviated, allowedUnits: [.second], maximumUnitCount: 1))
                } icon: {
                    Image(systemName: "timer")
                }
                .font(.footnote)
                .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .background(.fill.quaternary, in: .rect(cornerRadius: 12))
    }

    @ViewBuilder
    private var pendingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
            Text("snip.pending.description")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }

    @ViewBuilder
    private var failedSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("snip.status.failed", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(.red)
                .font(.headline)

            if let error = snip.error {
                Text(error)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.red.opacity(0.1), in: .rect(cornerRadius: 12))
    }

    @ViewBuilder
    private func section(_ title: LocalizedStringKey, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.smallCaps())
                .foregroundStyle(.secondary)

            content()
        }
    }
}

private struct FlowLayout: Layout {
    let spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)

        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions = [CGPoint]()
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalWidth: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }

            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalWidth = max(totalWidth, x - spacing)
        }

        return (CGSize(width: totalWidth, height: y + rowHeight), positions)
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SnipDetailView(snip: .fixture)
    }
    .previewEnvironment()
}
#Preview("Processing") {
    NavigationStack {
        SnipDetailView(snip: .fixtureProcessing)
    }
    .previewEnvironment()
}
#Preview("Failed") {
    NavigationStack {
        SnipDetailView(snip: .fixtureFailed)
    }
    .previewEnvironment()
}
#endif

//
//  SnipListView.swift
//  Multiplatform
//
//  Created on 15.03.26.
//

import SwiftUI
import ShelfPlayback

struct SnipListView: View {
    @Environment(Satellite.self) private var satellite

    let itemID: ItemIdentifier
    let snips: [Snip]
    let onDelete: (Snip) -> Void

    var body: some View {
        ForEach(snips) { snip in
            NavigationLink {
                SnipDetailView(snip: snip)
            } label: {
                SnipRow(snip: snip)
            }
            .buttonStyle(.plain)
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button("action.delete", systemImage: "trash", role: .destructive) {
                    onDelete(snip)
                }
            }
            .swipeActions(edge: .leading) {
                Button("snip.jumpToAnchor", systemImage: "arrow.right.to.line") {
                    satellite.seek(to: snip.anchorSeconds, insideChapter: false) {}
                }
                .tint(.accentColor)
            }
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        List {
            SnipListView(itemID: .fixture, snips: Snip.fixtures) { _ in }
        }
        .listStyle(.plain)
    }
    .previewEnvironment()
}
#endif

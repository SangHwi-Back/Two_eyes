//
//  FeedCellModel.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/27/26.
//

import Foundation

// MARK: - Feed Item Model
nonisolated struct FeedItemModel: Hashable, Sendable {
    let id: UUID
    /// Android의 Uri 배열에 해당 — 외부 URL 또는 로컬 file:// URL
    let images: [URL]
    let author: String
    let description: String
    var showReply: Bool

    init(
        images: [URL],
        author: String,
        description: String,
        showReply: Bool = false
    ) {
        self.id = UUID()
        self.images = images
        self.author = author
        self.description = description
        self.showReply = showReply
    }

    static func == (lhs: FeedItemModel, rhs: FeedItemModel) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Section
nonisolated enum FeedSection: Hashable {
    case list
}

//
//  FeedCollectionViewCell.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/18/26.
//

import UIKit

class FeedCollectionViewCell: UICollectionViewCell {

    static let reuseIdentifier = String(describing: FeedCollectionViewCell.self)

    // MARK: - UI Components
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    // MARK: - Image Loading

    /// 셀 재사용 시 이전 로딩 작업 취소용
    private var imageLoadTask: Task<Void, Never>?

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageView.image = nil
        authorLabel.text = nil
        descriptionLabel.text = nil
    }

    // MARK: - Configure

    func configure(with model: FeedItemModel) {
        authorLabel.text = model.author
        descriptionLabel.text = model.description

        // 이전 로딩 취소 후 첫 번째 이미지 URL 비동기 로드
        imageLoadTask?.cancel()
        guard let firstURL = model.images.first else { return }

        imageLoadTask = Task {
            await loadImage(from: firstURL)
        }
    }

    // MARK: - Private

    @MainActor
    private func loadImage(from url: URL) async {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            // Task가 취소된 경우 이미지 적용하지 않음
            guard !Task.isCancelled, let image = UIImage(data: data) else { return }
            imageView.image = image
        } catch {
            // 로드 실패 시 placeholder(secondarySystemBackground) 유지
        }
    }
}

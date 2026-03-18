//
//  FeedViewController.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/26/26.
//

import UIKit

class FeedViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<FeedSection, FeedItemModel>

    @IBOutlet weak var collectionView: UICollectionView!

    private let mockData = MockFeedDataGenerator.generateAllMockData()

    private lazy var diffableDatasource: DataSource = {
        DataSource(collectionView: collectionView) { collectionView, indexPath, model in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeedCollectionViewCell.reuseIdentifier,
                for: indexPath
            ) as? FeedCollectionViewCell
            cell?.configure(with: model)
            return cell
        }
    }()

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.register(
            UINib(nibName: "FeedCollectionViewCell", bundle: nil),
            forCellWithReuseIdentifier: FeedCollectionViewCell.reuseIdentifier
        )
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = diffableDatasource
        collectionView.backgroundColor = .systemBackground

        applySnapshot()
    }

    // MARK: - Snapshot

    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<FeedSection, FeedItemModel>()
        snapshot.appendSections([.list])
        snapshot.appendItems(mockData, toSection: .list)
        diffableDatasource.apply(snapshot, animatingDifferences: false)
    }

    // MARK: - Layout

    private func createLayout() -> UICollectionViewCompositionalLayout {
        // 이미지(정사각형) + 텍스트 영역을 합산한 예상 높이
        let screenWidth = UIScreen.main.bounds.width
        let estimatedHeight = screenWidth + 80  // 이미지 높이 + author + description

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(estimatedHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8   // 피드 아이템 사이 간격

        return UICollectionViewCompositionalLayout(section: section)
    }
}

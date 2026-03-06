//
//  FeedViewController.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/26/26.
//

import UIKit

class FeedViewController: UIViewController {

    typealias DataSource = UICollectionViewDiffableDataSource<FeedSection, FeedCell>
    typealias ContentsCell = FeedCollectionViewContentsCell
    typealias ThumbnailCell = FeedCollectionViewThumbnailCell
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private let mockData = MockFeedDataGenerator.generateAllMockData()
    
    private lazy var diffableDatasource: DataSource = {
        let dataSource = DataSource(collectionView: collectionView) { collectionView, indexPath, itemIdentifier in
            // MARK: ONLY ONE SECTION CONTAINS
            switch itemIdentifier {
            case .contents(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ContentsCell.self), for: indexPath)
                
                if let cell = cell as? ContentsCell {
                    cell.feedTitleLabel.text = model.title
                    cell.feedContentsLabel.text = model.contents
                }
                return cell
            case .thumbnail(let model):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: ThumbnailCell.self), for: indexPath)
                if let cell = cell as? ThumbnailCell {
                    cell.thumbnailImageView.image = model.firstImage.image
                }
                return cell
            }
        }
        return dataSource
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.register(UINib(nibName: String(describing: ContentsCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ContentsCell.self))
        collectionView.register(UINib(nibName: String(describing: ThumbnailCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: ThumbnailCell.self))
        collectionView.collectionViewLayout = createLayout()
        collectionView.dataSource = diffableDatasource
        applySnapshot()
    }
    
    private func applySnapshot() {
        var snapshot = NSDiffableDataSourceSnapshot<FeedSection, FeedCell>()
        
        snapshot.appendSections([.list])
        snapshot.appendItems(mockData, toSection: .list)
        
        diffableDatasource.apply(snapshot, animatingDifferences: true)
    }
    
    private func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let screenWidth: CGFloat = self.view.frame.width
            let group = NSCollectionLayoutGroup.vertical(
                layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .absolute(screenWidth * 0.85)),
                subitems: [
                    NSCollectionLayoutItem(layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(screenWidth * 0.5))
                    ),
                    NSCollectionLayoutItem(layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(screenWidth * 0.3))
                    ),
                ])
            group.interItemSpacing = .fixed(screenWidth * 0.05)
            group.edgeSpacing = .init(
                leading: .fixed(0),
                top: .fixed(20),
                trailing: .fixed(0),
                bottom: .fixed(20))
            
            return NSCollectionLayoutSection(group: group)
        }
    }
}

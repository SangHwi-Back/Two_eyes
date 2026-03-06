////
////  Temporary.swift
////  PhotoApp
////
////  Created by SangHwiBack on 2/27/26.
////
//
//import UIKit
//
//// MARK: - Data Models
//struct Item: Hashable {
//    let id: UUID
//    let title: String
//    let category: String
//    
//    
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(id)
//    }
//    
//    static func == (lhs: Item, rhs: Item) -> Bool {
//        lhs.id == rhs.id
//    }
//    
//    
//}
//
//// MARK: - Section Enum
//enum Section: Hashable {
//    case featured
//    case category(String)
//}
//
//// MARK: - ViewController
//class CollectionViewController: UIViewController {
//    private var collectionView: UICollectionView!
//    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!
//    
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        title = "Collection View Example"
//        view.backgroundColor = .systemBackground
//        
//        setupCollectionView()
//        configureDataSource()
//        applySnapshot()
//    }
//    
//    private func setupCollectionView() {
//        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
//        collectionView.backgroundColor = .systemBackground
//        
//        // 셀 등록
//        collectionView.register(ItemCell.self, forCellWithReuseIdentifier: "itemCell")
//        
//        // 헤더 등록
//        collectionView.register(
//            SectionHeaderView.self,
//            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//            withReuseIdentifier: "header"
//        )
//        
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(collectionView)
//        
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
//    
//    // MARK: - Compositional Layout
//    private func createLayout() -> UICollectionViewCompositionalLayout {
//        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
//            
//            let section = self.dataSource.snapshot().sectionIdentifiers[sectionIndex]
//            
//            switch section {
//            case .featured:
//                return self.createFeaturedSection()
//            case .category:
//                return self.createCategorySection()
//            }
//        }
//        
//        return layout
//    }
//    
//    // Featured 섹션: 2열 그리드
//    private func createFeaturedSection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(0.5),
//            heightDimension: .fractionalHeight(1.0)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(200)
//        )
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
//        
//        let section = NSCollectionLayoutSection(layoutSize: groupSize, subitem: item, count: 4)
//        section.orthogonalScrollingBehavior = .none
//        
//        // 헤더 추가
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(44)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // Category 섹션: 수평 스크롤
//    private func createCategorySection() -> NSCollectionLayoutSection {
//        let itemSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(150)
//        )
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
//        
//        let groupSize = NSCollectionLayoutSize(
//            widthDimension: .absolute(200),
//            heightDimension: .absolute(150)
//        )
//        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
//        
//        let section = NSCollectionLayoutSection(layoutSize: groupSize, subitem: item, count: 1)
//        section.orthogonalScrollingBehavior = .continuous
//        section.interGroupSpacing = 0
//        
//        // 헤더 추가
//        let headerSize = NSCollectionLayoutSize(
//            widthDimension: .fractionalWidth(1.0),
//            heightDimension: .absolute(44)
//        )
//        let header = NSCollectionLayoutBoundarySupplementaryItem(
//            layoutSize: headerSize,
//            elementKind: UICollectionView.elementKindSectionHeader,
//            alignment: .top
//        )
//        section.boundarySupplementaryItems = [header]
//        
//        return section
//    }
//    
//    // MARK: - Diffable DataSource
//    private func configureDataSource() {
//        dataSource = UICollectionViewDiffableDataSource<Section, Item>(
//            collectionView: collectionView
//        ) { collectionView, indexPath, item in
//            let cell = collectionView.dequeueReusableCell(
//                withReuseIdentifier: "itemCell",
//                for: indexPath
//            ) as! ItemCell
//            cell.configure(with: item)
//            return cell
//        }
//        
//        // 헤더 설정
//        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
//            let header = collectionView.dequeueReusableSupplementaryView(
//                ofKind: kind,
//                withReuseIdentifier: "header",
//                for: indexPath
//            ) as! SectionHeaderView
//            
//            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
//            
//            switch section {
//            case .featured:
//                header.configure(with: "Featured Items")
//            case .category(let categoryName):
//                header.configure(with: categoryName)
//            }
//            
//            return header
//        }
//    }
//    
//    // MARK: - Snapshot
//    private func applySnapshot() {
//        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
//        
//        // Featured 섹션
//        let featuredItems = [
//            Item(id: UUID(), title: "Featured 1", category: "featured"),
//            Item(id: UUID(), title: "Featured 2", category: "featured"),
//            Item(id: UUID(), title: "Featured 3", category: "featured"),
//            Item(id: UUID(), title: "Featured 4", category: "featured")
//        ]
//        
//        snapshot.appendSections([.featured])
//        snapshot.appendItems(featuredItems, toSection: .featured)
//        
//        // Category 섹션들
//        let categories = ["Electronics", "Books", "Clothes"]
//        
//        for category in categories {
//            snapshot.appendSections([.category(category)])
//            
//            let items = (1...6).map { index in
//                Item(id: UUID(), title: "\(category) Item \(index)", category: category)
//            }
//            snapshot.appendItems(items, toSection: .category(category))
//        }
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//    
//    // MARK: - 데이터 업데이트 예제
//    func updateItems() {
//        var snapshot = dataSource.snapshot()
//        
//        // 특정 섹션의 아이템 추가
//        let newItem = Item(id: UUID(), title: "New Item", category: "featured")
//        snapshot.appendItems([newItem], toSection: .featured)
//        
//        dataSource.apply(snapshot, animatingDifferences: true)
//    }
//    
//    
//}

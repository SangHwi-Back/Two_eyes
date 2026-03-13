//
//  CameraViewModel.swift
//  PhotoApp
//
//  Created by SangHwiBack on 3/6/26.
//

import UIKit
import PhotosUI
import Combine

final class CameraViewModel: NSObject, ObservableObject {
    
    let output = PassthroughSubject<Output, Never>()
    private(set) var images = [UIImage]() {
        didSet {
            output.send(.reloadPhotos)
        }
    }
    
    nonisolated enum Section: Hashable {
        case header,
             images,
             collection,
             preview,
             buttons,
             designScroll,
             landscape
    }
    
    nonisolated enum Item: Hashable {
        case header
        case selectedImages([UIImage])
        case collection([UIImage])
        case preview([UIImage])
        case buttons
        case designScroll
    }
    
    enum Input {
        case albumButtonTapped,
             cancelButtonTapped,
             takePhotoButtonTapped
    }
    
    enum Output {
        case openAlbum,
             openCamera,
             openSetting,
             cancel,
             reloadPhotos
    }
    
    var sectionTypes: (UITraitCollection) -> [Section] = {
        if $0.verticalSizeClass == .compact {
            return [.landscape]
        } else {
            return [.header, .images, .preview, .collection, .buttons]
        }
    }
    
    func getCollectionViewSetting(with traitCollection: UITraitCollection) -> SettingCollectionView {
        .init(layout: createLayout(traitCollection),
              dataSource: createDataSource(traitCollection),
              snapshot: createSnapshot(traitCollection)
        )
    }
    
    private func createLayout(_ traitCollection: UITraitCollection) -> UICollectionViewCompositionalLayout {
        let sectionTypes = self.sectionTypes(traitCollection)
        
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            
            if environment.traitCollection.verticalSizeClass == .compact {
                // Landscape: nested horizontal groups (5개 셀을 나란히 배치)
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)

                // Header group (54pt)
                let headerGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .absolute(54),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [item])

                // Images group (30%)
                let imagesGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.25),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [item])

                // Collection group (20%)
                let collectionGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.2),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [item])
                
                // Collection group (20%)
                let previewGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.25),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [item])

                // Buttons group (15%)
                let buttonsGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.15),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [item])

                // DesignScroll group (remaining: 1.0 - 0.3 - 0.2 - 0.15 = 0.35)
                let designScrollGroup = NSCollectionLayoutGroup.vertical(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(0.25),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [item])

                // Main horizontal group
                let mainGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: itemSize,
                    subitems: [headerGroup, imagesGroup, collectionGroup, previewGroup, buttonsGroup, designScrollGroup])

                return NSCollectionLayoutSection(group: mainGroup)
            } else {
                
                let section = sectionTypes[sectionIndex]
                
                // Portrait: each section has its own size
                let groupSize: NSCollectionLayoutSize
                switch section {
                case .header:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(54))
                case .images:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.25))
                case .collection:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.2))
                case .preview:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.25))
                case .buttons:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.15))
                case .designScroll:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(0.25))
                default:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0))
                }
                
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                return NSCollectionLayoutSection(group: group)
            }
        }
    }
    
    private func createDataSource(_ traitCollection: UITraitCollection) -> UICollectionViewDiffableDataSource<Section, Item>.CellProvider {
        return { collectionView, indexPath, itemIdentifier in
            switch itemIdentifier {
            case .header:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraViewHeaderCell.self), for: indexPath)
                return cell
                
            case .selectedImages(let images):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraViewSelectedImagesCell.self), for: indexPath)
                if let imagesCell = cell as? CameraViewSelectedImagesCell {
                    imagesCell.updateTrailCollection(traitCollection)
                    imagesCell.updateImages(images)
                }
                return cell
                
            case .collection(let images):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraViewImageCollectionViewCell.self), for: indexPath)
                if let collections = cell as? CameraViewImageCollectionViewCell {
                    collections.updateImages(images)
                    collections.updateTrailCollection(traitCollection)
                }
                return cell
                
            case .preview(let images):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraViewImagePreviewCell.self), for: indexPath)
                if let cell = cell as? CameraViewImagePreviewCell {
                    cell.updateImages(images)
                }
                return cell
                
            case .buttons:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraViewButtonsCell.self), for: indexPath)
                if let buttons = cell as? CameraViewButtonsCell {
                    buttons.updateTrailCollection(traitCollection)
                }
                return cell
                
            case .designScroll:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CameraViewTraitScrollCell.self), for: indexPath)
                if let designScroll = cell as? CameraViewTraitScrollCell {
                    designScroll.updateTrailCollection(traitCollection)
                }
                return cell
                
            }
        }
    }
    
    private func createSnapshot(_ traitCollection: UITraitCollection) -> NSDiffableDataSourceSnapshot<Section, Item> {
        
        let sectionTypes = self.sectionTypes(traitCollection)
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        snapshot.appendSections(sectionTypes)
        
        for section in sectionTypes {
            switch section {
            case .landscape:
                // Landscape: 모든 아이템을 한 섹션에 추가 (순서대로: header, images, collection, buttons, designScroll)
                snapshot.appendItems([
                    .buttons,
                    .selectedImages(self.images),
                    .preview(self.images),
                    .collection(self.images),
                    .designScroll], toSection: .landscape)
            case .header:
                snapshot.appendItems([.header], toSection: .header)
            case .images:
                snapshot.appendItems([.selectedImages(self.images)], toSection: .images)
            case .preview:
                snapshot.appendItems([.preview(self.images)], toSection: .preview)
            case .collection:
                snapshot.appendItems([.collection(self.images)], toSection: .collection)
            case .buttons:
                snapshot.appendItems([.buttons], toSection: .buttons)
            case .designScroll:
                snapshot.appendItems([.designScroll], toSection: .designScroll)
            }
        }

        return snapshot
    }
    
    struct SettingCollectionView {
        let layout: UICollectionViewCompositionalLayout
        let dataSource: UICollectionViewDiffableDataSource<Section, Item>.CellProvider
        let snapshot: NSDiffableDataSourceSnapshot<Section, Item>
    }
}

extension CameraViewModel: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]
    ) {
        defer {
            picker.dismiss(animated: true)
        }
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        
        images.append(image)
    }
}

extension CameraViewModel: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        results.forEach { result in
            let provider = result.itemProvider
            guard provider.canLoadObject(ofClass: UIImage.self) else {
                return
            }
            
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, _ in
                guard let self = self, let image = image as? UIImage else {
                    return
                }
                
                images.append(image)
            }
        }
    }
}

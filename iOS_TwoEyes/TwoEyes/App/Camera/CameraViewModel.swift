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

            let item = NSCollectionLayoutItem(
                layoutSize: NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)))

            if environment.traitCollection.verticalSizeClass == .compact {
                // ── Landscape ──────────────────────────────────────────────────
                // effectiveContentSize.width : SafeArea 및 콘텐츠 인셋을 제외한 실제 가용 너비
                // 5개 셀(buttons / selectedImages / preview / collection / designScroll)이
                // 가용 너비를 꽉 채우도록 절댓값으로 계산
                let availableWidth = environment.container.effectiveContentSize.width
                let headerWidth: CGFloat = 54
                let contentWidth = availableWidth - headerWidth

                // 각 셀 너비 비율: buttons(54pt 고정) / images:collection:preview:designScroll = 25:20:25:15
                let imagesWidth      = floor(contentWidth * 25 / 85)
                let collectionWidth  = floor(contentWidth * 20 / 85)
                let previewWidth     = floor(contentWidth * 25 / 85)
                // 마지막 셀이 반올림 오차를 흡수해 빈 여백을 없앰
                let buttonsWidth     = contentWidth - imagesWidth - collectionWidth - previewWidth

                func landscapeGroup(_ width: CGFloat) -> NSCollectionLayoutGroup {
                    NSCollectionLayoutGroup.vertical(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .absolute(width),
                            heightDimension: .fractionalHeight(1.0)),
                        subitems: [item])
                }

                let headerGroup      = landscapeGroup(headerWidth)
                let imagesGroup      = landscapeGroup(imagesWidth)
                let collectionGroup  = landscapeGroup(collectionWidth)
                let previewGroup     = landscapeGroup(previewWidth)
                let buttonsGroup     = landscapeGroup(buttonsWidth)

                let mainGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)),
                    subitems: [headerGroup, imagesGroup, collectionGroup, previewGroup, buttonsGroup])

                return NSCollectionLayoutSection(group: mainGroup)

            } else {
                // ── Portrait ───────────────────────────────────────────────────
                // effectiveContentSize.height : SafeArea 및 콘텐츠 인셋을 제외한 실제 가용 높이
                // 5개 섹션(header / images / preview / collection / buttons)이
                // 가용 높이를 꽉 채우도록 절댓값으로 계산
                let section = sectionTypes[sectionIndex]

                let availableHeight = environment.container.effectiveContentSize.height
                let headerHeight: CGFloat = 54
                let contentHeight = availableHeight - headerHeight

                // 각 섹션 높이 비율: header(54pt 고정) / images:preview:collection:buttons = 25:25:20:15
                let imagesHeight     = floor(contentHeight * 25 / 85)
                let previewHeight    = floor(contentHeight * 25 / 85)
                let collectionHeight = floor(contentHeight * 20 / 85)
                // 마지막 섹션이 반올림 오차를 흡수해 빈 여백을 없앰
                let buttonsHeight    = contentHeight - imagesHeight - previewHeight - collectionHeight

                let groupSize: NSCollectionLayoutSize
                switch section {
                case .header:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(headerHeight))
                case .images:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(imagesHeight))
                case .preview:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(previewHeight))
                case .collection:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(collectionHeight))
                case .buttons:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(buttonsHeight))
                case .designScroll:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(floor(contentHeight * 25 / 85)))
                default:
                    groupSize = NSCollectionLayoutSize(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0))
                }

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

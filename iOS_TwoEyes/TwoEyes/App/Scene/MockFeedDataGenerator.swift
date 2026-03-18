//
//  MockFeedDataGenerator.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/27/26.
//

import Foundation

// MARK: - Mock Data Generator
class MockFeedDataGenerator {

    static func generateAllMockData() -> [FeedItemModel] {
        let authors = [
            "sanghwi_back",
            "ios_developer",
            "swift_fan",
            "code_master",
            "tech_writer"
        ]

        let descriptions = [
            "UICollectionView의 Diffable DataSource와 Compositional Layout을 활용한 복잡한 레이아웃 구성 방법을 배워봅시다.",
            "SwiftUI의 최신 기능들과 실전 팁들을 모아서 정리했습니다.",
            "앱의 성능을 높이기 위한 다양한 기법들을 소개합니다.",
            "메모리 누수를 방지하고 효율적으로 관리하는 방법입니다.",
            "async/await와 Combine을 활용한 비동기 프로그래밍 패턴입니다.",
        ]

        return (0..<5).map { index in
            // 이미지 수: index에 따라 1~3장 (슬라이더 테스트용)
            let imageCount = (index % 3) + 1
            // picsum.photos: seed 값으로 항상 동일한 이미지 반환
            let imageURLs: [URL] = (0..<imageCount).compactMap { imageIndex in
                let seed = index * 10 + imageIndex
                return URL(string: "https://picsum.photos/seed/\(seed)/600/600")
            }

            return FeedItemModel(
                images: imageURLs,
                author: authors[index % authors.count],
                description: descriptions[index % descriptions.count]
            )
        }
    }
}

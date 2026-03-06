//
//  MockFeedDataGenerator.swift
//  PhotoApp
//
//  Created by SangHwiBack on 2/27/26.
//

import UIKit

// MARK: - Mock Data Generator
class MockFeedDataGenerator {
    
    /// 모든 목 데이터를 생성합니다
    static func generateAllMockData() -> [FeedCell] {
        var data: [FeedCell] = []
        
        // thumbnail 셀들
        let thumbnails = generateMockThumbnails(count: 5)
        // contents 셀들
        let contents = generateMockContents(count: 5)
        
        for i in 0..<min(thumbnails.count, contents.count) {
            data.append(thumbnails[i])
            data.append(contents[i])
        }
        
        return data
    }
    
    /// 목 Thumbnail 데이터를 생성합니다
    static func generateMockThumbnails(count: Int) -> [FeedCell] {
        return (0..<count).map { index in
            let firstImage = createMockImage(withColor: .systemBlue, name: "first_\(index)")
            let secondImage: FeedThumbnail.Image? = index % 2 == 0 ?
            createMockImage(withColor: .systemGreen, name: "second_\(index)") : nil
            
            let thumbnail = FeedThumbnail(
                firstImage: firstImage,
                secondImage: secondImage
            )
            
            return .thumbnail(thumbnail)
        }
    }
    
    /// 목 Contents 데이터를 생성합니다
    static func generateMockContents(count: Int) -> [FeedCell] {
        let titles = [
            "iOS 개발 팁",
            "SwiftUI 완벽 가이드",
            "성능 최적화 방법",
            "메모리 관리 전략",
            "비동기 프로그래밍",
            "테스트 주도 개발",
            "클린 코드 작성법",
            "아키텍처 패턴"
        ]
        
        let contentsList = [
            "UICollectionView의 Diffable DataSource와 Compositional Layout을 활용한 복잡한 레이아웃 구성 방법을 배워봅시다.",
            "SwiftUI의 최신 기능들과 실전 팁들을 모아서 정리했습니다.",
            "앱의 성능을 높이기 위한 다양한 기법들을 소개합니다.",
            "메모리 누수를 방지하고 효율적으로 관리하는 방법입니다.",
            "async/await와 combine을 활용한 비동기 프로그래밍 패턴입니다.",
            "테스트를 먼저 작성하고 구현하는 TDD 방식의 개발입니다.",
            "읽기 좋은 코드를 작성하기 위한 원칙과 기법입니다.",
            "MVC, MVVM, VIPER 등 다양한 아키텍처 패턴을 비교합니다."
        ]
        
        return (0..<count).map { index in
            let contents = FeedContents(
                title: titles[index % titles.count],
                contents: contentsList[index % contentsList.count]
            )
            
            return .contents(contents)
        }
    }
    
    /// 단색 이미지를 생성합니다
    private static func createMockImage(withColor color: UIColor, name: String) -> FeedThumbnail.Image {
        let image = createColoredImage(color: color, size: CGSize(width: 200, height: 200))
        return FeedThumbnail.Image(image: image, imagePath: "/mock/images/\(name).jpg")
    }
    
    /// 특정 색상으로 채워진 UIImage를 생성합니다
    private static func createColoredImage(color: UIColor, size: CGSize) -> UIImage {
//        let rect = CGRect(origin: .zero, size: size)
//        
//        UIGraphicsBeginImageContextWithOptions(size, false, 0)
//        color.setFill()
//        UIRectFill(rect)
//        
//        let image = UIGraphicsImageRendererContext().currentImage
//        UIGraphicsEndImageContext()
//        
//        return image
        return UIImage(named: "Test") ?? UIImage()
    }
}

// MARK: - Convenient Extensions
extension Array where Element == FeedCell {
    /// 특정 개수만큼만 반환합니다
    func take(_ count: Int) -> [FeedCell] {
        return Array(self.prefix(count))
    }
}

// MARK: - Usage Example
extension MockFeedDataGenerator {
    /// 사용 예제
    static func exampleUsage() {
        // 모든 목 데이터 생성
        let allData = generateAllMockData()
        print("Total mock data: \(allData.count)")
        
        // Thumbnail만 생성
        let thumbnails = generateMockThumbnails(count: 3)
        print("Generated thumbnails: \(thumbnails.count)")
        
        // Contents만 생성
        let contents = generateMockContents(count: 4)
        print("Generated contents: \(contents.count)")
        
        // 데이터 섞기
        let shuffledData = allData.shuffled()
        print("Shuffled data: \(shuffledData.count)")
        
        // 처음 5개만 가져오기
        let firstFive = allData.take(5)
        print("First 5 items: \(firstFive.count)")
    }
}

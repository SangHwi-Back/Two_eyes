//
//  DownloadImageView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/15/26.
//

import SwiftUI

/// NSCache
struct DownloadImageView: View {
    let url: URL?
    
    @State private var image: UIImage?
    
    var body: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
                .containerRelativeFrame(.horizontal, count: 1, spacing: 0)
                .clipped()
                .onDisappear {
                    // 뷰에 올라간 이미지 제거. 메모리 관리
                    self.image = nil
                }
        } else {
            ProgressView().frame(width: 24, height: 24).onAppear {
                if let url {
                    
                    let model = DownloadImageModel(image: image, imageUrl: url)
                    
                    ImageCache.shared.load(
                        url: url as NSURL,
                        item: model
                    ) { item, image in
                        self.image = image
                    }
                }
            }
        }
    }
}

struct DownloadImageModel {
    var image: UIImage?
    var imageUrl: URL
}

class ImageCache {
    static let shared = ImageCache()
    
    // .epemeral: 따로 NSCache를 사용하기 때문에 URLSession에서 cache를 사용하지 않게끔 설정
    let urlSession = URLSession(configuration: .ephemeral)
    
    var cachedImages: NSCache<NSURL, UIImage> = .init()
    var waitingClosure: [NSURL: [(DownloadImageModel, UIImage?) -> Void]] = .init()
    
    private func getImage(url: NSURL) -> UIImage? {
        return cachedImages.object(forKey: url)
    }
    
    func load(url: NSURL, item: DownloadImageModel, completion: @escaping (DownloadImageModel, UIImage?) -> Void) {
        // Cache에 저장된 이미지가 있는 경우
        if let cachedImage = getImage(url: url) { // Memory
            DispatchQueue.main.async {
                completion(item, cachedImage)
            }
            return
        } else if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
                  let imageName = url.lastPathComponent,
                  imageName.isEmpty == false
        { // Disk
            var filePath = URL(fileURLWithPath: path)
            filePath.appendPathComponent(imageName)
            
            if FileManager.default.fileExists(atPath: filePath.path()),
               let data = try? Data(contentsOf: filePath),
               let image = UIImage(data: data) {
                cachedImages.setObject(image, forKey: url, cost: data.count)
                DispatchQueue.main.async {
                    completion(item, image)
                }
                return
            }
        }
        
        // Cache에 저장된 이미지가 없는 경우, 서버로 부터 데이터를 가져오고나서 데이터를 completion에 넘겨주어야 하기때문에 기록
        if waitingClosure[url] != nil {
            /// 이미 같은 url에 대해서 처리중인 경우
            waitingClosure[url]?.append(completion)
            return
        } else {
            /// 해당 url처리가 처음인 경우 > URLSession으로 data 획득 필요
            waitingClosure[url] = [completion]
        }
        
        let task = urlSession.dataTask(with: url as URL) { data, response, error in
            // 이미지 data 획득
            guard let responseData = data,
                  let image = UIImage(data: responseData),
                  let blocks = self.waitingClosure[url], error == nil else {
                DispatchQueue.main.async {
                    completion(item, nil)
                }
                return
            }
            
            // 메모리 캐시에 저장 후 completion에 전달
            self.cachedImages.setObject(image, forKey: url, cost: responseData.count)
            
            self.waitingClosure.removeValue(forKey: url)
            for block in blocks {
                DispatchQueue.main.async {
                    block(item, image)
                }
            }
            
            // 디스크 캐시에 저장
            if let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first,
               let imageName = url.lastPathComponent,
               imageName.isEmpty == false
            {
                var filePath = URL(fileURLWithPath: path)
                filePath.appendPathComponent(imageName)
                
                FileManager.default.createFile(atPath: filePath.path(), contents: data)
            }
            
            return
        }
        
        task.resume()
    }
}

#Preview {
    DownloadImageView(url: nil)
}

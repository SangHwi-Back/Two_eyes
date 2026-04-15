//
//  PreviewPickImageMergeView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/15/26.
//

import SwiftUI
import Photos

struct PreviewPickImageMergeView: View {
    @State var asset: PHAsset?
    @State var progressText = "Start!"
    
    var body: some View {
        Group {
            if let asset {
                PickImageMergeView(model: .init(leading: asset, trailing: asset))
            } else {
                VStack {
                    ProgressView()
                    Text(progressText)
                }
            }
        }.onAppear {
            if let image = UIImage(named: "lenna") {
                var placeHolder: PHObjectPlaceholder?
                PHPhotoLibrary.shared().performChanges {
                    progressText = "Performing!"
                    let request = PHAssetChangeRequest.creationRequestForAsset(from: image)
                    placeHolder = request.placeholderForCreatedAsset
                } completionHandler: { success, error in
                    progressText = """
Feching is \(success ? "Success" : "Failure").
error is \(error?.localizedDescription ?? "Not determined").
placeholder id is \(placeHolder?.localIdentifier ?? "not recognized")
"""
                    if success, let localIdentifier = placeHolder?.localIdentifier {
                        // Fetch the PHAsset using its local identifier
                        let result = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: nil)
                        let asset = result.firstObject
                        self.asset = asset
                    }
                }
            } else {
                progressText = "Where is Lenna?"
            }
        }
    }
}

#Preview {
    PreviewPickImageMergeView()
}

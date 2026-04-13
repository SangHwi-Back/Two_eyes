//
//  PickImageMergeView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/13/26.
//

import SwiftUI

struct PickImageMergeView: View {
    let leadingImage: UIImage
    let trailingImage: UIImage
    var body: some View {
        HStack {
            Image(uiImage: leadingImage)
            Image(uiImage: trailingImage)
        }
    }
}

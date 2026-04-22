//
//  GlassIconButton.swift
//  iosApp
//
//  Created by SangHwiBack on 4/22/26.
//

import SwiftUI
import Shared
import Photos

struct GlassIconButton: View {
    
    let systemName: String
    let action: () -> Void
    
    var body: some View {
        Button { action() } label: {
            Image(systemName: systemName)
                .resizable()
                .scaledToFit()
                .padding(4)
                .frame(width: 40, height: 40)  // label 자체를 정사각형으로 → glass가 정원을 그림
                .allowsHitTesting(false)
        }
        .buttonStyle(.glass)
    }
}

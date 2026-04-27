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

struct GlassIconTitleButton: View {
    let systemName: String?
    let title: String
    let action: () -> Void
    
    init(systemName: String? = nil, title: String, action: @escaping () -> Void) {
        self.systemName = systemName
        self.title = title
        self.action = action
    }
    
    var body: some View {
        Button { action() } label: {
            if let systemName {
                Label {
                    Text(verbatim: title)
                        .font(Font.system(size: 13.6, weight: .semibold, design: .rounded))
                } icon: {
                    Image(systemName: systemName)
                        .resizable()
                        .scaledToFit()
                        .padding(4)
                        .frame(width: 40, height: 40)  // label 자체를 정사각형으로 → glass가 정원을 그림
                        .allowsHitTesting(false)
                }
            }
            else {
                Text(verbatim: title)
                    .font(Font.system(size: 13.6, weight: .semibold, design: .rounded))
                    .padding(.horizontal, 8)
                    .frame(height: 40)
            }
        }
        .buttonStyle(.glass)
    }
}

#Preview {
    VStack {
        GlassIconButton(systemName: "trash") {
            
        }
        
        GlassIconTitleButton(title: "Tap the trash button!") {
            
        }
        
        GlassIconTitleButton(systemName: "trash", title: "Tap the trash button!") {
            
        }
    }
}

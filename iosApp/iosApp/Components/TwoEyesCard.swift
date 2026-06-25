//
//  TwoEyesCard.swift
//  iosApp
//
//  Created by SangHwiBack on 4/22/26.
//

import SwiftUI
import Shared

struct TwoEyesCard<T: View>: View {
    
    var contents: () -> T
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(AppColors.shared.Surface.color)
                .border(Color.black, width: 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            contents()
        }
    }
}

struct TwoEyesChip: View {
    var title: String
    var body: some View {
        Text(title)
            .font(Font.system(size: 13.6, weight: .semibold, design: .rounded))
            .foregroundStyle(AppColors.shared.TextPrimary.color)
            .padding(.vertical)
            .padding(.horizontal, 16)
            .background(AppColors.shared.Surface2.color, in: Capsule())
    }
}

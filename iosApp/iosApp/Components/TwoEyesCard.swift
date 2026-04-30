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
                .fill(AppColors.shared.Background.color)
                .border(Color.black, width: 1)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            contents()
        }
    }
}

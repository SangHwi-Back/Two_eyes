//
//  UploadCreateFeedView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/24/26.
//

import SwiftUI
import Shared
import Photos

struct UploadCreateFeedView: View {
    @Environment(\.apiClient) var apiClient
    @Environment(\.appConstant) var constant
    
    @State var dto: UploadMergedDTO
    @State var tagTextFieldValue = ""
    @State var tags = [String]()
    
    let entity: MergeResultEntity
    let viewModel : UploadViewModel
    
    init(entity: MergeResultEntity, vm: UploadViewModel) {
        self.entity = entity
        self.viewModel = vm
        self.dto = .init(
            imageIds: [
                entity.resultId,
                entity.leadingImageId,
                entity.trailingImageId
            ],
            tags: [],
            contents: "")
    }
    
    var body: some View {
        ScrollViewContents
            .navigationTitle("Upload")
            .navigationBarTitleDisplayMode(.large)
            .background(AppColors.shared.Background.color)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    GlassIconTitleButton(
                        systemName: "square.and.arrow.up.on.square",
                        title: "Confirm"
                    ) {
                        actionConfirmButton()
                    }
                }
            }
    }
    
    @ViewBuilder
    var ScrollViewContents: some View {
        ScrollView { VStack {
            TwoEyesCard {
                TextField("Contents", text: $dto.contents)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(AppColors.shared.Primary.color)
                    .background(Color.clear)
                    .padding()
            }
            
            Divider().padding()
            
            TwoEyesCard {
                VStack {
                    HStack(alignment: .center) {
                        TextField("Tags", text: $tagTextFieldValue)
                            .textFieldStyle(.roundedBorder)
                            .foregroundStyle(AppColors.shared.Primary.color)
                            .background(Color.clear)
                        
                        Spacer()
                        
                        GlassIconButton(systemName: "plus") {
                            actionPlusButton()
                        }
                    }
                    .padding()
                    
                    ScrollView(.horizontal) { HStack(spacing: 8) {
                        ForEach($tags, id: \.self) {
                            TwoEyesChip(title: $0.wrappedValue)
                                .padding(.leading)
                                .padding(
                                    .trailing,
                                    $0.wrappedValue == tags.last ? 8 : 0)
                        }
                    } }
                    .frame(height: $tags.isEmpty ? 0 : 56)
                    .padding(.bottom)
                }
            }
            
            Divider().padding()
            
            HStack {
                Text("Result :")
                    .font(.title2)
                    .foregroundStyle(AppColors.shared.TextPrimary.color)
                PHAssetImage(assetIdentifier: dto.imageIds[0])
                Spacer()
            }
            .padding()
            
            HStack {
                PHAssetImage(assetIdentifier: dto.imageIds[1])
                PHAssetImage(assetIdentifier: dto.imageIds[2])
                Spacer()
            }
            .padding()
        } }
        .onChange(of: tagTextFieldValue) { oldValue, newValue in
            if newValue.count > 15 {
                tagTextFieldValue = oldValue
            }
        }
    }
    
    private func actionPlusButton() {
        guard tagTextFieldValue.trimmingCharacters(in: .whitespaces).isEmpty == false else {
            return
        }
        
        tags.append(tagTextFieldValue)
        
        dto.tags = NSMutableArray(array: tags)
        
        tagTextFieldValue = ""
    }
    
    private func actionConfirmButton() {
        Task {
            try? await viewModel.uploadEntity(dto: dto)
        }
    }
}

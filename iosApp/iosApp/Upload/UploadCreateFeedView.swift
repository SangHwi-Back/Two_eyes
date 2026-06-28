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
    @Environment(\.database) var database

    @State var dto: UploadMergedDTO
    @State var tagTextFieldValue = ""
    @State var tags = [String]()
    @State private var isUploading = false
    @FocusState private var isContentFocused: Bool

    let entity: MergeResultEntity
    let viewModel: UploadViewModel

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
        ScrollView {
            VStack(spacing: 24) {
                ImagePreviewSection
                ContentSection
                TagsSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 32)
        }
        .navigationTitle("새 게시물")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.shared.Background.color)
        .toolbar { uploadToolbarButton }
        .onChange(of: tagTextFieldValue) { old, new in
            if new.count > 15 { tagTextFieldValue = old }
        }
        .onTapGesture { isContentFocused = false }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var uploadToolbarButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button(action: actionConfirmButton) {
                if isUploading {
                    ProgressView().tint(.white)
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                        Text("공유")
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(AppColors.shared.Primary.color)
                }
            }
            .disabled(isUploading)
        }
    }

    // MARK: - Image Preview

    private var ImagePreviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "photo.badge.checkmark", title: "결과물")

            // Main result — full-width, prominent
            PHAssetImage(assetIdentifier: dto.imageIds[0])
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .overlay(alignment: .bottomLeading) {
                    Label("합성 결과", systemImage: "wand.and.stars")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.ultraThinMaterial, in: Capsule())
                        .padding(12)
                }

            // Source images — side by side, compact
            HStack(spacing: 10) {
                sourceImageCard(index: 1, label: "원본 1")
                sourceImageCard(index: 2, label: "원본 2")
            }
        }
    }

    @ViewBuilder
    private func sourceImageCard(index: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption2)
                .foregroundStyle(AppColors.shared.TextSecondary.color)
            PHAssetImage(assetIdentifier: dto.imageIds[index])
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Content Editor

    private var ContentSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            sectionHeader(icon: "text.alignleft", title: "내용")

            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(AppColors.shared.Surface.color)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isContentFocused
                                    ? AppColors.shared.Primary.color.opacity(0.5)
                                    : AppColors.shared.Surface2.color,
                                lineWidth: 1
                            )
                    )
                    .animation(.easeInOut(duration: 0.2), value: isContentFocused)

                if dto.contents.isEmpty {
                    Text("이미지에 대한 이야기를 작성해보세요...")
                        .foregroundStyle(AppColors.shared.TextSecondary.color.opacity(0.5))
                        .font(.body)
                        .padding(.horizontal, 16)
                        .padding(.top, 14)
                        .allowsHitTesting(false)
                }

                TextEditor(text: $dto.contents)
                    .focused($isContentFocused)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .foregroundStyle(AppColors.shared.TextPrimary.color)
                    .font(.body)
                    .frame(minHeight: 130)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
            }

            HStack {
                Spacer()
                Text("\(dto.contents.count)자")
                    .font(.caption2)
                    .foregroundStyle(AppColors.shared.TextSecondary.color.opacity(0.5))
                    .monospacedDigit()
            }
        }
    }

    // MARK: - Tags

    private var TagsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "tag", title: "태그")

            // Input row
            HStack(spacing: 10) {
                HStack(spacing: 8) {
                    Image(systemName: "number")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.shared.Secondary.color)
                    TextField("태그 추가 (최대 15자)", text: $tagTextFieldValue)
                        .foregroundStyle(AppColors.shared.TextPrimary.color)
                        .submitLabel(.done)
                        .onSubmit { actionPlusButton() }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 11)
                .background(AppColors.shared.Surface.color)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.shared.Surface2.color, lineWidth: 1)
                )

                Button(action: actionPlusButton) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(
                            tagTextFieldValue.trimmingCharacters(in: .whitespaces).isEmpty
                                ? AppColors.shared.Secondary.color.opacity(0.4)
                                : AppColors.shared.Primary.color
                        )
                        .animation(.easeInOut(duration: 0.15), value: tagTextFieldValue.isEmpty)
                }
                .disabled(tagTextFieldValue.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            if !tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(tags, id: \.self) { tag in
                            TagChip(tag: tag)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
    }

    @ViewBuilder
    private func TagChip(tag: String) -> some View {
        HStack(spacing: 6) {
            Text("#\(tag)")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(AppColors.shared.Primary.color)
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    tags.removeAll { $0 == tag }
                    dto.tags = NSMutableArray(array: tags)
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(AppColors.shared.TextSecondary.color)
            }
        }
        .padding(.leading, 12)
        .padding(.trailing, 10)
        .padding(.vertical, 7)
        .background(AppColors.shared.Surface.color)
        .clipShape(Capsule())
        .overlay(Capsule().stroke(AppColors.shared.Primary.color.opacity(0.25), lineWidth: 1))
    }

    // MARK: - Helpers

    @ViewBuilder
    private func sectionHeader(icon: String, title: String) -> some View {
        Label(title, systemImage: icon)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(AppColors.shared.TextSecondary.color)
            .textCase(.uppercase)
            .tracking(0.5)
    }

    private func actionPlusButton() {
        let trimmed = tagTextFieldValue.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            tags.append(trimmed)
            dto.tags = NSMutableArray(array: tags)
            tagTextFieldValue = ""
        }
    }

    private func actionConfirmButton() {
        guard !isUploading else { return }
        isUploading = true
        Task {
            _ = try? await viewModel.uploadEntity(dto: dto)
            // 에러 발생 시 AppErrorBus 가 앱 루트에서 알럿으로 표시
            self.isUploading = false
        }
    }
}

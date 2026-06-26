//
//  UploadView.swift
//  iosApp
//
//  Created by SangHwiBack on 4/9/26.
//

import SwiftUI
import Shared
import Photos
import UIKit

private extension Bundle {
    var displayName: String {
        (object(forInfoDictionaryKey: "CFBundleDisplayName") as? String)
        ?? (object(forInfoDictionaryKey: "CFBundleName") as? String)
        ?? "이 앱"
    }
}

enum UploadableListViewType { case small, large }
enum UploadViewTapType { case delete, list }

struct UploadView: View {
    @EnvironmentObject var navHost: NavigationPathObject<NavHost.Upload>
    
    @State var listType = UploadableListViewType.small
    
    // @State로 선언해야 SwiftUI가 부모 재렌더링 시 기존 인스턴스를 보존함
    @State private var wrapper: UploadViewModelWrapper
    
    // 사진 라이브러리 전체 접근 권한 상태 — 앱이 기억하도록 View 레벨에서 관리
    @State private var photoAuthStatus: PHAuthorizationStatus =
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
    private let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(database: AppDatabase, client: ApiClient) {
        _wrapper = State(wrappedValue: UploadViewModelWrapper(
            db: database,
            client: client
        ))
    }
    
    var body: some View {
        Group {
            switch photoAuthStatus {
            case .authorized:
                contentView
            case .notDetermined:
                // 권한 요청 중
                ProgressView("사진 접근 권한 확인 중…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                // denied / restricted / limited → 설정으로 안내
                photoAccessDeniedView
            }
        }
        .task {
            // 이미 결정된 경우 재요청 없음 (iOS 가 선택을 기억)
            guard photoAuthStatus == .notDetermined else { return }
            photoAuthStatus = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    continuation.resume(returning: status)
                }
            }
        }
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                GlassIconButton(systemName: "list.dash") {
                    listType = .small
                }
                GlassIconButton(systemName: "list.dash.header.rectangle") {
                    listType = .large
                }
            }
        }
    }

    // MARK: - 콘텐츠 뷰 (authorized 상태)
    
    @ViewBuilder
    private var contentView: some View {
        if wrapper.entities.isEmpty {
            Text("No Entities!!")
        } else {
            switch listType {
            case .small:
                List(wrapper.entities, id: \.id) { entity in
                    UploadListSmallCard(entity: entity) { tapType in
                        onTap(tapType, entity: entity)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            onTap(.delete, entity: entity)
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .listRowBackground(AppColors.shared.Background.color)
                }
                // List 기본 흰색 배경 제거 후 앱 배경색 적용
                .scrollContentBackground(.hidden)
                .background(AppColors.shared.Background.color)
            case .large:
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(wrapper.entities, id: \.id) { entity in
                            UploadGridCard(entity: entity) { tapType in
                                onTap(tapType, entity: entity)
                            }
                            .overlay(alignment: .topTrailing) {
                                GlassIconButton(systemName: "trash.circle") {
                                    onTap(.delete, entity: entity)
                                }
                            }
                        }
                    }
                }
                .background(AppColors.shared.Background.color)
            }
        }
    }
    
    // MARK: - 권한 거부 / 제한 안내 뷰
    
    @ViewBuilder
    private var photoAccessDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(AppColors.shared.Secondary.color)
            Text("사진 전체 접근 권한이 필요합니다")
                .font(.headline)
                .foregroundStyle(AppColors.shared.TextPrimary.color)
            Text("설정 > 개인 정보 보호 > 사진에서\n'\(Bundle.main.displayName)'의 접근을 '모든 사진'으로 변경해주세요.")
                .font(.subheadline)
                .foregroundStyle(AppColors.shared.TextSecondary.color)
                .multilineTextAlignment(.center)
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.glass)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func onTap(_ tap: UploadViewTapType, entity: MergeResultEntity) {
        switch tap {
        case .delete:
            wrapper.deleteEntity(entity)
        case .list:
            navHost.push(to: .upload(entity, wrapper.viewModel))
        }
    }
}

struct UploadListSmallCard: View {
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        TwoEyesCard {
            ScrollView(.horizontal) {
                HStack {
                    ForEach([
                        entity.resultId,
                        entity.leadingImageId,
                        entity.trailingImageId
                    ], id: \.self) { id in
                        PHAssetImage(assetIdentifier: id, size: thumbnailSize * 0.9)
                    }
                }
                .padding()
            }
        }
        .frame(height: thumbnailSize.height + 20)
        .onTapGesture {
            onTap(.list)
        }
    }
}

struct UploadGridCard: View {
    @Namespace var namespace
    let entity: MergeResultEntity
    let onTap: (UploadViewTapType) -> Void
    var body: some View {
        PHAssetImage(assetIdentifier: entity.resultId, size: thumbnailSize)
            .aspectRatio(1.58, contentMode: .fill)
            .clipped()
            .onTapGesture {
                onTap(.list)
            }
            .overlay(alignment: .topTrailing) {
                GlassIconButton(systemName: "trash.circle") {
                    onTap(.delete)
                }
            }
    }
}

#Preview {
    UploadView(
        database: Database_iosKt.getAppDatabase(),
        client: ApiClient()
    )
}

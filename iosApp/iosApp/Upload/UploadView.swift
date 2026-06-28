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
    @State private var wrapper: UploadViewModelWrapper
    @State private var photoAuthStatus: PHAuthorizationStatus =
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    
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
                ContentView
            case .notDetermined:
                ProgressView("사진 접근 권한 확인 중…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            default:
                photoAccessDeniedView
            }
        }
        .task {
            guard photoAuthStatus == .notDetermined else { return }
            photoAuthStatus = await withCheckedContinuation { continuation in
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                    continuation.resume(returning: status)
                }
            }
        }
        .navigationTitle("Upload")
        .navigationBarTitleDisplayMode(.large)
        .toolbar { layoutToggleToolbar }
    }
    
    // MARK: - Toolbar
    
    @ToolbarContentBuilder
    private var layoutToggleToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Picker("레이아웃", selection: $listType) {
                Image(systemName: "list.bullet")
                    .tag(UploadableListViewType.small)
                Image(systemName: "square.grid.2x2")
                    .tag(UploadableListViewType.large)
            }
            .pickerStyle(.segmented)
            .frame(width: 88)
        }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var ContentView: some View {
        if wrapper.entities.isEmpty {
            emptyStateView
        } else {
            switch listType {
            case .small:
                ListContentView
            case .large:
                GridContentView
            }
        }
    }

    // MARK: - List

    private var ListContentView: some View {
        List(wrapper.entities, id: \.id) { entity in
            UploadListRow(entity: entity) {
                onTap(.list, entity: entity)
            }
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(role: .destructive) {
                    onTap(.delete, entity: entity)
                } label: {
                    Label("삭제", systemImage: "trash")
                }
            }
            .listRowInsets(.init(top: 6, leading: 16, bottom: 6, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.shared.Background.color)
    }
    
    // MARK: - Grid
    
    private let gridColumns = [GridItem(.flexible(), spacing: 4), GridItem(.flexible(), spacing: 4)]
    
    private var GridContentView: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 4) {
                ForEach(wrapper.entities, id: \.id) { entity in
                    UploadGridCell(entity: entity) {
                        onTap(.list, entity: entity)
                    } onDelete: {
                        onTap(.delete, entity: entity)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .background(AppColors.shared.Background.color)
    }
    
    // MARK: - Empty State
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "photo.stack")
                .font(.system(size: 64, weight: .thin))
                .foregroundStyle(AppColors.shared.Secondary.color)
            VStack(spacing: 6) {
                Text("업로드할 항목이 없습니다")
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.TextPrimary.color)
                Text("카메라 탭에서 두 장의 사진을 합성한 뒤\n여기서 게시물로 업로드할 수 있습니다.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.TextSecondary.color)
                    .multilineTextAlignment(.center)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.shared.Background.color)
    }
    
    // MARK: - Permission Denied
    
    private var photoAccessDeniedView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "photo.badge.exclamationmark")
                .font(.system(size: 56, weight: .thin))
                .foregroundStyle(AppColors.shared.Secondary.color)
            
            VStack(spacing: 6) {
                Text("사진 접근 권한이 필요합니다")
                    .font(.headline)
                    .foregroundStyle(AppColors.shared.TextPrimary.color)
                Text("설정 > 개인 정보 보호 > 사진에서\n'\(Bundle.main.displayName)'의 접근을\n'모든 사진'으로 변경해주세요.")
                    .font(.subheadline)
                    .foregroundStyle(AppColors.shared.TextSecondary.color)
                    .multilineTextAlignment(.center)
            }
            
            Button("설정 열기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.glass)
            .padding(.top, 4)
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.shared.Background.color)
    }
    
    // MARK: - Actions
    
    func onTap(_ tap: UploadViewTapType, entity: MergeResultEntity) {
        switch tap {
        case .delete:
            wrapper.deleteEntity(entity)
        case .list:
            navHost.push(to: .upload(entity, wrapper.viewModel))
        }
    }
}

// MARK: - List Row

struct UploadListRow: View {
    let entity: MergeResultEntity
    let onTap: () -> Void
    
    private let resultSize = CGSize(width: 76, height: 76)
    private let sourceSize = CGSize(width: 36, height: 52)
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                ScrollView(.horizontal) { HStack(spacing: 0) {
                    // 합성 결과 이미지
                    PHAssetImage(
                        assetIdentifier: entity.resultId,
                        size: resultSize,
                        showBackground: false
                    )
                    
                    Divider()
                        .background(AppColors.shared.Divider.color)
                        .padding(.horizontal, 6)
                    
                    // 원본 이미지 2장
                    ForEach([entity.leadingImageId, entity.trailingImageId], id: \.self) { id in
                        PHAssetImage(
                            assetIdentifier: id,
                            size: sourceSize,
                            showBackground: false
                        )
                        .padding(.trailing, 6)
                    }
                } }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppColors.shared.TextSecondary.color.opacity(0.5))
            }
            .padding(12)
        }
        .background(AppColors.shared.Surface.color)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .buttonStyle(.plain)
    }
}

// MARK: - Grid Cell

struct UploadGridCell: View {
    let entity: MergeResultEntity
    let onTap: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        GeometryReader { geo in
            let side = geo.size.width
            ZStack(alignment: .topTrailing) {
                TwoEyesCard {
                    // 결과 이미지 — 셀 전체를 채움
                    PHAssetImage(
                        assetIdentifier: entity.resultId,
                        size: CGSize(width: side, height: side),
                        showBackground: false
                    )
                    .frame(width: side, height: side)
                    .clipped()
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onTap)
                }
                
                // 상단 그라디언트 (삭제 버튼 가독성)
                LinearGradient(
                    colors: [.black.opacity(0.4), .clear],
                    startPoint: .top,
                    endPoint: .center
                )
                .frame(width: side, height: side)
                .allowsHitTesting(false)
                
                // 삭제 버튼
                Button(action: onDelete) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                }
                .padding(8)
            }
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

//
//  SearchModalView.swift
//  iosApp
//

import SwiftUI
import Shared

struct SearchModalView: View {
    @Binding var tabSelection: TabSelection
    @State private var searchText = ""
    @State private var pendingTab: TabSelection? = nil

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            HStack(spacing: 12) {
                // 리퀴드 글래스 버튼 그룹
                HStack(spacing: 0) {
                    SearchNavButton(icon: "text.below.photo") { requestSwitch(to: .feed) }
                    SearchNavButton(icon: "camera")           { requestSwitch(to: .camera) }
                    SearchNavButton(icon: "square.and.arrow.up") { requestSwitch(to: .upload) }
                }
                .glassEffect(in: Capsule())

                // 리퀴드 글래스 텍스트필드
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(.secondary)
                    TextField("Search", text: $searchText)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                }
                .padding(.horizontal, 16)
                .frame(height: 48)
                .glassEffect(in: Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.shared.Background.color.ignoresSafeArea())
        .alert("화면을 이동할까요?", isPresented: Binding(
            get: { pendingTab != nil },
            set: { if !$0 { pendingTab = nil } }
        )) {
            Button("확인") {
                if let tab = pendingTab { tabSelection = tab }
                pendingTab = nil
            }
            Button("취소", role: .cancel) {
                pendingTab = nil
            }
        } message: {
            Text("검색어가 지워집니다. 계속 이동하시겠습니까?")
        }
    }

    private func requestSwitch(to tab: TabSelection) {
        if searchText.isEmpty {
            tabSelection = tab
        } else {
            pendingTab = tab
        }
    }
}

// MARK: - Search Nav Button

struct SearchNavButton: View {
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 17, weight: .medium))
                .frame(width: 52, height: 48)
        }
        .buttonStyle(.plain)
        .foregroundStyle(.primary)
    }
}

package com.example.twoeyesproject

import com.example.twoeyesproject.platformspecific.PlatformImage
import kotlinx.cinterop.ExperimentalForeignApi
import platform.UIKit.NSCollectionLayoutDimension
import platform.UIKit.NSCollectionLayoutEnvironmentProtocol
import platform.UIKit.NSCollectionLayoutGroup
import platform.UIKit.NSCollectionLayoutItem
import platform.UIKit.NSCollectionLayoutSection
import platform.UIKit.NSCollectionLayoutSize
import platform.UIKit.UICollectionViewCompositionalLayout
import platform.UIKit.UICollectionViewCompositionalLayoutSectionProvider
import platform.UIKit.UITraitCollection
import platform.UIKit.UIUserInterfaceSizeClassCompact
import platform.darwin.NSInteger

@OptIn(ExperimentalForeignApi::class)
class PickImageCompositionalLayout {
    enum class Section {
        HEADER, SELECTED_IMAGES, ALL_IMAGES, PREVIEW, BUTTONS, LANDSCAPE_SCROLL, LANDSCAPE
    }
    sealed class Item {
        class HEADER
        data class SELECTED_IMAGES(val images: List<PlatformImage>)
        data class ALL_IMAGES(val images: List<PlatformImage>)
        data class PREVIEW(val leftImage: PlatformImage, val rightImage: PlatformImage)
        class BUTTONS
        class LANDSCAPE_SCROLL
        class LANDSCAPE
    }
    
    fun createLayout(traitCollection: UITraitCollection): UICollectionViewCompositionalLayout {
        val result = UICollectionViewCompositionalLayout(fun(sectionIndex: NSInteger, environment: NSCollectionLayoutEnvironmentProtocol?): NSCollectionLayoutSection? {
            val item = NSCollectionLayoutItem.itemWithLayoutSize(
                NSCollectionLayoutSize.sizeWithWidthDimension(
                    NSCollectionLayoutDimension.fractionalWidthDimension(1.0),
                    NSCollectionLayoutDimension.fractionalHeightDimension(1.0),
                )
            )

            if (environment?.traitCollection?.verticalSizeClass == UIUserInterfaceSizeClassCompact) {
// ── Landscape ──────────────────────────────────────────────────
                // effectiveContentSize.width : SafeArea 및 콘텐츠 인셋을 제외한 실제 가용 너비
                // 5개 셀(buttons / selectedImages / preview / collection / designScroll)이
                // 가용 너비를 꽉 채우도록 절댓값으로 계산
                val availableWidth = environment.container.effectiveContentSize.size
                val headerWidth = 54f
                val contentWidth = availableWidth - headerWidth

                // 각 셀 너비 비율: buttons(54pt 고정) / images:collection:preview:designScroll = 25:20:25:15

                val imagesWidth      = (contentWidth * 25 / 85).toDouble()
                val collectionWidth  = (contentWidth * 20 / 85).toDouble()
                val previewWidth     = (contentWidth * 25 / 85).toDouble()
                // 마지막 셀이 반올림 오차를 흡수해 빈 여백을 없앰
                val buttonsWidth     = contentWidth - imagesWidth - collectionWidth - previewWidth

                fun landscapeGroup(width: Float): NSCollectionLayoutGroup =
                    NSCollectionLayoutGroup.verticalGroupWithLayoutSize(
                        NSCollectionLayoutSize.sizeWithWidthDimension(
                            NSCollectionLayoutDimension.absoluteDimension(imagesWidth),
                            NSCollectionLayoutDimension.fractionalHeightDimension(1.0),
                        ),
                        repeatingSubitem = item,
                        count = 1
                    )

                val headerGroup      = landscapeGroup(headerWidth)
                val imagesGroup      = landscapeGroup(imagesWidth.toFloat())
                val collectionGroup  = landscapeGroup(collectionWidth.toFloat())
                val previewGroup     = landscapeGroup(previewWidth.toFloat())
                val buttonsGroup     = landscapeGroup(buttonsWidth.toFloat())

                val mainGroup = NSCollectionLayoutGroup.horizontalGroupWithLayoutSize(
                    NSCollectionLayoutSize.sizeWithWidthDimension(
                        NSCollectionLayoutDimension.fractionalWidthDimension(1.0),
                        NSCollectionLayoutDimension.fractionalHeightDimension(1.0)
                    ),
                    subitems = listOf(headerGroup, imagesGroup, collectionGroup, previewGroup, buttonsGroup)
                )

                return NSCollectionLayoutSection.sectionWithGroup(mainGroup)
            } else {
// ── Portrait ───────────────────────────────────────────────────
                // effectiveContentSize.height : SafeArea 및 콘텐츠 인셋을 제외한 실제 가용 높이
                // 5개 섹션(header / images / preview / collection / buttons)이
                // 가용 높이를 꽉 채우도록 절댓값으로 계산
                val section = getSectionType(traitCollection).get(sectionIndex.toInt())

                val availableHeight = environment?.container?.effectiveContentSize?.align ?: 0
                val headerHeight = 54f
                val contentHeight = availableHeight - headerHeight

                // 각 섹션 높이 비율: header(54pt 고정) / images:preview:collection:buttons = 25:25:20:15
                val imagesHeight     = (contentHeight * 25 / 85)
                val previewHeight    = (contentHeight * 25 / 85)
                val collectionHeight = (contentHeight * 20 / 85)
                // 마지막 섹션이 반올림 오차를 흡수해 빈 여백을 없앰
                val buttonsHeight    = contentHeight - imagesHeight - previewHeight - collectionHeight


                val heightDimension = if (section == Section.HEADER)
                    NSCollectionLayoutDimension.absoluteDimension(headerHeight.toDouble())
                else if (section == Section.SELECTED_IMAGES)
                    NSCollectionLayoutDimension.absoluteDimension(imagesHeight.toDouble())
                else if (section == Section.PREVIEW)
                    NSCollectionLayoutDimension.absoluteDimension(previewHeight.toDouble())
                else if (section == Section.ALL_IMAGES)
                    NSCollectionLayoutDimension.absoluteDimension(collectionHeight.toDouble())
                else if (section == Section.BUTTONS)
                    NSCollectionLayoutDimension.absoluteDimension(buttonsHeight.toDouble())
                else if (section == Section.LANDSCAPE_SCROLL)
                    NSCollectionLayoutDimension.absoluteDimension((contentHeight * 25 / 85).toDouble())
                else
                    NSCollectionLayoutDimension.fractionalHeightDimension(1.0)

                val groupSize = NSCollectionLayoutSize.sizeWithWidthDimension(
                    NSCollectionLayoutDimension.fractionalWidthDimension(1.0),
                    heightDimension)

                val group = NSCollectionLayoutGroup.verticalGroupWithLayoutSize(groupSize, listOf(item))
                return NSCollectionLayoutSection.sectionWithGroup(group)
            }
        })

        return result
    }

    fun getSectionType(traitCollection: UITraitCollection): List<Section> =
        if (traitCollection.verticalSizeClass == UIUserInterfaceSizeClassCompact) listOf(Section.LANDSCAPE)
        else listOf(Section.HEADER, Section.SELECTED_IMAGES, Section.PREVIEW, Section.ALL_IMAGES, Section.BUTTONS)
}
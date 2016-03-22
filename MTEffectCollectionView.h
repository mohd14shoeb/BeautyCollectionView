//
//  MTEffectCollectionView.h
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTCameraEffectCategory.h"

@class MTEffectCollectionView;

@protocol MTEffectCollectionViewDelegate <NSObject>

/**
 *  选择当前特效
 *
 *  @param effectCollectionView 特效选择栏
 *  @param effectID             特效ID
 *  @param indexPath            当前特效cell的indexPath
 */
- (void)effectCollectionView:(MTEffectCollectionView *)effectCollectionView
           didSelectCategory:(MTCameraEffectCategory *)effectCategory
                      effect:(MTCameraEffect *)effect;
@optional

/**
 *  展开特效的section
 *
 *  @param collectionView
 *  @param indexPath      展开section的indexPath
 */
- (void)effectCollectionView:(MTEffectCollectionView *)collectionView didExpandItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  收起特效的section
 *
 *  @param collectionView
 *  @param indexPath      收起section的indexPath
 */
- (void)effectCollectionView:(MTEffectCollectionView *)collectionView didCollapseItemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  获得展开section所处位置 和展开section的长度
 *
 *  @param collectionView
 *  @param position       section的位置
 *  @param length         section的长度
 */
- (void)effectCollectionView:(MTEffectCollectionView *)collectionView didExpandItemAtPosition:(CGPoint)position;

/**
 *  更新collectonView contentOffset的位置
 *
 *  @param collectionView
 *  @param newOffset      更新的contentOffset
 */
- (void)effectCollectionView:(MTEffectCollectionView *)collectionView updateContentOffset:(CGPoint)newOffset;

/**
 *  更新section的长度
 *
 *  @param collectionView
 *  @param length         更新的长度
 */
- (void)effectCollectionView:(MTEffectCollectionView *)collectionView updateSectionLength:(CGFloat)length;

@end

@interface MTEffectCollectionView : UICollectionView

@property (weak, nonatomic) id<MTEffectCollectionViewDelegate> effectDelegate;

@property (assign, nonatomic) BOOL beforeCapture;
@property (strong, nonatomic) NSArray *sectionDatasource;   /**< 数据源 */

/**
 *  开启特效选择栏
 *
 *  @param indexPath 选中特效cell的indexPath
 */
- (void)showEffectCollectionViewAtIndexPath:(NSIndexPath *)indexPath needAnimation:(BOOL)isNeedAnimation;

/**
 *  选中特效
 *
 *  @param indexPath  选中的特效
 *  @param completion 完成回调
 */
- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL finished))completion;

/**
 *  获取当前展开的section
 *
 *  @return 返回展开的section数组
 */
- (NSArray*)expandedSectionIndexPaths;

- (void)configCategoryFromIndexPath:(NSIndexPath *)indexPath open:(BOOL)shouldOpen animation:(BOOL)animation completion:(void (^)(BOOL finished))completion;

@end

//
//  MTTitleScrollView.h
//  MTExpandableCollectionView
//
//  Created by meitu on 16/3/10.
//  Copyright © 2016年 YJR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTIndicateScrollView : UIScrollView

@property (nonatomic) NSString *topicName;/**< 主题名称 */

/**
 *  更新主题视图信息
 *
 *  @param viewOffset 位置
 */
- (void)updateTopicViewPositionX:(CGFloat)viewOffset;

/**
 *  更新指示文字位置信息
 *
 *  @param labelPositionX
 */
- (void)updateIndicateLabelPositionIfNeed;

/**
 *  设置主题label的宽度
 *
 *  @param length 长度
 */
- (void)updateLabelLength:(CGFloat)length;

/**
 *  展示主题label
 */
- (void)showLabelView;

/**
 *  隐藏主题label
 */
- (void)hidenLabelView;



@end

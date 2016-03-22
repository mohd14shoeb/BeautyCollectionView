//
//  MTTopicScrollLabel.h
//  MTExpandableCollectionView
//
//  Created by meitu on 16/3/10.
//  Copyright © 2016年 YJR. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MTTopicLabel : UIView

@property (nonatomic, copy) NSString *topicName;/**< 主题名称 */

@property (nonatomic, strong) UILabel *indicateLabel;/**< 显示主题名称的label */

- (void)updateTopicLabelPosition:(CGFloat)length;/**< 更新显示主题名称的label的位置 */

@end

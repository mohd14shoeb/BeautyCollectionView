//
//  MTEffectHeaderView.h
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTCameraEffectCategory.h"

@interface MTEffectHeaderView : UICollectionReusableView

- (void)configurationWithCategory:(MTCameraEffectCategory *)category;

@end

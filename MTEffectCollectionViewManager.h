//
//  MTEffectCollectionViewManager.h
//  MTXX
//
//  Created by daemon on 16/3/21.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MTEffectCollectionViewManager : NSObject
@property (assign, nonatomic) NSNumber *openingSection;
@property (assign, nonatomic) CGFloat contentOffsetX;

+ (MTEffectCollectionViewManager *)sharedManager;

@end

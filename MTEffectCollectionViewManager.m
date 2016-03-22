//
//  MTEffectCollectionViewManager.m
//  MTXX
//
//  Created by daemon on 16/3/21.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "MTEffectCollectionViewManager.h"

@implementation MTEffectCollectionViewManager

+ (MTEffectCollectionViewManager *)sharedManager {
    static MTEffectCollectionViewManager *sharedManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManagerInstance = [[self alloc] init];
    });
    return sharedManagerInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

@end

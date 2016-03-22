//
//  MTEffectCollectionViewFlowLayout.m
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "MTEffectCollectionViewFlowLayout.h"

@interface MTEffectCollectionViewFlowLayout ()

@property (nonatomic, strong) NSMutableArray *deleteIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertIndexPaths;

@end

@implementation MTEffectCollectionViewFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    return [super layoutAttributesForElementsInRect:rect];
}

- (void)prepareForCollectionViewUpdates:(NSArray *)updateItems {
    [super prepareForCollectionViewUpdates:updateItems];
    
    self.deleteIndexPaths = [NSMutableArray array];
    self.insertIndexPaths = [NSMutableArray array];
    
    for (UICollectionViewUpdateItem *update in updateItems) {
        if (update.updateAction == UICollectionUpdateActionDelete) {
            [self.deleteIndexPaths addObject:update.indexPathBeforeUpdate];
        }
        else if (update.updateAction == UICollectionUpdateActionInsert) {
            [self.insertIndexPaths addObject:update.indexPathAfterUpdate];
        }
    }
}

- (void)finalizeCollectionViewUpdates {
    [super finalizeCollectionViewUpdates];
    self.deleteIndexPaths = nil;
    self.insertIndexPaths = nil;
}

- (UICollectionViewLayoutAttributes *)initialLayoutAttributesForAppearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super initialLayoutAttributesForAppearingItemAtIndexPath:itemIndexPath];
    
    // 判断是否是要插入的数组
    if ([self.insertIndexPaths containsObject:itemIndexPath]) {
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        // 获得每组的第一个Item的布局属性
        UICollectionViewLayoutAttributes *sectionAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:itemIndexPath];
        attributes.size = CGSizeMake(.0f, attributes.size.height);
        // 设定要插入的起始位置为headView位置
        attributes.center = CGPointMake(CGRectGetMaxX(sectionAttr.frame) + attributes.size.width ,CGRectGetMidY(self.collectionView.bounds));
//         若sectionAttr中点的位置 超出屏幕左边以外 将插入位置改变为self.collectionView.contentOffset.x + self.itemSize.width + 10
        if (sectionAttr.center.x < self.collectionView.contentOffset.x) {
            attributes.center = CGPointMake(self.collectionView.contentOffset.x + self.itemSize.width + self.sectionInset.left + 400 ,CGRectGetMidY(self.collectionView.bounds));
            
        }
    }
    return attributes;
}

- (UICollectionViewLayoutAttributes *)finalLayoutAttributesForDisappearingItemAtIndexPath:(NSIndexPath *)itemIndexPath {
    UICollectionViewLayoutAttributes *attributes = [super finalLayoutAttributesForDisappearingItemAtIndexPath:itemIndexPath];
    if ([self.deleteIndexPaths containsObject:itemIndexPath]) {
        if (!attributes) {
            attributes = [self layoutAttributesForItemAtIndexPath:itemIndexPath];
        }
        // 让item最终的消失位置为section 的headView位置
        UICollectionViewLayoutAttributes *sectionAttr = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:itemIndexPath];
//        attributes.size = CGSizeMake(0, attributes.size.height);
        attributes.center = CGPointMake(CGRectGetMidX(sectionAttr.frame) ,CGRectGetMidY(self.collectionView.bounds));
    }
    return attributes;
}

@end

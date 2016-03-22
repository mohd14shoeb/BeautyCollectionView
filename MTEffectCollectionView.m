//
//  MTEffectCollectionView.m
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "MTEffectCollectionView.h"

#import "MTNetwork.h"
#import "MTEffectHeaderView.h"
#import "MTCameraEffectManager.h"
#import "MTCameraSettingManager.h"
#import "MTEffectCollectionViewCell.h"
#import "MTEffectCollectionViewFlowLayout.h"

static CGFloat const itemSizeWidth              = 60.f;         /**< cell 宽度 */
static CGFloat const itemSizeHeight             = 85.f;         /**< cell 高度 */
static CGFloat const minimumInteritemSpacing    = 0.f;          /**< cell 间距 */
static CGFloat const minimumLineSpacing         = 4.f;          /**< cell 行距 */
static CGFloat const headerSizeWidth            = 85.f;         /**< header 宽度 */
static CGFloat const headerSizeHeight           = 85.f;         /**< header 高度 */

static NSString * const kReuseIdentifier        = @"cellReuseIdentifier";
static NSString * const kSectionIdentifier      = @"sectionReuseIdentifier";

@interface MTEffectCollectionView () <
    UICollectionViewDelegate,
    UICollectionViewDataSource,
    UIGestureRecognizerDelegate>

@property (strong, nonatomic) UITapGestureRecognizer *tapGesture;
@property (strong, nonatomic) NSMutableArray *expandedSections;
@property (strong, nonatomic) MTEffectCollectionViewFlowLayout *effectLayout;

@property (strong, nonatomic) NSIndexPath *nowIndexPath;
// 获得对应section的indexPaths数组
@property (strong, nonatomic) NSArray *indexPaths;
// 获得当前展开的section数组
@property (strong, nonatomic) NSArray *expandedSectionIndexPaths;
// 获得当前展开分类的section的长度(包括items)
@property (assign, nonatomic) CGFloat sectionWidth;
// 获得headerView的实际宽度
@property (assign, nonatomic) CGFloat headerViewSizeWidth;
// 获得当前的contentOffset
@property (assign, nonatomic) CGPoint nowContentOffset;
// 获得指示视图的位置
@property (assign, nonatomic) CGFloat indicateViewPosition;

@end

@implementation MTEffectCollectionView

- (NSArray *)indexPaths {
    // 获得对应section的indexPaths数组
    return [self indexPathsForSection:self.nowIndexPath.section];
}

- (CGFloat)sectionWidth {
    // 获得当前展开分类的section的长度(包括items)
   return (itemSizeWidth + minimumLineSpacing) * [self.indexPaths count] - minimumLineSpacing;
}

- (NSArray *)expandedSectionIndexPaths {
    // 获得当前展开的section数组
    NSMutableArray* sectionIndexPaths = [NSMutableArray array];
    for (NSInteger i = 0; i < self.numberOfSections; i++) {
        if ([self isExpandedSection:i]) {
            [sectionIndexPaths addObject:[NSIndexPath indexPathForItem:0 inSection:i]];
        }
    }
    return [sectionIndexPaths copy];
}

- (CGFloat)headerViewSizeWidth {
    // 获得headerView的实际宽度
    return headerSizeWidth + self.effectLayout.sectionInset.left + self.effectLayout.sectionInset.right;
}

- (CGPoint)nowContentOffset {
    // 获得当前的contentOffset
    return CGPointMake(self.headerViewSizeWidth  * self.nowIndexPath.section - self.contentInset.left, self.contentOffset.y);
}

- (CGFloat)indicateViewPosition {
    // 获得指示视图的位置
    return self.nowContentOffset.x + headerSizeWidth + self.contentInset.left + self.effectLayout.sectionInset.left;
}


- (NSMutableArray *)expandedSections {
    if (!_expandedSections) {
        _expandedSections = [NSMutableArray array];
        NSInteger maxI = [self.sectionDatasource count];
        for (NSInteger i = 0; i < maxI; i++) {
            [_expandedSections addObject:@NO];
        }
    }
    return _expandedSections;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"contentOffset"];
}

- (instancetype)init {
    if (self = [super init]) {
        [self initView];
    }
    
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initView];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initView];
    }
    
    return self;
}

- (void)initView {
    self.backgroundColor = [UIColor clearColor];
    self.contentInset = UIEdgeInsetsMake(.0, 65.f, .0, .0);
    self.contentOffset = CGPointMake(-65.f, .0f);
    self.decelerationRate = UIScrollViewDecelerationRateNormal;

    // 隐藏滚动条
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    
    // 设置布局
    _effectLayout = [[MTEffectCollectionViewFlowLayout alloc] init];
    _effectLayout.itemSize = CGSizeMake(itemSizeWidth, itemSizeHeight);
    _effectLayout.headerReferenceSize = CGSizeMake(headerSizeWidth, headerSizeHeight);
    _effectLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _effectLayout.minimumInteritemSpacing = minimumInteritemSpacing;
    _effectLayout.minimumLineSpacing = minimumLineSpacing;
    _effectLayout.sectionInset = UIEdgeInsetsMake(0, 4, 0, 4);
    [self setCollectionViewLayout:self.effectLayout];
    
    [self registerNib:[UINib nibWithNibName:@"MTEffectCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:kReuseIdentifier];
    [self registerClass:[MTEffectHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSectionIdentifier];
    
    self.dataSource = self;
    self.delegate = self;
    
    // 添加手势
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    _tapGesture.delegate = self;
    [self addGestureRecognizer:self.tapGesture];
    
    // 注册contentOffset变化通知
    [self registerNotificationOfContenOffset];
}

- (void)registerNotificationOfContenOffset {
    [self addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqual:@"contentOffset"] && (object == self)) {
        if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:updateContentOffset:)]) {
            [self.effectDelegate effectCollectionView:self updateContentOffset:self.contentOffset];
        }
    }
}

- (void)reloadData {
    _expandedSections = nil;
    [super reloadData];
}

- (void)showEffectCollectionViewAtIndexPath:(NSIndexPath *)indexPath needAnimation:(BOOL)isNeedAnimation {
    self.nowIndexPath = indexPath;
    self.userInteractionEnabled = NO;
    if ([self expandedSectionIndexPaths].count == 0) {
        if (isNeedAnimation) {
            // 先展开特效分类，过.4s再选中特效
            if (self.nowContentOffset.x >= 120) {
                CGFloat collectionViewlength = self.headerViewSizeWidth * self.sectionDatasource.count;
                self.nowContentOffset = CGPointMake(collectionViewlength - [UIScreen mainScreen].bounds.size.width, self.contentOffset.y);
            }
            CGFloat delayTime = self.contentOffsetX == self.nowContentOffset.x ? .0f : .4f;
            [self setContentOffset:self.nowContentOffset animated:YES];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self performBatchUpdates:^{
                    [self deleteItemsAtIndexPaths:[self collapseIndexPathsForSectionIndexPaths:self.expandedSectionIndexPaths]];
                    [self insertItemsAtIndexPaths:self.indexPaths];
                    [self updateExpandedSectionsForSectionIndexPaths:self.expandedSectionIndexPaths];
                    self.expandedSections[indexPath.section] = @(YES);
                } completion:^(BOOL finished) {
                    self.userInteractionEnabled = YES;
                }];
                
                [self selectItemAtIndexPath:indexPath
                                   animated:YES
                             scrollPosition:indexPath.item < 2 ? UICollectionViewScrollPositionNone : UICollectionViewScrollPositionCenteredHorizontally];
            });
        } else {
            // 直接展开分类并选中特效
            [self performBatchUpdates:^{
                [self deleteItemsAtIndexPaths:[self collapseIndexPathsForSectionIndexPaths:self.expandedSectionIndexPaths]];
                [self insertItemsAtIndexPaths:self.indexPaths];
                [self updateExpandedSectionsForSectionIndexPaths:self.expandedSectionIndexPaths];
                self.expandedSections[indexPath.section] = @(YES);
            } completion:^(BOOL finished) {
                self.userInteractionEnabled = YES;
            }];
            [self selectItemAtIndexPath:indexPath
                               animated:NO
                         scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        }
        
    } else {
        [self selectItemAtIndexPath:indexPath
                           animated:isNeedAnimation
                     scrollPosition:isNeedAnimation ? UICollectionViewScrollPositionCenteredHorizontally : UICollectionViewScrollPositionNone];
        self.userInteractionEnabled = YES;
    }
    
    if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:updateSectionLength:)]) {
        [self.effectDelegate effectCollectionView:self updateSectionLength:self.sectionWidth];
    }
    
    if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtPosition:)]) {
        [self.effectDelegate effectCollectionView:self didExpandItemAtPosition:CGPointMake(self.indicateViewPosition, 0)];
    }
    
    if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtIndexPath:)]) {
        [self.effectDelegate effectCollectionView:self didExpandItemAtIndexPath:indexPath];
    }
}

- (void)selectedItemAtIndexPath:(NSIndexPath *)indexPath completion:(void (^)(BOOL finished))completion {
    self.nowIndexPath = indexPath;
    // 如果当前屏幕上有展开的特效分类
    if ([self expandedSectionIndexPaths].count != 0) {
        if ([self isExpandedSection:indexPath.section]) {
            // 当前选中的特效属于展开的特效分类中
            if(is4_7InchScreen || is5_5InchScreen) {
                if (!(indexPath.section == 1 && indexPath.item < 2)) {
                    [self selectItemAtIndexPath:indexPath
                                       animated:YES
                                 scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                } else {
                    [self selectItemAtIndexPath:indexPath
                                       animated:YES
                                 scrollPosition:UICollectionViewScrollPositionNone];
                }
            } else {
                [self selectItemAtIndexPath:indexPath
                                   animated:YES
                             scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
            }
            if (completion) {
                completion(YES);
            }
        } else {
            // 当前选中的特效不属于展开的特效分类中
            NSInteger section = indexPath.section;

            [UIView animateWithDuration:.38 animations:^{
                [self performBatchUpdates:^{
                    [self deleteItemsAtIndexPaths:[self collapseIndexPathsForSectionIndexPaths:self.expandedSectionIndexPaths]];
                    [self updateExpandedSectionsForSectionIndexPaths:self.expandedSectionIndexPaths];
                } completion:^(BOOL finished) {
                    [self setContentOffset:self.nowContentOffset animated:YES];
                    [self performBatchUpdates:^{
                        [self insertItemsAtIndexPaths:self.indexPaths];
                        self.expandedSections[section] = @(YES);
                    } completion:^(BOOL finished) {
                        NSIndexPath *currentEffectIndexPath = [MTCameraEffectManager currentFilterIndexPath:self.sectionDatasource];
                        if (currentEffectIndexPath.section == section) {
                            [self selectItemAtIndexPath:indexPath
                                               animated:YES
                                         scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
                        } else {
                            [self selectItemAtIndexPath:indexPath
                                               animated:YES
                                         scrollPosition:UICollectionViewScrollPositionNone];
                        }
                        if (completion) {
                            completion(finished);
                        }
                    }];
                }];
                if (indexPath.section == 1) {
                    [self setContentOffset:CGPointMake(-65, self.contentOffset.y) animated:YES];
                }else if (indexPath.section == 0 && (indexPath.item == 0 || indexPath.item == 1)) {
                    [self setContentOffset:CGPointMake(20, self.contentOffset.y) animated:YES];
                }
            }];
            
            if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:updateSectionLength:)]) {
                [self.effectDelegate effectCollectionView:self updateSectionLength:self.sectionWidth];
            }
            
            if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtPosition:)]) {
                [self.effectDelegate effectCollectionView:self didExpandItemAtPosition:CGPointMake(self.indicateViewPosition, 0)];
            }
            
            if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtIndexPath:)]) {
                [self.effectDelegate effectCollectionView:self didExpandItemAtIndexPath:indexPath];
            }
        }
    } else {
        [self showEffectCollectionViewAtIndexPath:indexPath needAnimation:YES];
        if (completion) {
            completion(YES);
        }
    }
}

- (void)configCategoryFromIndexPath:(NSIndexPath *)indexPath open:(BOOL)shouldOpen animation:(BOOL)animation completion:(void (^)(BOOL finished))completion {
    self.nowIndexPath = indexPath;
    CGFloat duration = animation ? .38f : .0f;
    NSInteger section = indexPath.section;
    [UIView animateWithDuration:duration animations:^{
        [self performBatchUpdates:^{
            [self deleteItemsAtIndexPaths:[self collapseIndexPathsForSectionIndexPaths:self.expandedSectionIndexPaths]];
            [self updateExpandedSectionsForSectionIndexPaths:self.expandedSectionIndexPaths];
        } completion:^(BOOL finished) {
            if (shouldOpen) {
                [self performBatchUpdates:^{
                    [self insertItemsAtIndexPaths:self.indexPaths];
                    self.expandedSections[section] = @(YES);
                } completion:^(BOOL finished) {
                    
                }];
            }
            if (completion) {
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:updateSectionLength:)]) {
                    [self.effectDelegate effectCollectionView:self updateSectionLength:self.sectionWidth];
                }
                
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtPosition:)]) {
                    [self.effectDelegate effectCollectionView:self didExpandItemAtPosition:CGPointMake(self.indicateViewPosition, 0)];
                }
                
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtIndexPath:)]) {
                    [self.effectDelegate effectCollectionView:self didExpandItemAtIndexPath:indexPath];
                }
                completion(finished);
            }
        }];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.tapGesture) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            CGPoint point = [touch locationInView:self];
            NSIndexPath* tappedCellPath = [self indexPathAtPoint:point];
            return tappedCellPath && (tappedCellPath.item == 0);
        }
    }
    return YES;
}

#pragma mark - UICollectionView DataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [self.sectionDatasource count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    MTCameraEffectCategory *effectCategory = self.sectionDatasource[section];
    NSInteger effectCount = [effectCategory.categoryList count];
    NSInteger count = [self isExpandedSection:section] ? effectCount : MIN(0, effectCount);
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MTEffectCollectionViewCell *cell = [self dequeueReusableCellWithReuseIdentifier:kReuseIdentifier forIndexPath:indexPath];
    MTCameraEffectCategory *effectCategory = self.sectionDatasource[indexPath.section];
    MTCameraEffect *effect = effectCategory.categoryList[indexPath.item];
    [cell configurationWithEffects:effect beforeCapture:self.beforeCapture];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath {
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        MTEffectHeaderView *headerView = [self dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                                                                  withReuseIdentifier:kSectionIdentifier
                                                                         forIndexPath:indexPath];
        
        MTCameraEffectCategory *effectCategory = self.sectionDatasource[indexPath.section];
        [headerView configurationWithCategory:effectCategory];
        return headerView;
    }
    return nil;
}

#pragma mark - UICollectionView Delegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didSelectCategory:effect:)]) {
        MTCameraEffectCategory *effectCategory = self.sectionDatasource[indexPath.section];
        MTCameraEffect *effect = effectCategory.categoryList[indexPath.item];
        [self.effectDelegate effectCollectionView:self
                                didSelectCategory:effectCategory
                                           effect:effect];
    }
    
    MTEffectCollectionViewCell *cell = (MTEffectCollectionViewCell *)[self cellForItemAtIndexPath:indexPath];
    [cell showJumpAnimation];
    CGRect cellFrame = cell.frame;
    CGFloat minDifference = minimumLineSpacing * 2 + itemSizeWidth + self.contentInsetLeft;
    // 判断是否为第一个item
    if (indexPath.item == 0) {
        minDifference = minimumLineSpacing * 2 + headerSizeWidth + self.contentInsetLeft;
    }
    CGFloat difference = ABS(CGRectGetMinX(cellFrame) - self.contentOffset.x);
    
    // 判断是否需要向右推进
    BOOL moveRightIfNeed = difference < minDifference;
    CGFloat moveRightLength = minDifference - difference;
    if (moveRightIfNeed) {
        [UIView animateWithDuration:.3f animations:^{
            self.contentOffset = CGPointMake(self.contentOffset.x - moveRightLength, self.contentOffset.y);
        }];
    }
    
    // 判断是否需要向左推进
    BOOL moveLeftIfNeed =  difference + 2 * (minimumLineSpacing + itemSizeWidth) > self.frame.size.width;
    CGFloat moveLeftLength = difference + 2 * (minimumLineSpacing + itemSizeWidth) - self.frame.size.width;
    
    // 判断是否为最后一个item
    NSInteger sectionCount = [[self indexPathsForSection:indexPath.section] count];
    BOOL isLastItem = (sectionCount == indexPath.item + 1);
    if (isLastItem) {
        moveLeftLength = difference + 2 * minimumLineSpacing + itemSizeWidth + headerSizeWidth - self.frame.size.width;
    }
    // 如果是最后一组最后一个item则不进行推进
    BOOL isLastSection = ([self.sectionDatasource count] == (indexPath.section + 1));
    if (isLastItem && isLastSection) {
        moveLeftLength = 0;
    }
    if (moveLeftIfNeed) {
        [UIView animateWithDuration:.3f animations:^{
            self.contentOffset = CGPointMake(self.contentOffset.x + moveLeftLength, self.contentOffset.y);
        }];
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    MTEffectCollectionViewCell *cell = (MTEffectCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    MTCameraEffectCategory *effectCategory = self.sectionDatasource[indexPath.section];
    MTCameraEffect *effect = effectCategory.categoryList[indexPath.item];
    
    BOOL downloaded = [[MTCamEffectDownloadManager sharedManager] isFileCompletion:effect];
    if (effect.online && !downloaded) {
        if ([MTNetwork checkNetworkAvailability:YES]) {
            [cell downloadMaterial];
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.05 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSIndexPath *indexPath = [MTCameraEffectManager currentFilterIndexPath:self.sectionDatasource];
            [self selectedItemAtIndexPath:indexPath completion:nil];
            if ([self expandedSectionIndexPaths].count != 0) {
                if ([self isExpandedSection:indexPath.section]) {
                    if(is4_7InchScreen || is5_5InchScreen) {
                        if (!(indexPath.section == 1 && indexPath.item < 2)) {
                            [self selectItemAtIndexPath:indexPath
                                               animated:NO
                                         scrollPosition:UICollectionViewScrollPositionNone];
                        } else {
                            [self selectItemAtIndexPath:indexPath
                                               animated:NO
                                         scrollPosition:UICollectionViewScrollPositionNone];
                        }
                    } else {
                        [self selectItemAtIndexPath:indexPath
                                           animated:NO
                                     scrollPosition:UICollectionViewScrollPositionNone];
                    }
                }
            }
        });
        
        return NO;
    }
    
    return YES;
}

#pragma mark - Selector
- (void)handleTapGesture:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        self.userInteractionEnabled = NO;
        CGPoint point = [gesture locationInView:self];
        NSIndexPath *tappedSectionPath = [self indexPathAtPoint:point];
        if (tappedSectionPath && tappedSectionPath.item == 0) {
            NSInteger tappedSection = tappedSectionPath.section;
            BOOL willOpen = ![self.expandedSections[tappedSection] boolValue];
            NSArray *indexPaths = [self indexPathsForSection:tappedSection];
            NSArray *expandedSectionIndexPaths = willOpen ? [self expandedSectionIndexPaths] : @[];
            [self performBatchUpdates:^{
                if (willOpen) {
                    [self insertItemsAtIndexPaths:indexPaths];
                    [self deleteItemsAtIndexPaths:[self collapseIndexPathsForSectionIndexPaths:expandedSectionIndexPaths]];
                } else {
                    [self deleteItemsAtIndexPaths:indexPaths];
                }
                [self updateExpandedSectionsForSectionIndexPaths:expandedSectionIndexPaths];
                self.expandedSections[tappedSection] = @(willOpen);
            } completion:^(BOOL finished) {
            }];
            
            if (willOpen) {
                // 设置展开的位置
                CGFloat contentOffsetX = (headerSizeWidth + self.effectLayout.sectionInset.left + self.effectLayout.sectionInset.right)  * tappedSection - self.contentInset.left;
                NSIndexPath *indexPath = [MTCameraEffectManager currentFilterIndexPath:self.sectionDatasource];
                [self setContentOffset:CGPointMake(contentOffsetX, self.contentOffset.y) animated:YES];
                if (tappedSection == indexPath.section) {
                    [self selectItemAtIndexPath:indexPath
                                       animated:YES
                                 scrollPosition:UICollectionViewScrollPositionNone];
                    self.userInteractionEnabled = YES;
                } else {
                    self.userInteractionEnabled = YES;
                }
                CGFloat sectionWidth = (itemSizeWidth + minimumLineSpacing) * [indexPaths count] - minimumLineSpacing;
                
                CGFloat indicateViewPosition = contentOffsetX + headerSizeWidth +self.contentInset.left + self.effectLayout.sectionInset.left;
                
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:updateSectionLength:)]) {
                    [self.effectDelegate effectCollectionView:self updateSectionLength:sectionWidth];
                }
                
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtPosition:)]) {
                    [self.effectDelegate effectCollectionView:self didExpandItemAtPosition:CGPointMake(indicateViewPosition, 0)];
                }
                
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didExpandItemAtIndexPath:)]) {
                    [self.effectDelegate effectCollectionView:self didExpandItemAtIndexPath:tappedSectionPath];
                }
            } else {
                self.userInteractionEnabled = YES;
                // 设置收缩的位置
                if ([self.effectDelegate respondsToSelector:@selector(effectCollectionView:didCollapseItemAtIndexPath:)]) {
                    [self.effectDelegate effectCollectionView:self didCollapseItemAtIndexPath:tappedSectionPath];
                }
                
            }
        }
    }
}

#pragma mark - Private
- (NSArray*)indexPathsForSection:(NSInteger)section {
    NSMutableArray* indexPaths = [NSMutableArray array];
    MTCameraEffectCategory *effectCategorys = self.sectionDatasource[section];
    for (NSInteger i = 0, maxI = [effectCategorys.categoryList count]; i < maxI; i++) {
        [indexPaths addObject:[NSIndexPath indexPathForItem:i inSection:section]];
    }
    return [indexPaths copy];
}

- (NSArray*)collapseIndexPathsForSectionIndexPaths:(NSArray*)sectionIndexPaths {
    NSArray* indexPaths = @[];
    for (NSIndexPath* sectionIndexPath in sectionIndexPaths) {
        indexPaths = [indexPaths arrayByAddingObjectsFromArray:[self indexPathsForSection:sectionIndexPath.section]];
    }
    return indexPaths;
}

- (void)updateExpandedSectionsForSectionIndexPaths:(NSArray*)sectionIndexPaths {
    for (NSIndexPath* sectionIndexPath in sectionIndexPaths) {
        self.expandedSections[sectionIndexPath.section] = @(NO);
    }
}

- (BOOL)isExpandedSection:(NSInteger)section {
    return [self.expandedSections[section] boolValue];
}

- (NSIndexPath *)indexPathAtPoint:(CGPoint)point {
    for (int i = 0; i < self.sectionDatasource.count; i++) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:i];
        UICollectionViewLayoutAttributes *attrs = [self layoutAttributesForSupplementaryElementOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
        if (CGRectContainsPoint(attrs.frame, point)) {
            return indexPath;
        }
    }
    return nil;
}

@end

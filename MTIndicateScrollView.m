//
//  MTTitleScrollView.m
//  MTExpandableCollectionView
//
//  Created by meitu on 16/3/10.
//  Copyright © 2016年 YJR. All rights reserved.
//

#import "MTIndicateScrollView.h"
#import "MTTopicLabel.h"

//static const CGFloat kDefaultEdgeInsetRight = 130;
static const CGFloat kDefaultOutSideDistance = 60;
static const CGFloat kDefaultContentInsetLeft = 65;

@interface MTIndicateScrollView () {
    CGFloat _labelWidth;
    CGFloat _EdgeInsetRight;
}

@property (nonatomic, strong) MTTopicLabel *topicLabel;

@end

@implementation MTIndicateScrollView

- (MTTopicLabel *)topicLabel {
    if (!_topicLabel) {
        _topicLabel = [MTTopicLabel new];
        _topicLabel.alpha = 0;
        [self addSubview:_topicLabel];
    }
    return _topicLabel;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    _labelWidth = 1000;
    _EdgeInsetRight = is4_7InchScreen ? 130 : 100;
    if (is5_5InchScreen) {
        _EdgeInsetRight = 150.f;
    }
    self.contentSize = CGSizeMake(1000, self.frame.size.height);
    self.topicLabel.frame = CGRectMake(0, 0, _labelWidth, self.frame.size.height);
    self.topicLabel.hidden = YES;
    self.userInteractionEnabled = NO;
    self.scrollEnabled = NO;
}

- (void)setTopicName:(NSString *)topicName {
    self.topicLabel.topicName = topicName;
}

-(void)updateTopicViewPositionX:(CGFloat)viewOffset {
    
    [UIView animateWithDuration:.3f animations:^{
        self.topicLabel.frame = CGRectMake(viewOffset - kDefaultContentInsetLeft, 0,_labelWidth, self.frame.size.height);
    }];
}

- (void)updateIndicateLabelPositionIfNeed {
    CGFloat moveLength = self.topicLabel.frame.origin.x - self.contentOffset.x;
    if (moveLength > 0) {
        [self.topicLabel updateTopicLabelPosition:0];
    } else {
        BOOL isMiddleOffset = (ABS(moveLength) + 2 * _EdgeInsetRight + self.topicLabel.indicateLabel.frame.size.width) < self.topicLabel.frame.size.width;
        if (isMiddleOffset) {
            [self.topicLabel updateTopicLabelPosition:ABS(moveLength)];
        } else {
            BOOL isCloseOutSide = (ABS(moveLength) + _EdgeInsetRight + self.topicLabel.indicateLabel.frame.size.width > self.topicLabel.frame.size.width);
            BOOL isNearlyOutSide = ABS(moveLength) > self.topicLabel.frame.size.width - kDefaultOutSideDistance;
            if (isCloseOutSide && !isNearlyOutSide) {
            [self.topicLabel updateTopicLabelPosition:ABS(moveLength) - _EdgeInsetRight];
            }
        }
    }
}

- (void)updateLabelLength:(CGFloat)length {
    _labelWidth = length;
}

- (void)showLabelView {
    
    self.topicLabel.hidden = NO;
    [UIView animateWithDuration:0.8f animations:^{
        self.topicLabel.alpha = 1;
    }];
}


- (void)hidenLabelView {
    
    [UIView animateWithDuration:.2f animations:^{
        self.topicName = @"";
        self.topicLabel.alpha = 0;
    } completion:^(BOOL finished) {
        self.topicLabel.hidden = YES;
    }];
}
@end

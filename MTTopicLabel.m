//
//  MTTopicScrollLabel.m
//  MTExpandableCollectionView
//
//  Created by meitu on 16/3/10.
//  Copyright © 2016年 YJR. All rights reserved.
//

#import "MTTopicLabel.h"

//static const CGFloat kDefaultTopicLabelPositionX = 130;
static const CGFloat kDefaultTopicLabelWidth = 60;
static const CGFloat kDefaultTopicLabelHeight = 20;
static const CGFloat kDefaultTopicLabelLineCenterY = 13.;
static const NSInteger kDefaultLabelTextFont = 10;


@interface MTTopicLabel () {

    CGFloat _oldTopicLabelPositionX;
    CGFloat _topicLabelPositionX;
}

@end

@implementation MTTopicLabel

- (UILabel *)indicateLabel {
    if (!_indicateLabel) {
        _indicateLabel = [[UILabel alloc] initWithFrame:CGRectMake(_topicLabelPositionX, 0, kDefaultTopicLabelWidth, kDefaultTopicLabelHeight)];
        self.indicateLabel.backgroundColor = [UIColor whiteColor];
        self.indicateLabel.textAlignment = NSTextAlignmentCenter;
        self.indicateLabel.textColor = RGBAHEX(0x919ba6, 1.f);
        self.indicateLabel.font = [UIFont systemFontOfSize:kDefaultLabelTextFont];
        [self addSubview:self.indicateLabel];
    }
    return _indicateLabel;
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
    self.backgroundColor = [UIColor whiteColor];
    _topicLabelPositionX = is4_7InchScreen ? 130.f : 100.f;
    if (is5_5InchScreen) {
        _topicLabelPositionX = 150.f;
    }
    
}

- (void)drawRect:(CGRect)rect {
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:CGRectMake(.0f,
                                                                         kDefaultTopicLabelLineCenterY,
                                                                         CGRectGetWidth(self.frame),
                                                                         1.f)];
    
    [RGBAHEX(0xe9ecef, 1.f) setFill];
    [linePath fill];
}

- (void)updateTopicLabelPosition:(CGFloat)length {
    self.indicateLabel.frame = CGRectMake(_topicLabelPositionX + length, (CGRectGetHeight(self.frame) - kDefaultTopicLabelHeight) * 0.5 , kDefaultTopicLabelWidth, kDefaultTopicLabelHeight);
}

-(void)setTopicName:(NSString *)topicName {
    _topicName = topicName;
    self.indicateLabel.text = _topicName;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
}
@end

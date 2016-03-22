//
//  MTEffectHeaderView.m
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "MTEffectHeaderView.h"
#import <Masonry/Masonry.h>
#import "YYLabel.h"

@interface MTEffectHeaderView ()

@property (strong, nonatomic) YYLabel *titleLabel;
@property (strong, nonatomic) UIImageView *imageView;

@end

@implementation MTEffectHeaderView

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

- (void)awakeFromNib {
    
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    self.backgroundColor = RGBAHEX(0x578fff, 1.f);
    
    self.imageView = [[UIImageView alloc] init];
    [self addSubview:self.imageView];
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    
    self.titleLabel = [[YYLabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont systemFontOfSize:15.f];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.shadowColor = RGBAHEX(0x000000, .2f);
    self.titleLabel.shadowOffset = CGSizeMake(.0, 5.f);
    self.titleLabel.shadowBlurRadius = 18.f;
    [self addSubview:self.titleLabel];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(6.f);
        make.right.mas_equalTo(self).offset(-6.f);
        make.bottom.mas_equalTo(self).offset(-6.f);
        make.height.mas_equalTo(17.f);
    }];
}

- (void)configurationWithCategory:(MTCameraEffectCategory *)category {
    self.titleLabel.text = category.categoryName;
    self.imageView.image = [UIImage imageNamed:category.thumbnail];
}

@end

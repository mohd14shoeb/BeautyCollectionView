//
//  MTEffectCollectionViewCell.h
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MTCameraEffect.h"
#import "MTCamEffectDownloadManager.h"

@interface MTEffectCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *effectTitleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@property (strong, nonatomic) MTCameraEffect *effect;

- (void)configurationWithEffects:(MTCameraEffect *)effect
                   beforeCapture:(BOOL)beforeCapture;
- (void)showJumpAnimation;
- (void)downloadMaterial;

@end

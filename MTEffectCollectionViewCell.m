//
//  MTEffectCollectionViewCell.m
//  MTXX
//
//  Created by daemon on 16/2/24.
//  Copyright © 2016年 Meitu. All rights reserved.
//

#import "MTEffectCollectionViewCell.h"
#import "MTCameraEffectCategory.h"
#import "MTProgressOverlayView.h"
#import <UIImageView+WebCache.h>
#import "Masonry.h"

@interface MTEffectCollectionViewCell ()

@property (weak, nonatomic) IBOutlet UIView *coverView;
@property (weak, nonatomic) IBOutlet UIImageView *flagView;

@property (strong, nonatomic) MTProgressOverlayView *progressView;

@property (copy, nonatomic) MTDownloadProgressHandle progressHandle;    /**< 下载进度回调 */

@end

@implementation MTEffectCollectionViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
    [self commonInit];
}

- (void)commonInit {
    self.progressView = [[MTProgressOverlayView alloc] initWithFrame:self.iconImageView.bounds];
    self.progressView.waitingDownloadContainerViewColor = [UIColor clearColor];
    [self.progressView displayOperationDidFailed];
    self.progressView.hidden = YES;
    [self.iconImageView addSubview:_progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.iconImageView);
    }];
    
    // 添加素材下载状态监听
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(materialDownloadDidStartNotification:)
                                                 name:MTCamEffectDownloadDidStartNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadSuccessWithNotification:)
                                                 name:MTCamEffectDownloadSuccessNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(downloadFailedWithNotification:)
                                                 name:MTCamEffectDownloadFailureNotification
                                               object:nil];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    
    self.progressView.hidden = YES;
    self.progressView.progress = .0f;
    [self.progressView displayOperationDidFailed];
    self.progressView.waitingDownloadContainerViewColor = [UIColor clearColor];
    
    [self.iconImageView sd_cancelCurrentImageLoad];
    self.progressHandle = nil;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    self.coverView.hidden = !selected;
}

- (void)configurationWithEffects:(MTCameraEffect *)effect beforeCapture:(BOOL)beforeCapture {
    self.effect = effect;
    
    self.effectTitleLabel.text = effect.title;
    self.effectTitleLabel.backgroundColor = effect.color;
    
    if (beforeCapture) {
        self.flagView.image = [UIImage imageNamed:@"icon_camera_white"];
    } else {
        self.flagView.image = [UIImage imageNamed:@"icon_slider_flag"];
        self.flagView.hidden = effect.effectID == 0 ? YES : NO;
    }
    
    // 在线素材
    if (effect.isOnline) {
        [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:effect.thumbnail]
                              placeholderImage:[UIImage imageNamed:effect.category.thumbnail]];
        
        BOOL downloading = [[MTCamEffectDownloadManager sharedManager] isDownloadingForMaterial:effect
                                                                                 progressHandle:self.progressHandle];
        self.progressView.hidden = [[MTCamEffectDownloadManager sharedManager] isFileCompletion:effect];
        
        if (downloading) {
            self.progressView.progress = effect.downloadProgress;
            
            [self.progressView displayOperationWillTriggerAnimation];
        } else {
            // 素材未下载
            [self.progressView displayOperationDidFailed];
        }
    } else {
        self.iconImageView.image = [UIImage imageNamed:effect.category.thumbnail];
        self.progressView.hidden = YES;
    }
}

- (void)showJumpAnimation {
    [UIView animateWithDuration:.13f animations:^{
        self.center = CGPointMake(self.center.x, self.center.y - 7);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:.13f animations:^{
            self.center = CGPointMake(self.center.x, self.center.y + 7);
        } completion:^(BOOL finished) {
            
        }];
    }];
}

- (void)downloadMaterial {
    self.progressView.hidden = NO;
    [self.progressView displayOperationWillTriggerAnimation];
    
    [[MTCamEffectDownloadManager sharedManager] downloadFileForMaterial:self.effect];
}

#pragma mark - Private

- (MTDownloadProgressHandle)progressHandle
{
    __weak __typeof__(self) weakSelf = self;
    if (_progressHandle == nil) {
        _progressHandle = ^void(CGFloat progress){
            __strong __typeof__(self) strongSelf = weakSelf;
            strongSelf.progressView.progress = progress;
            strongSelf.effect.downloadProgress = progress;
        };
    }
    return _progressHandle;
}

#pragma mark - Notification

// 素材下载成功
- (void)downloadSuccessWithNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = notification.object;
        if ([url.absoluteString isEqualToString:[self.effect.URL absoluteString]]) {
            self.progressView.hidden = YES;
        }
    });
}

// 素材下载失败
- (void)downloadFailedWithNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSURL *url = notification.object;
        if ([url.absoluteString isEqualToString:[self.effect.URL absoluteString]]) {
            self.progressView.hidden = NO;
            [self.progressView displayOperationDidFailed];
        }
    });
}

- (void)materialDownloadDidStartNotification:(NSNotification *)notification
{
    NSURL *URL = notification.object;
    if ([URL.absoluteString isEqualToString:self.effect.URL.absoluteString]) {
        self.progressView.progress = self.effect.downloadProgress;
        [self.progressView displayOperationWillTriggerAnimation];
    }
    
    [[MTCamEffectDownloadManager sharedManager] isDownloadingForMaterial:self.effect
                                                          progressHandle:self.progressHandle];
}

@end

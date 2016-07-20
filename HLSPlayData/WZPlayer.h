//
//  WZPlayer.h
//  WZPlayer
//
//  Created by qianjianeng on 16/1/31.
//  Copyright © 2016年 SF. All rights reserved.
//


#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

FOUNDATION_EXPORT NSString *const kWZPlayerStateChangedNotification;
FOUNDATION_EXPORT NSString *const kWZPlayerProgressChangedNotification;
FOUNDATION_EXPORT NSString *const kWZPlayerLoadProgressChangedNotification;

//播放器的几种状态
typedef NS_ENUM(NSInteger, WZPlayerState) {
    WZPlayerStateBuffering = 1,
    WZPlayerStatePlaying   = 2,
    WZPlayerStateStopped   = 3,
    WZPlayerStatePause     = 4
};

@interface WZPlayer : NSObject

@property (nonatomic, readonly) WZPlayerState state;
@property (nonatomic, readonly) CGFloat       loadedProgress;   //缓冲进度
@property (nonatomic, readonly) CGFloat       duration;         //视频总时间
@property (nonatomic, readonly) CGFloat       current;          //当前播放时间
@property (nonatomic, readonly) CGFloat       progress;         //播放进度 0~1
@property (nonatomic          ) BOOL          stopWhenAppDidEnterBackground;// default is YES


+ (instancetype)sharedInstance;
- (void)playWithUrl:(NSURL *)url showView:(UIView *)showView;
- (void)seekToTime:(CGFloat)seconds;

- (void)resume;
- (void)pause;
- (void)stop;

- (void)fullScreen;  //全屏
- (void)halfScreen;   //半屏
@end

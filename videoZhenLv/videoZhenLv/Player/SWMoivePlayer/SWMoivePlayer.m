//
//  SWMoivePlayer.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/13.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import "SWMoivePlayer.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SWMoivePlayer ()

@property (nonatomic, strong) MPMoviePlayerController *movPlayer;

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;

@end

@implementation SWMoivePlayer

-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr {
    if (self = [super init]) {
        self.frame = frame;
        
//        [self setUpMPMoivePlayer:urlStr];
        
        self.player = [AVPlayer playerWithURL:urlStr];
        self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
        [self.layer addSublayer:self.playerLayer];
        self.playerLayer.frame = self.bounds;
        self.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
        self.player.accessibilityNavigationStyle = UIAccessibilityNavigationStyleSeparate;
    }
    return self;
}


-(void)setUpMPMoivePlayer:(NSURL *)urlStr {
    MPMoviePlayerController *movPlayer = [[MPMoviePlayerController alloc]initWithContentURL:urlStr];
    
    [self addSubview:movPlayer.view];
    movPlayer.view.frame = self.bounds;
    self.movPlayer = movPlayer;
    // 相关配置
    /**
     MPMovieControlStyleNone,      没有控制栏
     MPMovieControlStyleEmbedded,   嵌入的控制栏, 默认的
     MPMovieControlStyleFullscreen,    全屏的控制栏
     */
    movPlayer.controlStyle = MPMovieControlStyleEmbedded;
    
    // 视频的填充模式
    /**
     MPMovieScalingModeNone,       // 什么都不做
     MPMovieScalingModeAspectFit,  // 保持比例拉伸, 留黑边
     MPMovieScalingModeAspectFill, // 保持比例拉伸, 会有一部分看不到
     MPMovieScalingModeFill                 // 不保持比例直接拉伸全屏
     */
    movPlayer.scalingMode = MPMovieScalingModeNone;
    movPlayer.currentPlaybackRate = 1.0;
    //总时长
    NSTimeInterval totalTime = movPlayer.duration;
    //总帧数
    NSTimeInterval totalFrames = totalTime * 30;
    NSLog(@"totalTime = %f  totalFrames = %f ",totalTime,totalFrames);

}

-(void)play {
    
//    [self.movPlayer play];
    [self.player play];
}

@end

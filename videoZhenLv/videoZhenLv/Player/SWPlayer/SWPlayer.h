//
//  SWPlayer.h
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/8.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>

@class NYSliderPopover;
@class SWPlayer;
@class TTRangeSlider;

@protocol SWPlayerDelegate <NSObject>


@end


@interface SWPlayer : UIView



@property (nonatomic, strong) AVPlayer *player;


@property (nonatomic, strong) AVPlayerLayer *playerLayer;

/**
 *  播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *playBtn;

/**
 *  原生滑条
 */
@property (weak, nonatomic) IBOutlet  NYSliderPopover*timeSlider;
/**
 *  放自定义滑条的VIew
 */
@property (weak, nonatomic) IBOutlet UIView *rangeView;

/**
 *  双头自定义滑条
 */
@property (weak, nonatomic) IBOutlet TTRangeSlider *rangeSlider;
/**
 *  标记label
 */
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;
/**
 *  标记按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *clockBtn;

/**
 *  sliderMaxValue
 */
@property (nonatomic, assign) CGFloat sliderMaxValue;

/**
 *  播放完成回调block
 */
@property (nonatomic, copy) void (^playerDidPlayFinish)();

/**
 *  初始化
 *
 *  @param frame
 *  @param urlStr
 *
 *  @return
 */
-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr;

/**
 *  播放
 */
-(void)play;
/**
 *  暂停
 */
-(void)pause;

/**
 *  步进帧数
 */
-(void)stepByCount:(CGFloat)count;


/**
 *
 */
@property (nonatomic, weak) id<SWPlayerDelegate> playerDelegate;

@end

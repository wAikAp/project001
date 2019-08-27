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

-(void)player:(SWPlayer *)player NotifCurrTimes:(CGFloat)times;

@end

@class TXHRrettyRuler;
@interface SWPlayer : UIView

/**
 *  tap时回调
 */
@property (nonatomic, copy) void (^tapPlayerBlock)();

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
 *  player
 */
@property (nonatomic, strong) AVPlayer *player;

/**
 *  playerLayer
 */
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
 *  尺子view
 */
@property (nonatomic, strong) TXHRrettyRuler *rulerView;
/**
 *  双头自定义滑条
 */
@property (weak, nonatomic) IBOutlet TTRangeSlider *rangeSlider;
/**
 *  标记label
 */
@property (weak, nonatomic) IBOutlet UILabel *clockLabel;

/**
 *  标记按钮的view
 */
@property (weak, nonatomic) IBOutlet UIView *clockView;

/**
 *  sliderMaxValue
 */
@property (nonatomic, assign) CGFloat sliderMaxValue;

/**
 *  播放完成回调block
 */
@property (nonatomic, copy) void (^playerDidPlayFinish)();
/**
 *  等价于tag 记录是第几个player
 */
@property (nonatomic, assign) CGFloat playerNumber;
/**
 *  是否在最前
 */
@property (nonatomic, assign) BOOL playerIsFont;
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
 *  代理
 */
@property (nonatomic, weak) id<SWPlayerDelegate> playerDelegate;


@end

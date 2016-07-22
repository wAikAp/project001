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

-(void)silderValueChange:(SWPlayer *)player value:(CGFloat)value;


@end


@interface SWPlayer : UIView

@property (nonatomic, strong) AVPlayer *player;

@property (nonatomic, strong) AVPlayerLayer *playerLayer;


@property (weak, nonatomic) IBOutlet UIButton *playBtn;

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

@property (nonatomic, assign) CGFloat sliderMaxValue;



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
 *
 */
@property (nonatomic, weak) id<SWPlayerDelegate> playerDelegate;

@end

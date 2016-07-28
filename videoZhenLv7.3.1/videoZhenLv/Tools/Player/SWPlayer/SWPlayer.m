//
//  SWPlayer.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/8.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import "SWPlayer.h"

#import "UIView+SWUtility.h"
#import "NYSliderPopover.h"

//#import "TTRangeSlider.h"


@interface SWPlayer() //<TTRangeSliderDelegate>



/**
 *  正在播放
 */
@property (nonatomic, assign) BOOL isPlaying;
/**
 *  播完
 */
@property (nonatomic, assign) BOOL playFinish;
/**
 *  timer
 */
@property (nonatomic, strong) NSTimer *timer;
/**
 *  记录原生滑条上一次value
 */
@property (nonatomic, assign) CGFloat sliderValue;
/**
 *  记录自定义滑条的上一次Value
 */
@property (nonatomic, assign) CGFloat currentRangeValue;
/**
 *  rangeValue最大
 */
@property (nonatomic, assign) CGFloat currentMAXRangeValue;

/**
 *  标记按钮1
 */
@property (weak, nonatomic) IBOutlet UIButton *clockBtn2;
/**
 *  标记按钮2
 */
@property (weak, nonatomic) IBOutlet UIButton *clockBtn1;
@property (weak, nonatomic) IBOutlet UIButton *clockBtn3;
@property (weak, nonatomic) IBOutlet UIButton *clockBtn4;

/**
 *  是否标记
 */
@property (nonatomic, assign) BOOL isBiaoJi;

/**
 *  标记的时间
 */
@property (nonatomic, assign) CGFloat biaoJiTime;


@end

@implementation SWPlayer

#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr
{
    if (self = [super init]) {
        self = [[[UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil] instantiateWithOwner:nil options:nil]lastObject];
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        
        //设置player
        [self setUPplayerWithUrl:urlStr];
        
        //range Slider
        [self setUpRangeSlider];
        //UI细节
        [self setUpUI];
        

    }
    return self;
}

#pragma mark - stUpPLayer
-(void)setUPplayerWithUrl:(NSURL *)url
{
    //player
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    AVPlayer *player = [AVPlayer playerWithPlayerItem:item];
    self.player = player;
    
    //layer
    AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    [self.layer addSublayer:playerLayer];
    playerLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
    self.playerLayer = playerLayer;
    // 配置
    /**
     AVLayerVideoGravityResizeAspect        //  保持比例, 留黑边
     AVLayerVideoGravityResizeAspectFill    //  保持比例, 可能会有一不部分看不到
     AVLayerVideoGravityResize              // 填充全屏
     */
    playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
    //拿到影片长度
    double assDura  = CMTimeGetSeconds(self.player.currentItem.asset.duration);
    
    //TimeSlider
    self.timeSlider.minimumValue = 0.00;
    self.timeSlider.maximumValue = assDura;
    //        [self.timeSlider setMinimumTrackImage:[UIImage imageNamed:@"slider"] forState:UIControlStateNormal];
    CMTime zongT = self.player.currentItem.asset.duration;
    NSLog(@"视频总秒数 = %f —— value数 = %lld —— 每秒帧数 = %d —— 视频的总长度数 = %lld",assDura,zongT.value,zongT.timescale, zongT.value * zongT.timescale);
}


#pragma mark - setUpUI
-(void)setUpUI
{
    //playBtn
    int corenrRaidus = 10;
    [self setTheViewCornerRadius:self.playBtn cornerRadius:self.playBtn.frame.size.width / 2];
    [self setTheViewCornerRadius:self.clockBtn1 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn2 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn3 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn4 cornerRadius:corenrRaidus];
    //clockBtn
    [self.clockBtn1.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.clockBtn2.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.clockBtn3.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.clockBtn4.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    //图层移动
    [self bringSubviewToFront:self.playBtn];
    [self bringSubviewToFront:self.timeSlider];
    //        [self bringSubviewToFront:self.rangeView];
    [self bringSubviewToFront:self.clockLabel];
    [self bringSubviewToFront:self.clockView];
}


/**
 *  设置View圆角
 */
-(void)setTheViewCornerRadius:(UIView *)view cornerRadius:(CGFloat)cornerRadius {
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}


//range Slider
- (void)setUpRangeSlider
{
    /*
     self.rangeSlider.delegate = self;
     self.rangeSlider.minValue = 0.0f;//最小值
     self.rangeSlider.maxValue = (float)assDura;//最大值
     self.rangeSlider.selectedMinimum = 0.0f;//选中开始值
     self.rangeSlider.selectedMaximum = (float)assDura;//选中最大值
     self.rangeSlider.backgroundColor = [UIColor clearColor];
     self.rangeSlider.minLabelColour = [UIColor whiteColor];
     self.rangeSlider.maxLabelColour = [UIColor whiteColor];
     self.rangeSlider.maxLabel.string = [NSString stringWithFormat:@"%.2f",(float)assDura];//选中的label的最大值
     self.rangeSlider.minLabel.string = [NSString stringWithFormat:@"%.2f",0.0f];//最小
     */
    
}


#pragma mark - 监听播放事件
/**
 *  播放时监听
 */
-(void)notifPlayTime
{

 
    //播完
    if (self.timeSlider.value == self.timeSlider.maximumValue) {
        self.player.rate = 0;//
        [self.timer invalidate];//停止timer的监听
        self.timer = nil;//timer指向nil
        self.playBtn.selected = NO;
        _playFinish = YES;
        if (self.playerDidPlayFinish) {//播放完成
            self.playerDidPlayFinish();//回调控制器
        }
    }
    
    CMTime time = [self.player.currentItem currentTime];
    CGFloat currentSec = (CGFloat)(time.value *1.0f / time.timescale);
    self.sliderValue = self.timeSlider.value = currentSec;
    
    NSLog(@"进度条 = %f 实际 = %f",self.sliderValue,currentSec);
    //更新进度条
    [self updateSliderPopoverTextCurreSec:currentSec];

    //    CGFloat xiangChaSec = currentSec - self.biaoJiTime;
    //    [self changeClockLabelText:currentSec biaoJiTime:self.biaoJiTime differentTime:xiangChaSec];
    //    self.rangeSlider.selectedMinimum = currentSec;
    
    //触发代理
    if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
        [self.playerDelegate player:self NotifCurrTimes:currentSec];
    }
    
}


#pragma mark - 外面拖动尺子改变帧
/**
 *  步进帧
 */
-(void)stepByCount:(CGFloat)count
{
    [self pause];
    if (count > 0) {//每拖一次改变0.01秒 向左拖 快进
        count = count *0.01;
        [self.timeSlider setValue:self.timeSlider.value + count animated:NO];
        [self timeSliderValueChange:self.timeSlider];
        self.sliderValue = self.timeSlider.value;
    }else //向右拖 倒退
    {
        count = count *0.1;
        [self.timeSlider setValue:self.timeSlider.value + count animated:NO];
        [self timeSliderValueChange:self.timeSlider];
        self.sliderValue = self.timeSlider.value;
    }
    
    if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
        [self.playerDelegate player:self NotifCurrTimes:self.timeSlider.value];
    }
    
}

#pragma mark - 原生Slider拖动事件
/**
 *  原生滑动条的值改变时
 *
 *  @param sender
 */
- (IBAction)timeSliderValueChange:(UISlider *)sender {
    //注销timer
    [self.timer invalidate];
    self.timer = nil;
    self.playBtn.selected = NO;
    [self.player pause];
    
    if (sender.value <= self.sliderValue) {//向左拖
        
        CMTime currenTime = [self.player.currentItem currentTime];
        
        float sliderValueChange = sender.value - self.sliderValue;
        self.sliderValue = sender.value;
        //视频现在的秒数
        float videoCurreSec = (CGFloat)currenTime.value/currenTime.timescale;
//        NSLog(@"向左slider的值改变了:%f",sliderValueChange);
        NSArray *itemTracks = self.player.currentItem.tracks;
        float moveZhen = 0 ;
        //拿出track 算每帧多少秒
        for (AVPlayerItemTrack *track in itemTracks) {
            //数组里面有声源和视频源 vide是视频源
            if ([track.assetTrack.mediaType isEqualToString: @"vide"]) {
                
                AVAssetTrack *assTrack = track.assetTrack;
                //时间结构体 显示轨道的帧的最小时间
                CMTime minFrameDuration = assTrack.minFrameDuration;
                //每帧的秒数
                CGFloat meiZhenMiao = (CGFloat)minFrameDuration.value / minFrameDuration.timescale;
//                NSLog(@"每%f秒1帧",meiZhenMiao);
//                NSLog(@"视频现在在%f秒 进度条%f秒",videoCurreSec,sender.value);
                //要移动的帧数
                moveZhen = sliderValueChange / meiZhenMiao;
//                NSLog(@"向左要移动%f帧", moveZhen);
                if (moveZhen > -0.5f) {
//                    NSLog(@"向左改变%f",moveZhen);
                }
            }
        }
        //利用 AVPlayerItem  stepByCount的方法能做到帧播放效果 移动多少帧率
        [self.player.currentItem stepByCount:moveZhen];
        sender.value = videoCurreSec;
        //更新滑动条上的label
        [self updateSliderPopoverTextCurreSec:videoCurreSec];

    }else if (sender.value >= self.sliderValue)
    {//向右拖
        
        float sliderValueChange = sender.value - self.sliderValue;
//        NSLog(@"向右slider的值改变了:%f",sliderValueChange);
        CMTime currenTime = [self.player.currentItem currentTime];
        //视频现在的秒数
        float videoCurreSec = (CGFloat)currenTime.value/currenTime.timescale;
        self.sliderValue = sender.value;//记录当前Value
        
        NSArray *itemTracks = self.player.currentItem.tracks;
        float moveZhen = 0 ;
        //拿出track 算每帧多少秒
        for (AVPlayerItemTrack *track in itemTracks) {
            //数组里面有声源和视频源 vide是视频源
            if ([track.assetTrack.mediaType isEqualToString: @"vide"]) {
                
                AVAssetTrack *assTrack = track.assetTrack;
                //时间结构体 显示轨道的帧的最小时间
                CMTime minFrameDuration = assTrack.minFrameDuration;
                //每帧的秒数
                CGFloat meiZhenMiao = (CGFloat)minFrameDuration.value / minFrameDuration.timescale;
//                NSLog(@"向右每%f秒1帧",meiZhenMiao);
//                NSLog(@"视频现在在%f秒 进度条%f秒",videoCurreSec,sender.value);
                //要移动的帧数
                moveZhen = sliderValueChange / meiZhenMiao;
//                NSLog(@"要移动%f帧", moveZhen);
                if (moveZhen < 0.5f) {//帧率如果比1小
                    moveZhen = 1 + moveZhen;
//                    NSLog(@"比1帧小-要移动%f帧", moveZhen);
                }
            }
        }
        //利用 AVPlayerItem  stepByCount的方法能做到帧播放效果 移动多少帧率
        [self.player.currentItem stepByCount:moveZhen];
        sender.value = videoCurreSec;
//        self.sliderValue = videoCurreSec;
        //更新滑动条上的label
        [self updateSliderPopoverTextCurreSec:videoCurreSec];
    }
    //拿出当前时间
//    CMTime currenTime = [self.player.currentItem currentTime];
//    float videoCurreSec = (CGFloat)currenTime.value/currenTime.timescale;
    //改变标记
//    [self changeClockLabelText:videoCurreSec biaoJiTime:self.biaoJiTime differentTime:videoCurreSec - self.biaoJiTime];
}

/**
 *  原生滑动条松手时
 *
 *  @param sender
 */
- (IBAction)slideDidTouchUP:(UISlider *)sender {
    CMTime currenTime = [self.player.currentItem currentTime];
    //视频现在的秒数
    float videoCurreSec = (CGFloat)currenTime.value/currenTime.timescale;
    //滑条的value以视频的时间为准
    self.sliderValue = sender.value = videoCurreSec;
    [self updateSliderPopoverTextCurreSec:videoCurreSec];
    
}

#pragma mark - 点击事件
- (IBAction)playBtnCilck:(UIButton *)sender {//播放按钮
    if (sender.selected)//播放中
    {
        [self pause];
        
    }else if(self.player.rate == 0.0)//暂停中
    {
        _isPlaying = sender.selected = YES;//播放
        [self play];
    }
}

#pragma mark - 标记时间
/**
 *  标记时间
 *
 */
- (IBAction)clockBtnClick:(UIButton *)sender {
    //rangeSlider
    /*
    [self.clockBtn setTitle:[NSString stringWithFormat:@"当前标记在%@",self.rangeSlider.minLabel.string] forState:UIControlStateNormal];
    NSString *minStr = self.rangeSlider.minLabel.string;
    self.biaoJiTime = minStr.floatValue;
    */
    
    CMTime time = [self.player.currentItem currentTime];
    //视频现在的秒数
    CGFloat currentSec = (CGFloat)(time.value *1.0f / time.timescale);
    //timeSlider
    if (self.timeSlider.value < 10) {
        [sender setTitle:[NSString stringWithFormat:@"0%.2f",self.timeSlider.value] forState:UIControlStateNormal];
    }else{
        [sender setTitle:[NSString stringWithFormat:@"%.2f",self.timeSlider.value] forState:UIControlStateNormal];
    }
    self.biaoJiTime = currentSec;
}


#pragma mark - 播放暂停
/**
 *  播放
 */
-(void)play {
    
    if (_playFinish) {//先判断是否播完 播完就重新开始
        [self.player seekToTime:CMTimeMake(0, 1)];
        self.timeSlider.value = 0;
    }
    _playFinish = NO;
    [self.player play];
    self.isPlaying = self.playBtn.selected = YES;
    [self createTimer];
    if (self.timeSlider.hidden == NO) {
        [self.timeSlider showPopoverAnimated:YES];
    }
}
/**
 *  暂停
 */
-(void)pause
{
    self.playBtn.selected = NO;
    [self.player pause];
    [self.timer invalidate];
    self.timer = nil;
}



#pragma mark - timer
/**
 *  创建时间加到runLoop
 *
 *  @return NSTimer
 */
-(NSTimer *)createTimer
{
    
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(notifPlayTime) userInfo:nil repeats:YES];
    self.timer = timer;
    return timer;
}

#pragma mark - 更新滑动条上的popLabel
/**
 *  更新滑动条上的popLabel
 */
- (void)updateSliderPopoverTextCurreSec:(float)videoCurreSec
{
    if (self.timeSlider.hidden)
    {
        [self.timeSlider hidePopover];
        return;
        
    }else{
        
        if (videoCurreSec < 10) {
            
            self.timeSlider.popover.textLabel.text = [NSString stringWithFormat:@"0%.2f", videoCurreSec];
        }else
        {
            self.timeSlider.popover.textLabel.text = [NSString stringWithFormat:@"%.2f", videoCurreSec];
        }
        
        [self.timeSlider showPopover];
    }
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}


/**
 *  给变标记label的时间
 *
 *  @param nowTime       现在的时间
 *  @param biaoJiTime    标记的时间
 *  @param differentTime 相差的时间
 */
-(void)changeClockLabelText:(float)nowTime biaoJiTime:(float)biaoJiTime differentTime:(float)differentTime
{
    self.clockLabel.text = [NSString stringWithFormat:@"现在秒数:%.2f-标记秒数:%.2f=相差:%.2f",nowTime,self.biaoJiTime,differentTime];
}



#pragma mark - 自定义slider - TTRangeSliderDelegate
/*
 -(void)rangeSlider:(TTRangeSlider *)sender didChangeSelectedMinimumValue:(float)selectedMinimum andMaximumValue:(float)selectedMaximum
 {
 CMTime currenTime = [self.player.currentItem currentTime];
 float videoCurreSec = (CGFloat)currenTime.value/currenTime.timescale;
 //会有+ - 0.05误差
 NSLog(@"range slider updated. Min Value: %.1f Max Value: %.1f", selectedMinimum, selectedMaximum);
 if (selectedMinimum * 0.1 *.1f >= selectedMaximum *0.1 * .1f ) {//越界
 NSLog(@"数值大于，slider到最大极限！");
 [self pause];
 
 self.rangeSlider.minLabel.string = [NSString stringWithFormat:@"%.2f",selectedMaximum];
 self.rangeSlider.maxLabel.string = [NSString stringWithFormat:@"%.2f",selectedMaximum];
 
 CGFloat xiangChaSec = selectedMaximum - self.biaoJiTime;
 //        self.clockLabel.text = [NSString stringWithFormat:@"现在秒数:%.2f-标记秒数:%.2f=相差:%.2f",selectedMaximum,self.biaoJiTime,xiangChaSec];
 [self changeClockLabelText:selectedMaximum biaoJiTime:self.biaoJiTime differentTime:xiangChaSec];
 
 return;
 }
 
 
 if (self.timer) {//播放
 self.rangeSlider.minLabel.string = [NSString stringWithFormat:@"%.2f",selectedMinimum];
 self.rangeSlider.maxLabel.string = [NSString stringWithFormat:@"%.2f",selectedMaximum];
 self.currentRangeValue = selectedMinimum;
 return;
 }else if (self.timer == nil && sender.maxLabelIsDrawing == NO)//不是播放中 即是说在拖动
 {
 
 
 NSLog(@"TimerNil");
 NSLog(@"上次的值：%f",self.currentRangeValue);
 float cha = selectedMinimum - self.currentRangeValue;
 self.currentRangeValue= selectedMinimum;
 NSLog(@"这次的值：%f - 传过来的值： %f",self.currentRangeValue,selectedMinimum);
 NSArray *itemTracks = self.player.currentItem.tracks;
 float moveZhen = 0 ;
 //拿出track 算每帧多少秒
 for (AVPlayerItemTrack *track in itemTracks) {
 //数组里面有声源和视频源 vide是视频源
 if ([track.assetTrack.mediaType isEqualToString: @"vide"]) {
 
 AVAssetTrack *assTrack = track.assetTrack;
 //时间结构体 显示轨道的帧的最小时间
 CMTime minFrameDuration = assTrack.minFrameDuration;
 //每帧的秒数
 CGFloat meiZhenMiao = (CGFloat)minFrameDuration.value / minFrameDuration.timescale;
 NSLog(@"向右每%f秒1帧",meiZhenMiao);
 //要移动的帧数
 moveZhen = cha / meiZhenMiao;
 }
 }
 //计算帧率步数 不够1的+上1
 if (moveZhen > 0) {
 
 moveZhen += 1;
 NSLog(@"向右小于0.5并为整数");
 }else  if (moveZhen < 0) {
 moveZhen -= 1;
 NSLog(@"向左小于0并为负数");
 }
 
 NSLog(@"MOveZhen - %f",moveZhen);
 
 NSLog(@"视频现在在%f秒 进度条%f秒",videoCurreSec,sender.selectedMinimum);
 
 [self.player.currentItem stepByCount:moveZhen];
 sender.minLabel.string = [NSString stringWithFormat:@"%.2f",videoCurreSec];
 CGFloat xiangChaSec = videoCurreSec - self.biaoJiTime;
 //        self.clockLabel.text = [NSString stringWithFormat:@"现在秒数:%.2f-标记秒数:%.2f=相差:%.2f",videoCurreSec,self.biaoJiTime,xiangChaSec];
 [self changeClockLabelText:videoCurreSec biaoJiTime:self.biaoJiTime differentTime:xiangChaSec];
 }
 else //在拖动大的
 {
 NSLog(@"拖动max");
 sender.maxLabel.string = [NSString stringWithFormat:@"%.2f",selectedMaximum];
 }
 }
 */


#pragma mark - Dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"SWplayer  -   dealloc");
}



@end

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
#import "TXHRrettyRuler.h"
//#import "TTRangeSlider.h"

//第三方
#import "Masonry.h"
#import "MBProgressHUD+MJ.h"

const NSInteger playerMaxRulerValue = 2222;//尺子长度
const CGFloat subViewAlpht = 0.55f;

@interface SWPlayer() <TXHRrettyRulerDelegate>//<TTRangeSliderDelegate>

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

/**
 *  是否隐藏着子view
 */
@property (nonatomic, assign) BOOL subViewIsHidden;
/**
 *  放尺子的view
 */
@property (weak, nonatomic) IBOutlet UIView *chiZiView;

@property (nonatomic, assign) CGFloat rulerValue;
/**
 *  视频约束开始时间
 */
@property (nonatomic, assign) CGFloat startTime;
/**
 *  视频约束结束时间
 */
@property (nonatomic, assign) CGFloat endTime;
/**
 *  手势移动的x
 */
@property (nonatomic, assign) CGFloat panX;

@end

@implementation SWPlayer


#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr
{
    if (self = [super init]) {
//        NSLog(@"init - %@",self);
        self = [[[UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil] instantiateWithOwner:nil options:nil]lastObject];
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        //设置player
        [self setUPplayerWithUrl:urlStr];
        
        //range Slider
        [self setUpRangeSlider];
        //UI细节
        [self setUpUI];
        //手势
        [self setUpNotifction];

    }
    return self;
}

#pragma mark - setUpPLayer
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
    CMTime zongT = self.player.currentItem.asset.duration;
    NSLog(@"视频总秒数 = %f —— value数 = %lld —— 每秒帧数 = %d —— 视频的总长度数 = %lld",assDura,zongT.value,zongT.timescale, zongT.value * zongT.timescale);
}

#pragma mark - setUp监听手势
-(void)setUpNotifction
{
    //添加手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerDidTap:)];
    tap.numberOfTapsRequired = 1;
    [self addGestureRecognizer:tap];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panThePlayer:)];

    [self addGestureRecognizer:pan];
}

#pragma mark - setUpUI
-(void)setUpUI
{
    //尺子
    self.rulerView = [[TXHRrettyRuler alloc]initWithFrame:CGRectMake(0, 0, SW_SCREEN_WIDTH, 44)];
    [self.rulerView showRulerScrollViewWithCount:playerMaxRulerValue average:[NSNumber numberWithFloat:1] currentValue:(playerMaxRulerValue)/2 smallMode:NO];
    self.rulerView.rulerDeletate = self;
    [self.chiZiView addSubview:self.rulerView];
    self.rulerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.chiZiView);
    }];
    [self bringSubviewToFront:self.chiZiView];
    
    //playBtn
    int corenrRaidus = 10;
    [self setTheViewCornerRadius:self.playBtn cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn1 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn2 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn3 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn4 cornerRadius:corenrRaidus];
    //clockBtn
    [self.clockBtn1.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.clockBtn2.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.clockBtn3.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.clockBtn4.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:16]];
    [self.playBtn.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:18]];
    [self.playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.playBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];

    self.timeSlider.alpha = subViewAlpht;
    self.playBtn.alpha = subViewAlpht;
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

#pragma mark - 尺子移动
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView
{
    //减去屏幕宽度的已移动多少宽度
    CGFloat contentOffSetWidth = rulerScrollView.contentSize.width - SW_SCREEN_WIDTH;
    
    if (rulerScrollView.contentOffset.x <= 0 || //到最左
        rulerScrollView.bounds.origin.x >= contentOffSetWidth)//到最右
    {
        NSLog(@"player到顶或底");
        [rulerScrollView setContentOffset:CGPointMake((rulerScrollView.contentSize.width-SW_SCREEN_WIDTH) / 2, 0) animated:NO];
        return;
    }
    
    if (rulerScrollView.rulerValue > self.rulerValue ) {//向左拖 rulerValue数值增加
        [self stepByCount:1];
        self.rulerValue = rulerScrollView.rulerValue;
        
    }else if (rulerScrollView.rulerValue < self.rulerValue) {//向右拖 数值减少
        [self stepByCount: -1];
        self.rulerValue = rulerScrollView.rulerValue;
    }else
    {
        NSLog(@"0");
        [self stepByCount:0];
        self.rulerValue = rulerScrollView.rulerValue;
    }
    [self.playBtn setImage:nil forState:UIControlStateNormal];
}


#pragma mark - 手势事件
-(void)playerDidTap:(UITapGestureRecognizer *)tap
{
    if (tap.state ==UIGestureRecognizerStateEnded) {
        if (_subViewIsHidden) {
            [UIView animateWithDuration:0.25 animations:^{
                self.timeSlider.alpha = subViewAlpht;
                self.playBtn.alpha = subViewAlpht;
                self.clockBtn1.alpha = subViewAlpht;
                self.clockBtn2.alpha = subViewAlpht;
                self.clockBtn3.alpha = subViewAlpht;
            }completion:^(BOOL finished) {
                //更新按钮的时间
                [self.playBtn setImage:nil forState:UIControlStateNormal];
                [self updateSliderPopoverTextCurreSec:self.timeSlider.value];
            }];
        }else{
            
            [UIView animateWithDuration:0.25 animations:^{
                self.timeSlider.alpha = 0;
                self.playBtn.alpha = 0;
                self.clockBtn1.alpha = 0;
                self.clockBtn2.alpha = 0;
                self.clockBtn3.alpha = 0;
            }completion:^(BOOL finished) {
                //更新按钮的时间
                [self.playBtn setImage:nil forState:UIControlStateNormal];
                [self updateSliderPopoverTextCurreSec:self.timeSlider.value];
            }];
        }
        _subViewIsHidden = !_subViewIsHidden;
        //触发block
        if (self.tapPlayerBlock) {
            self.tapPlayerBlock();
        }
    }
}
/**
 *  拖动
 */
-(void)panThePlayer:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateBegan) {
        NSLog(@"began");
    }
    
    //当值改变时才改变帧数
    if (pan.state == UIGestureRecognizerStateChanged) {
        NSLog(@"change");
        //移动的x
        CGPoint translatedPoint = [pan translationInView:self];
        
        if (_panX < translatedPoint.x) {//向右拖++
            [self stepByCount:1];
            
        }else                            //向左--
        {
            [self stepByCount:-1];
        }
        _panX = translatedPoint.x;
        
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
        NSLog(@"end");
    }
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
    NSLog(@"播放ing 进度条 = %f currentSEc = %f",self.sliderValue,currentSec);
    //更新进度条
    [self updateSliderPopoverTextCurreSec:currentSec];
    //触发代理
    if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
        [self.playerDelegate player:self NotifCurrTimes:currentSec];
    }
    
}

#pragma mark - 拖动尺子改变帧
/**
 *  步进帧
 */
-(void)stepByCount:(CGFloat)count
{
    [self pause];
    //当前时间
    CMTime time = [self.player.currentItem currentTime];
    CGFloat currentSec = (CGFloat)(time.value *1.0f / time.timescale);
    
    if (currentSec >= self.endTime && self.endTime != 0 && count > 0) {//限制不能快进
        NSLog(@"到达endTime");
        [self updateSliderPopoverTextCurreSec:currentSec];
        return;
    }
    
    if (currentSec <= self.startTime && self.startTime != 0 && count < 0) {//不能后退
        NSLog(@"到达startTime");
        [self updateSliderPopoverTextCurreSec:currentSec];
        return;
    }
    
    //每拖一次改变0.1秒动3帧 向左拖 快进
    [self.player.currentItem stepByCount:count];
    
    self.sliderValue = self.timeSlider.value = currentSec;
    [self.playBtn setImage:nil forState:UIControlStateNormal];
    //执行代理
    if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
        [self.playerDelegate player:self NotifCurrTimes:currentSec];
    }
    [self updateSliderPopoverTextCurreSec:currentSec];
    
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
    [self.playBtn setImage:nil forState:UIControlStateNormal];
    
    CMTime currenTime = [self.player.currentItem currentTime];
    //视频现在的秒数
    float videoCurreSec = (CGFloat)currenTime.value/currenTime.timescale;
    //改变的秒数 现在的value - 现在的秒数
    float sliderValueChange = sender.value - self.sliderValue;
    NSLog(@"相差 = %f",sliderValueChange);
    //改变的值向右拖时如果比0.1秒小 就会没反应
    if (sliderValueChange <0.1f && sliderValueChange > 0) {
        sliderValueChange = 0.1f;
    }
    else if (sliderValueChange > -0.1 && sliderValueChange < 0)
    {
        sliderValueChange = -0.1f;
    }
    
    self.sliderValue = sender.value;
    NSArray *itemTracks = self.player.currentItem.tracks;
    float moveZhen = 0 ;
    //拿出track 算每帧多少秒
    for (AVPlayerItemTrack *track in itemTracks) {
        //数组里面有声源和视频源 vide是视频源
        if ([track.assetTrack.mediaType isEqualToString: @"vide"]) {
            
            AVAssetTrack *assTrack = track.assetTrack;
            //时间结构体 显示轨道的帧的最小时间
            CMTime minFrameDuration = assTrack.minFrameDuration;
            //每帧的秒数 每0.03秒一帧数
            CGFloat meiZhenMiao = (CGFloat)minFrameDuration.value / minFrameDuration.timescale;
            //要移动的帧数
            moveZhen = sliderValueChange / meiZhenMiao;
        }
    }
    //利用 AVPlayerItem  stepByCount的方法能做到帧播放效果 移动多少帧率
    NSLog(@"要移动%f帧",moveZhen);
    //移动帧
    [self.player.currentItem stepByCount:moveZhen];
    sender.value = videoCurreSec;
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

#pragma mark - 标记时间事件
//计算相差
- (IBAction)reSetTime:(UIButton *)sender {
    CGFloat diffNum = self.endTime - self.startTime;
    [sender setTitle:[NSString stringWithFormat:@"%.2f",diffNum] forState:UIControlStateNormal];
}

#pragma mark - 标记结束时间
- (IBAction)endTimeBtnClick:(UIButton *)sender {
    
    self.endTime = self.timeSlider.value;
//    NSLog(@"end time = %f",self.endTime);
    if (self.endTime <= self.startTime) {
        [MBProgressHUD show:@"结束时间不能少于或等于开始时间" icon:@"error" view:self];
        
        if (self.endTime == 0) {
            [MBProgressHUD show:@"结束时间不能为0" icon:@"error" view:self];
        }
    }else{
        if (self.timeSlider.value < 10) {
            [sender setTitle:[NSString stringWithFormat:@"0%.2f",self.timeSlider.value] forState:UIControlStateNormal];
        }else{
            [sender setTitle:[NSString stringWithFormat:@"%.2f",self.timeSlider.value] forState:UIControlStateNormal];
        }
    }
    
}

/**
 *  标记开始时间
 *
 */
- (IBAction)clockBtnClick:(UIButton *)sender {

    self.startTime = self.timeSlider.value;
//    NSLog(@"start time = %f",self.startTime);

    if (self.timeSlider.value < 10) {
        [sender setTitle:[NSString stringWithFormat:@"0%.2f",self.timeSlider.value] forState:UIControlStateNormal];
    }else{
        [sender setTitle:[NSString stringWithFormat:@"%.2f",self.timeSlider.value] forState:UIControlStateNormal];
    }
}


#pragma mark - 播放暂停
/**
 *  播放
 */
-(void)play {
    
    [self.playBtn setImage:nil forState:UIControlStateNormal];
    
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
    
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:0.10f target:self selector:@selector(notifPlayTime) userInfo:nil repeats:YES];
    self.timer = timer;
    return timer;
}

#pragma mark - 更新滑动条上的popLabel
/**
 *  更新滑动条上的popLabel
 */
- (void)updateSliderPopoverTextCurreSec:(float)videoCurreSec
{
    if (videoCurreSec < 10) {
        
        self.timeSlider.popover.textLabel.text = [NSString stringWithFormat:@"0%.2f", videoCurreSec];
        [self.playBtn setTitle:[NSString stringWithFormat:@"0%.2f",videoCurreSec] forState:UIControlStateNormal];
    }else
    {
        self.timeSlider.popover.textLabel.text = [NSString stringWithFormat:@"%.2f", videoCurreSec];
        [self.playBtn setTitle:[NSString stringWithFormat:@"%.2f",videoCurreSec] forState:UIControlStateNormal];
    }
}

#pragma mark - layoutSubviews
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}

-(void)willMoveToWindow:(UIWindow *)newWindow
{
    //将要显示到最前
}

-(void)willMoveToSuperview:(UIView *)newSuperview
{
    //将要显示在父view
}


#pragma mark - Dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"SWplayer  -   dealloc %@",self);
    //每次init重载后会先释放父类的 所以会调用一次
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

@end

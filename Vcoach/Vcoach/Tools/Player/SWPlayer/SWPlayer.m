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
#import "SWDevelopmentTool.h"

//第三方
#import "Masonry.h"
#import "MBProgressHUD+MJ.h"

const NSInteger playerMaxRulerValue = 2222;//尺子长度
const CGFloat subViewAlpht = 1.0f;//透明度

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
/**
 *  是否拖动
 */
@property (nonatomic, assign) BOOL isPaning;
/**
 *  秒/帧数
 */
@property (nonatomic, assign) int videoZhen;

@property(nonatomic ,assign) BOOL isIpad;

@end

@implementation SWPlayer


#pragma mark - init
-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr
{
    if (self = [super init]) {

        self = [[[UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil] instantiateWithOwner:nil options:nil]lastObject];
        self.frame = frame;
        self.backgroundColor = [UIColor blackColor];
        NSString * deviceType = [SWDevelopmentTool getDeviceType];
        if ([deviceType isEqualToString:@"ipad"]) {
            self.isIpad = YES;
        }else{ self.isIpad = NO;}
        
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
    //    rate能调播放数度
    //    player.rate = 0.5;
    
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
//    NSLog(@" \n 视频总秒数 = %f\n value数 = %lld\n 每秒帧数 = %d\n 视频的总长度数 = %lld\n",assDura,zongT.value,zongT.timescale, zongT.value * zongT.timescale);
    self.videoZhen = zongT.timescale;
    //监听player状态
    //    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //每一秒回调一次 ， 拖动就会调用
//    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:NULL usingBlock:^(CMTime time) {}];
}

#pragma mark - setUpUI
-(void)setUpUI
{

    float corenrRaidus = 10;
    float fontsize = 16;
    float playFontSize = 18;
    float rulerHeight = 44;
    if (self.isIpad) {
        corenrRaidus = 4.75;
        fontsize = 8;
        playFontSize = 10;
        
        [self.clockBtn1 mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(120/2, 60/2));
        }];
        [self.playBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(self.clockBtn1);
        }];
    }
    
    //尺子
    self.rulerView = [[TXHRrettyRuler alloc]initWithFrame:CGRectMake(0, 0, SW_SCREEN_WIDTH, rulerHeight)];
    [self.rulerView showRulerScrollViewWithCount:playerMaxRulerValue average:[NSNumber numberWithFloat:1] currentValue:(playerMaxRulerValue)/2 smallMode:NO];
    self.rulerView.rulerDeletate = self;
    [self.chiZiView addSubview:self.rulerView];
    self.rulerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.rulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.chiZiView);
    }];
    [self bringSubviewToFront:self.chiZiView];
    
    //playBtn
    [self setTheViewCornerRadius:self.playBtn cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn1 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn2 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn3 cornerRadius:corenrRaidus];
    [self setTheViewCornerRadius:self.clockBtn4 cornerRadius:corenrRaidus];
    //clockBtn
    [self.clockBtn1.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:fontsize]];
    [self.clockBtn2.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:fontsize]];
    [self.clockBtn3.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:fontsize]];
    [self.clockBtn4.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:fontsize]];
    [self.playBtn.titleLabel setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:playFontSize]];
    [self.playBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [self.playBtn setImage:[UIImage imageNamed:playImageName] forState:UIControlStateNormal];
    [self.playBtn setTitle:@"＞" forState:UIControlStateNormal];
    self.timeSlider.alpha = subViewAlpht;
    
    self.playBtn.alpha = subViewAlpht;
    self.clockBtn1.alpha = subViewAlpht;
    self.clockBtn2.alpha = subViewAlpht;
    self.clockBtn3.alpha = subViewAlpht;
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
//        NSLog(@"began");
    }
    
    //当值改变时才改变帧数
    if (pan.state == UIGestureRecognizerStateChanged) {
//        NSLog(@"change");
        _isPaning = YES;
        
        CGPoint translatedPoint = [pan translationInView:self];
        
        if (_panX < translatedPoint.x) {//right slide++
            [self stepByCount:1];
            
        }else                            //left slide--
        {
            [self stepByCount:-1];
        }
        _panX = translatedPoint.x;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded) {
//        NSLog(@"end");
        _isPaning = NO;
    }
}

#pragma mark - 监听播放事件
/**
 *  播放时监听
 */
-(void)notifPlayTime
{
    CMTime time = [self.player.currentItem currentTime];
    CGFloat currentSec = (CGFloat)(time.value *1.0f / time.timescale);
    
    if (currentSec >= self.endTime && self.endTime != 0) {//播放到结束时间后
        [self pause];//暂停
        [self updateSliderPopoverTextCurreSec:self.endTime];
        //更新时间代理
        if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
            [self.playerDelegate player:self NotifCurrTimes:self.endTime];
        }
        if (self.playerDidPlayFinish) {//播放完成
            self.playerDidPlayFinish();//回调控制器
        }
        return;
    }
    //播完
    if (self.timeSlider.value == self.timeSlider.maximumValue) {
//        self.player.rate = 0;//
        [self.timer invalidate];//停止timer的监听
        self.timer = nil;//timer指向nil
        self.playBtn.selected = NO;
        _playFinish = YES;
        if (self.playerDidPlayFinish) {//播放完成
            self.playerDidPlayFinish();//回调控制器
        }
    }
    
    self.sliderValue = self.timeSlider.value = currentSec;
//    NSLog(@"播放ing 进度条 = %f currentSEc = %f",self.sliderValue,currentSec);
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
    _playFinish = NO;
    [self pause];
    //当前时间
    CMTime time = [self.player.currentItem currentTime];
    CGFloat currentSec = (CGFloat)(time.value *1.0f / time.timescale);
    
    if (currentSec >= self.endTime && self.endTime != 0 && count > 0 && _isPaning == NO) {//限制不能快进
        NSLog(@"到达endTime");
        [self updateSliderPopoverTextCurreSec:self.endTime];
        if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
            [self.playerDelegate player:self NotifCurrTimes:self.endTime];
        }
        return;
    }
    
    if (currentSec <= self.startTime && self.startTime != 0 && count < 0 && _isPaning == NO) {//不能后退
        NSLog(@"到达startTime");
        [self updateSliderPopoverTextCurreSec:self.startTime];
        if ([self.playerDelegate respondsToSelector:@selector(player:NotifCurrTimes:)]) {
            [self.playerDelegate player:self NotifCurrTimes:self.startTime];
        }
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
    _playFinish = NO;
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
//    NSLog(@"相差 = %f",sliderValueChange);
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
//    NSLog(@"要移动%f帧",moveZhen);
    //移动帧
    [self.player.currentItem stepByCount:moveZhen];
    sender.value = videoCurreSec;
    [self updateSliderPopoverTextCurreSec:videoCurreSec];
//    NSLog(@"拖动的时间 = %f 进度条时间 = %f",videoCurreSec,sender.value);
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

//计算相差
- (IBAction)reSetTime:(UIButton *)sender {
    CGFloat diffNum = self.endTime - self.startTime;
    [sender setTitle:[NSString stringWithFormat:@"%.2f",diffNum] forState:UIControlStateNormal];
}

#pragma mark - 标记结束时间
- (IBAction)endTimeBtnClick:(UIButton *)sender {
    
    if (self.endTime != 0) {//再点一次就重置结束值
        [sender setTitle:@"结束时间" forState:UIControlStateNormal];
        self.endTime = 0;
        return;
    }
    
    self.endTime = self.timeSlider.value;
    
    if (self.endTime == 0) {
        [MBProgressHUD show:@"结束时间不能为0" icon:@"error" view:self];
        return;
    }
    
    if (self.endTime <= self.startTime) {//记录结束值
        [MBProgressHUD show:@"不能少于或等于开始时间" icon:@"error" view:self];
        [sender setTitle:@"Error" forState:UIControlStateNormal];
        self.endTime = self.timeSlider.maximumValue;
        return;
    }else{
        if (self.timeSlider.value < 10) {
            [sender setTitle:[NSString stringWithFormat:@"0%.2f",self.timeSlider.value] forState:UIControlStateNormal];
        }else{
            [sender setTitle:[NSString stringWithFormat:@"%.2f",self.timeSlider.value] forState:UIControlStateNormal];
        }
        [self.clockBtn3 setTitle:[NSString stringWithFormat:@"%.2f",self.endTime - self.startTime] forState:UIControlStateNormal];
    }
    
}
#pragma mark - 标记开始时间
/**
 *  标记开始时间
 *
 */
- (IBAction)clockBtnClick:(UIButton *)sender {

    if (self.startTime != 0) {//再点一次就重置开始值
        [sender setTitle:@"开始时间" forState:UIControlStateNormal];
        self.startTime = 0;
        return;
    }
    self.startTime = self.timeSlider.value;
    if (self.timeSlider.value < 10) {
        [sender setTitle:[NSString stringWithFormat:@"0%.2f",self.timeSlider.value] forState:UIControlStateNormal];
    }else{
        [sender setTitle:[NSString stringWithFormat:@"%.2f",self.timeSlider.value] forState:UIControlStateNormal];
    }
    if (self.endTime != 0) {
        [self.clockBtn3 setTitle:[NSString stringWithFormat:@"%.2f",self.endTime - self.startTime] forState:UIControlStateNormal];
    }
}


#pragma mark - 播放暂停
/**
 *  播放
 */
-(void)play {
    
    [self.playBtn setImage:nil forState:UIControlStateNormal];
    CMTime time = [self.player.currentItem currentTime];
    CGFloat currentSec = (CGFloat)(time.value *1.0f / time.timescale);
    
    if (_playFinish) {//先判断是否播完 播完就重新开始
        [self.player seekToTime:CMTimeMake(0, 1)];
        self.sliderValue = self.timeSlider.value = 0;
        _playFinish = NO;
    }
    else if (currentSec >= self.endTime && self.endTime != 0){//如果结束了再点播放
        //重开始时间开始播
        __weak typeof(self) weakSelf = self;
        [self.player seekToTime:CMTimeMake(self.startTime*self.videoZhen, self.videoZhen)toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
            [weakSelf pause];
            weakSelf.sliderValue = weakSelf.timeSlider.value = weakSelf.startTime;
            [weakSelf updateSliderPopoverTextCurreSec:weakSelf.startTime];
            if (weakSelf.playerDidPlayFinish) {
                weakSelf.playerDidPlayFinish();
            }
            return ;
        }];
    }
    [self.player play];
    self.isPlaying = self.playBtn.selected = YES;
    [self createTimer];
}
/**
 *  暂停
 */
-(void)pause
{
    [self.player pause];
    self.playBtn.selected = NO;
    [self.timer invalidate];
    self.timer = nil;
}

#pragma mark - timer监听
/**
 *  创建时间加到runLoop
 *
 *  @return NSTimer
 */
-(NSTimer *)createTimer
{
    
    NSTimer *timer =  [NSTimer scheduledTimerWithTimeInterval:0.01f target:self selector:@selector(notifPlayTime) userInfo:nil repeats:YES];
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
        
//        self.timeSlider.popover.textLabel.text = [NSString stringWithFormat:@"0%.2f", videoCurreSec];
        [self.playBtn setTitle:[NSString stringWithFormat:@"0%.2f",videoCurreSec] forState:UIControlStateNormal];
    }else
    {
//        self.timeSlider.popover.textLabel.text = [NSString stringWithFormat:@"%.2f", videoCurreSec];
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
    [self.playerLayer removeFromSuperlayer];
    self.player = nil;
    self.playerLayer = nil;
    self.timer = nil;
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"SWplayer  -   dealloc\n %@",self);
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

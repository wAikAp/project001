//
//  ViewController.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/8.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

//自己
#import "SWContrastVideoPlayerController.h"
#import "SightPlayerViewController.h"
#import "SWPlayer.h"
#import "SWMoveButton.h"
//第三方
#import "Masonry.h"
#import "TXHRrettyRuler.h"
#import "NYSliderPopover.h"
#import "UIView+SWUtility.h"
//系统
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

const float CENTER_BUTTON_HEIGHT = 44;//按钮高度
const NSInteger maxRulerValue = 9999;//尺子长度
const float animationSec = 0.15f;


@interface SWContrastVideoPlayerController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,TXHRrettyRulerDelegate,SWPlayerDelegate , SWMoveButtonDelegate>


@property (nonatomic, strong)IBOutlet UIView *player1View;

@property (nonatomic, strong)IBOutlet UIView *player2View;

@property (nonatomic, strong) SWPlayer *player1;

@property (nonatomic, strong) SWPlayer *player2;


/**
 *  右上浮动按钮
 */
@property (strong, nonatomic) SWMoveButton *topRightBtn;
/**
 *  叠合状态
 */
@property (nonatomic, assign) BOOL isDoubleSreen;
/**
 *  播放按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *vcPlayBtn;
/**
 *  尺子view的参考view (透明的)
 */
@property (weak, nonatomic) IBOutlet UIView *scrollTimeView;
/**
 *  底部工具view
 */
@property (weak, nonatomic) IBOutlet UIView *vcToolView;
/**
 *  尺子view
 */
@property (nonatomic, strong) TXHRrettyRuler *rulerView;
/**
 *  记录尺子的value
 */
@property (nonatomic, assign) CGFloat ruleValue;
/**
 *  判断哪个按了添加 1和2
 */
@property (nonatomic, assign) CGFloat whichBtnNum;
/**
 *  全屏时记录Video1label
 */
@property (nonatomic, strong) UILabel *video1Label;
/**
 *  全屏时记录Video2label
 */
@property (nonatomic, strong) UILabel *video2Label;
/**
 *  装载label的view
 */
@property (nonatomic, strong) UIView *labelView;

/**
 *  叠合按钮
 */
@property (nonatomic, strong) UIButton *pop1Btn;
@property (nonatomic, strong) UIButton *pop2Btn;
@property (nonatomic, strong) UIButton *pop3Btn;

@end

@implementation SWContrastVideoPlayerController

#pragma mark - viewDidLoad
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.vcPlayBtn.layer.cornerRadius = 15;
    self.vcPlayBtn.layer.masksToBounds = YES;
    //叠合按钮
    [self setUPTopRightBtn];
    //尺子view
    [self setUPRulerView];
    //label
    [self setUpVideoTimesLabel];
    //navBarItem
    [self setUPNavBar];
    //监听旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - SetUpUI
/**
 *  叠合状态下显示当前时间
 */
-(void)setUpVideoTimesLabel
{
    
    UIView *labelView = [[UIView alloc]init];
    [self.view addSubview:labelView];
    
    //label1
    UILabel *video1Label = [[UILabel alloc]init];
    video1Label.text = @"视频ONE :";
    video1Label.textColor = [UIColor whiteColor];
    [labelView addSubview:video1Label];
    self.video1Label = video1Label;
    [video1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(labelView).offset(10);
    }];
    [video1Label setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:18]];
    //label2
    UILabel *video2Label = [[UILabel alloc]init];
    video2Label.text = @"视频TWO :";
    video2Label.textColor = [UIColor whiteColor];
    [labelView addSubview:video2Label];
    self.video2Label = video2Label;
    [video2Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(video1Label.mas_bottom).offset(5);
        make.leading.mas_equalTo(video1Label);
    }];
    [video2Label setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:18]];
    
    [labelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self.player1View);
        make.trailing.mas_equalTo(video2Label).offset(5);
        make.bottom.mas_equalTo(video2Label).offset(5);
    }];
    self.labelView = labelView;
    
    labelView.hidden = YES;
}


/**
 *  叠合按钮
 */
-(void)setUPTopRightBtn
{
    self.topRightBtn = [SWMoveButton buttonWithType:UIButtonTypeCustom];
    self.topRightBtn.frame = CGRectMake(SW_SCREEN_WIDTH - 60 - 5, 70, 60, 60);
    
    self.topRightBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//文字水平居中
    self.topRightBtn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//垂直
    self.topRightBtn.titleLabel.numberOfLines = 0;
    self.topRightBtn.backgroundColor = [UIColor whiteColor];
    
    [self.topRightBtn setTitle:@"  按钮\n闭合ing" forState:UIControlStateNormal];
    [self.topRightBtn setTitle:@"  按钮\n展开ing" forState:UIControlStateSelected];
    [self.topRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.topRightBtn.titleLabel.font = [UIFont systemFontOfSize:13];
    self.topRightBtn.selected = NO;
    self.topRightBtn.layer.cornerRadius = 15;
    self.topRightBtn.layer.masksToBounds = YES;
    [self.topRightBtn addTarget:self action:@selector(topRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.topRightBtn];
    self.topRightBtn.moveButtonDelegate = self;
    //pop按钮
    [self popSubButton];
    [self.view bringSubviewToFront:self.topRightBtn];
}

-(void)popSubButton {
    
    UIButton *pop1Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop1Btn setTitle:@"叠合" forState:UIControlStateNormal];
    pop1Btn.backgroundColor = [UIColor redColor];
    pop1Btn.titleLabel.font = [UIFont systemFontOfSize:13];
    pop1Btn.layer.cornerRadius = 15;
    pop1Btn.layer.masksToBounds = YES;
    [self.view addSubview:pop1Btn];
    pop1Btn.tag = 0;
    pop1Btn.frame = self.topRightBtn.frame;
    self.pop1Btn = pop1Btn;
//    self.pop1Btn.alpha = 0.0f;
    [pop1Btn addTarget:self action:@selector(popBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *pop2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop2Btn setTitle:@"Video1" forState:UIControlStateNormal];
    pop2Btn.backgroundColor = [UIColor blueColor];
    pop2Btn.titleLabel.font = [UIFont systemFontOfSize:13];
    pop2Btn.layer.cornerRadius = 15;
    pop2Btn.layer.masksToBounds = YES;
    [self.view addSubview:pop2Btn];
    pop2Btn.tag = 1;
    self.pop2Btn = pop2Btn;
    pop2Btn.frame = pop1Btn.frame;
    [pop2Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pop3Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop3Btn setTitle:@"Video2" forState:UIControlStateNormal];
    [pop3Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop3Btn.backgroundColor = [UIColor whiteColor];
    pop3Btn.titleLabel.font = [UIFont systemFontOfSize:13];
    pop3Btn.layer.cornerRadius = 15;
    pop3Btn.layer.masksToBounds = YES;
    [self.view addSubview:pop3Btn];
    pop3Btn.tag = 2;
    self.pop3Btn = pop3Btn;
    pop3Btn.frame = pop1Btn.frame;
    [pop3Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
}


/**
 *  navBarItem
 */
-(void)setUPNavBar
{
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navRightBtn setTitle:@"单独" forState:UIControlStateNormal];
    [navRightBtn addTarget:self action:@selector(navRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    navRightBtn.frame = CGRectMake(0, 0, 60, 60);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navRightBtn];
    
}

/**
 *  尺子view
 */
-(void)setUPRulerView
{
    //毛玻璃
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurView = [[UIVisualEffectView alloc] initWithEffect:effect];
    blurView.translatesAutoresizingMaskIntoConstraints = NO;
    blurView.userInteractionEnabled = NO;
    [self.vcToolView addSubview:blurView];
    
    [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.mas_equalTo(self.vcToolView);
    }];
    
    //尺子
    self.rulerView = [[TXHRrettyRuler alloc]initWithFrame:CGRectMake(0, 0, SW_SCREEN_WIDTH, 60)];
    [self.rulerView showRulerScrollViewWithCount:maxRulerValue average:[NSNumber numberWithFloat:1] currentValue:(maxRulerValue)/2 smallMode:NO];
    self.rulerView.rulerDeletate = self;
    [self.vcToolView addSubview:self.rulerView];

    self.rulerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rulerView.alpha = 0.7f;
    [self.rulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.vcToolView);
    }];
    
//    self.vcToolView.hidden = YES;
    [self.vcToolView bringSubviewToFront:self.vcPlayBtn];
    
}


#pragma mark - 尺子拖动
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    NSLog(@"拖动");
//    NSLog(@"rulerScrollView.rulerValue = %f  rulerScrollView.count = %lu ",rulerScrollView.rulerValue,(unsigned long)rulerScrollView.rulerCount);
    
//    NSLog(@"scroll contofSet = %@  intSetLeft = %f  bounds = %@  ContSize = %@",NSStringFromCGPoint(rulerScrollView.contentOffset),rulerScrollView.contentInset.left,NSStringFromCGRect(rulerScrollView.bounds),NSStringFromCGSize(rulerScrollView.contentSize));
    
    //减去屏幕宽度的已移动多少宽度
    CGFloat contentOffSetWidth = rulerScrollView.contentSize.width - SW_SCREEN_WIDTH;
    
    if (rulerScrollView.contentOffset.x <= 0 || //到最左
        rulerScrollView.bounds.origin.x >= contentOffSetWidth)//到最右
    {
        NSLog(@"到顶或底");
        [rulerScrollView setContentOffset:CGPointMake((rulerScrollView.contentSize.width-SW_SCREEN_WIDTH) / 2, 0) animated:NO];
        return;
    }
    
    
    self.vcPlayBtn.selected = NO;
    if (self.player1 != nil && self.player2 != nil) {//有视频
        if (rulerScrollView.rulerValue > self.ruleValue ) {//向左拖 rulerValue数值增加
            [self.player1 stepByCount:1];
            [self.player2 stepByCount:1];
            self.ruleValue = rulerScrollView.rulerValue;
            
        }else if (rulerScrollView.rulerValue < self.ruleValue) {//向右拖 数值减少
            [self.player1 stepByCount: -1];
            [self.player2 stepByCount: -1];
            self.ruleValue = rulerScrollView.rulerValue;
        }
    }
    
    
}
#pragma mark - navBTN
-(void)navRightBtnClick
{
    SightPlayerViewController *sigVC = [[SightPlayerViewController alloc]init];
    [self.navigationController pushViewController:sigVC animated:YES];
}

#pragma mark - 清空视频
/**
 *  清空视频
 */
- (IBAction)clickVideoBtn:(UIButton *)sender
{
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[SWPlayer class]]) {
            [subView removeFromSuperview];
            self.player1 = nil;
            self.player2 = nil;
        }
    }
}

#pragma mark - imagePicker回调
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    self.topRightBtn.hidden = NO;
    
    if (self.player1 == nil && self.whichBtnNum == 1) {
        SWPlayer *player1 = [[SWPlayer alloc]initWithFrame:self.player1View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];//player1
        self.player1View.backgroundColor = [UIColor blackColor];
        self.player1 = player1;
        player1.playerDelegate = self;
        player1.playerNumber = 1;//number
        [self.view addSubview:player1];
        [player1 setPlayerDidPlayFinish:^{//播放完成回调
            self.vcPlayBtn.selected = NO;
        }];
        player1.translatesAutoresizingMaskIntoConstraints = NO;
        [player1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.bottom.trailing.mas_equalTo(self.player1View);
        }];
        
    }else if (self.player2 == nil && self.whichBtnNum == 2) {
        SWPlayer *player2 = [[SWPlayer alloc]initWithFrame:self.player2View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];
        self.player2 = player2;
        [self.view addSubview:player2];
        player2.playerDelegate = self;
        player2.playerNumber = 2;
        [player2 setPlayerDidPlayFinish:^{//完成回调
            self.vcPlayBtn.selected = NO;
        }];
        player2.translatesAutoresizingMaskIntoConstraints = NO;
        [player2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
        }];
    }
    [self.view bringSubviewToFront:self.vcToolView];
    self.vcToolView.hidden = NO;
    [self.view bringSubviewToFront:self.labelView];
    [self.view bringSubviewToFront:self.pop1Btn];
    [self.view bringSubviewToFront:self.pop2Btn];
    [self.view bringSubviewToFront:self.pop3Btn];
    [self.view bringSubviewToFront:self.topRightBtn];
    
/*
    self.vcPlayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.vcPlayBtn setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [self.vcPlayBtn setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    self.vcPlayBtn.frame = CGRectMake(10, self.view.bounds.size.height - 60 * 2, 60, 60);
    self.vcPlayBtn.backgroundColor = [UIColor blueColor];
    self.vcPlayBtn.layer.cornerRadius = 30;
    self.vcPlayBtn.layer.masksToBounds = YES;
    [self.view addSubview:self.vcPlayBtn];
    [self.vcPlayBtn addTarget:self action:@selector(vcPlayBtnCilck:) forControlEvents:UIControlEventTouchUpInside];
    
    self.vcTimeSlider = [[UISlider alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(self.vcPlayBtn.frame), self.view.bounds.size.width - 20, 40)];
    
    [self.view addSubview:self.vcTimeSlider];
    self.vcTimeSlider.maximumValue = (self.player1.sliderMaxValue + self.player2.sliderMaxValue) /2;
    self.vcTimeSlider.value = (self.player1.currenSliderValue + self.player2.currenSliderValue)/2;
    player1.playerDelegate = self;
    player2.playerDelegate = self;
*/

}

#pragma mark - player播放监听代理
-(void)player:(SWPlayer *)player NotifCurrTimes:(CGFloat)times
{
    if (player.playerNumber == 1) {
        if (times < 10) {
            self.video1Label.text = [NSString stringWithFormat:@"视频ONE : 0%.2f",times];
        }else{
            self.video1Label.text = [NSString stringWithFormat:@"视频ONE : %.2f",times];
        }
    }else if (player.playerNumber == 2)
    {
        if (times < 10) {
            self.video2Label.text = [NSString stringWithFormat:@"视频TWO : 0%.2f",times];
        }else{
            self.video2Label.text = [NSString stringWithFormat:@"视频TWO : %.2f",times];
        }
    }
    
    
    
}

#pragma mark - 添加视频按钮
- (IBAction)addVideoPlayerOne:(UIButton *)sender
{
    self.player1 = nil;
    self.whichBtnNum = sender.tag;
    [self openThePickerController];
}

- (IBAction)addVideoPlayerTwo:(UIButton *)sender
{
    self.player2 = nil;
    self.whichBtnNum = sender.tag;
    [self openThePickerController];
}

#pragma mark - 开启图库
-(void)openThePickerController
{

    UIImagePickerController *pickController = [[UIImagePickerController alloc]init];
    pickController.delegate = self;
    pickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    pickController.view.backgroundColor = [UIColor whiteColor];
    pickController.mediaTypes =  [NSArray arrayWithObjects:@"public.movie", nil];
    pickController.allowsEditing = YES;
    
    pickController.videoQuality = UIImagePickerControllerQualityTypeHigh;
    
    [self presentViewController:pickController animated:YES completion:nil];
}

#pragma mark - 播放按钮点击
- (IBAction)vcPlayBtnClick:(UIButton *)sender
{
    //播放 暂停 换样式 pop选单
    if (self.player1 == nil && self.player2 == nil) {
        return;
    }
    if (self.player1.player.rate == 0.0f && self.player2.player.rate == 0.0f){
        sender.selected = YES;
        [self.player1 play];
        [self.player2 play];
    }else {//播放中
        [self.player1 pause];
        [self.player2 pause];
        sender.selected = NO;
    }
}

#pragma mark - 叠合按钮点击
//叠合
- (void)topRightBtnClick:(UIButton *)sender
{
    [self changeBtnConstraints:sender];
    sender.selected = !sender.selected;
}

//改变pop1的位置
-(void)changeBtnConstraints:(UIButton *)sender
{
    if (sender.selected == NO) { //闭合了的状态
        //展开
        [self moveBtnIsOpenIngToPopBtnXDidMove:sender];
        
    }else if (sender.selected == YES) {//展开了的状态
        //闭合
        [self closeMoveBtn:sender];
    }
}

/**
 *  闭合按钮
 *
 *  @param moveBtn 移动的按钮
 */
-(void)closeMoveBtn:(UIButton *)moveBtn
{
    [UIView animateWithDuration:animationSec animations:^{
        self.pop1Btn.frame = moveBtn.frame;
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:animationSec  animations:^{
            self.pop2Btn.frame =  self.pop1Btn.frame;
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:animationSec animations:^{
                self.pop3Btn.frame = self.pop2Btn.frame;
            }];
        }];
        
    }];
}

/**
 *  展开按钮 并判断pop按钮在做还是右
 *
 *  @param sender 移动的按钮
 */
-(void)moveBtnIsOpenIngToPopBtnXDidMove:(UIButton *)moveBtn
{
    self.pop1Btn.alpha = 1.0f;
    if (moveBtn.sw_x >= SW_SCREEN_WIDTH/2) {//展开
        
        //先移动pop3
        [UIView animateWithDuration:animationSec animations:^{//动画1
            
            self.pop3Btn.frame = CGRectMake(moveBtn.sw_x - moveBtn.sw_width * 3 - 5*3 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
            
        } completion:^(BOOL finished) {
            
            //完成再移动pop2
            [UIView animateWithDuration:animationSec animations:^{//动画2
                
                self.pop2Btn.frame = CGRectMake(moveBtn.sw_x - moveBtn.sw_width*2 - 5*2 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
                
            } completion:^(BOOL finished) {
                //动画完成再移动pop1
                [UIView animateWithDuration:animationSec  animations:^{//动画3
                    self.pop1Btn.frame = CGRectMake(self.pop2Btn.sw_x + moveBtn.sw_width + 5 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
                }];
            }];
        }];
        
    }else {
        //先移动pop3
        [UIView animateWithDuration:animationSec animations:^{//1
            
            self.pop3Btn.frame = CGRectMake(CGRectGetMaxX(moveBtn.frame) + moveBtn.sw_width*2 + 5*3 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
            
        } completion:^(BOOL finished) {
            
            [UIView animateWithDuration:animationSec animations:^{//2
                //先移动pop2
                self.pop2Btn.frame = CGRectMake(CGRectGetMaxX(moveBtn.frame) + moveBtn.sw_width + 5*2 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
            } completion:^(BOOL finished) {
                //动画完成再移动pop1
                [UIView animateWithDuration:animationSec  animations:^{//3
                    self.pop1Btn.frame = CGRectMake(CGRectGetMaxX(moveBtn.frame) + 5 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
                }];
            }];
        }];
        
        
        
        
    }

}

#pragma mark - moveBtnDelegate
-(void)moveBtn:(SWMoveButton *)moveBtn didMoveTheX:(CGFloat)x theY:(CGFloat)y
{
    if (moveBtn.selected) {
        [self moveBtnIsOpenIngToPopBtnXDidMove:moveBtn];
    }else
    {
        [self closeMoveBtn:moveBtn];
    }
}

#pragma mark - popBtn点击事件:

-(void)popBtnClick:(UIButton *)popBtn
{
    switch (popBtn.tag) {
        case 0:
            //叠合视频
            [self pileUpVideo];
            break;
        case 1:
            NSLog(@"1");
            break;
        case 2:
            NSLog(@"2");
            break;
        default:
            break;
    }
}

#pragma mark - 叠合视频
/**
 *  叠合视频
 */
-(void)pileUpVideo
{
    
    if (self.player1 == nil && self.player2 == nil) {
        NSLog(@"return");
        return;
    }
    if (_isDoubleSreen == NO) {
        NSLog(@"是full");
        _isDoubleSreen = YES;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        //        [self.navigationController.navigationBar setBarTintColor:[UIColor blackColor]];
        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
        
        [self.view bringSubviewToFront:self.player1];
        [self.view bringSubviewToFront:self.player2];
        [self.view bringSubviewToFront:self.vcToolView];
        [self.view bringSubviewToFront:self.labelView];
        [self.view bringSubviewToFront:self.pop1Btn];
        [self.view bringSubviewToFront:self.pop2Btn];
        [self.view bringSubviewToFront:self.pop3Btn];
        [self.view bringSubviewToFront:self.topRightBtn];
        self.labelView.hidden = NO;
        self.labelView.alpha = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view);//.mas_offset( navHeight + statusHeight);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view);//.mas_offset( navHeight + statusHeight);
                
            }];
            
            self.labelView.alpha = 1;
            self.player2.alpha = 0.5f;
            [self hiddenPlayerSubViewsPlayer1:self.player1 andPlayer2:self.player2 hiddenSubViews:YES];
            
        }completion:^(BOOL finished) {
            self.player2.backgroundColor = [UIColor clearColor];
            self.player1.backgroundColor = [UIColor blackColor];
            
            
        }];
        
        [self.player1.timeSlider hidePopover];
        [self.player2.timeSlider hidePopover];
        
    }else
    {
        NSLog(@"不是full");
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        
        _isDoubleSreen = NO;
        self.player2.backgroundColor = [UIColor blackColor];
        self.player2.alpha = 1;
        [UIView animateWithDuration:0.25 animations:^{
            
            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.leading.trailing.mas_equalTo(self.player1View);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
                
            }];
            
            self.labelView.alpha = 0;
            [self hiddenPlayerSubViewsPlayer1:self.player1 andPlayer2:self.player2 hiddenSubViews:NO];
            
        }completion:^(BOOL finished) {
            self.labelView.hidden = YES;
        }];
        
        [self.player1.timeSlider showPopoverAnimated:YES];
        [self.player2.timeSlider showPopoverAnimated:YES];
        
    }

}

/**
 *  隐藏player的子view
 */
-(void)hiddenPlayerSubViewsPlayer1:(SWPlayer *)player1 andPlayer2:(SWPlayer *)player2 hiddenSubViews:(BOOL)hidden
{
    //播放按钮隐藏
    player1.playBtn.hidden = hidden;
    player2.playBtn.hidden = hidden;
    //View隐藏
//    player1.rangeView.hidden = hidden;
//    player2.rangeView.hidden = hidden;

    //timeSlider隐藏
    player1.timeSlider.hidden = hidden;
    player2.timeSlider.hidden = hidden;
    //标记隐藏
    player1.clockView.hidden = hidden;
    player2.clockView.hidden = hidden;
    
}

#pragma mark - 监听旋转
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    [self.player1.timeSlider hidePopover];
    [self.player2.timeSlider hidePopover];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        NSLog(@"home键靠右");
    }
    
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        NSLog(@"home键靠左");
    }
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        //
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //
    }
}

#pragma mark - dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"ViewController释放");
}

@end

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
const NSInteger maxRulerValue = 5555;//尺子长度
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
@property (nonatomic, strong) UIButton *pop4Btn;

/**
 *  是否横盘状态 yes为是
 */
@property (nonatomic, assign) BOOL isLandscapeLeftOrRight;

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
    self.vcToolView.hidden = YES;
    self.topRightBtn.hidden = YES;
    
    
//    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
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
    video1Label.text = @"底视频ONE :";
    video1Label.textColor = [UIColor whiteColor];
    [labelView addSubview:video1Label];
    self.video1Label = video1Label;
    [video1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(labelView).offset(10);
    }];
    [video1Label setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:18]];
    //label2
    UILabel *video2Label = [[UILabel alloc]init];
    video2Label.text = @"顶视频TWO :";
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
    [self.topRightBtn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateNormal];
    
    [self.topRightBtn setTitle:@"Closing" forState:UIControlStateNormal];
    [self.topRightBtn setTitle:@"Opening" forState:UIControlStateSelected];
    
    [self.topRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.topRightBtn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
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
    pop1Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [pop1Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop1Btn.layer.cornerRadius = 15;
    pop1Btn.layer.masksToBounds = YES;
    [self.view addSubview:pop1Btn];
    pop1Btn.tag = 0;
    pop1Btn.frame = self.topRightBtn.frame;
    self.pop1Btn = pop1Btn;
    [pop1Btn addTarget:self action:@selector(popBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *pop2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop2Btn setTitle:@"Video1" forState:UIControlStateNormal];
    pop2Btn.backgroundColor = [UIColor blueColor];
    [pop2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop2Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
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
    pop3Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    pop3Btn.layer.cornerRadius = 15;
    pop3Btn.layer.masksToBounds = YES;
    [self.view addSubview:pop3Btn];
    pop3Btn.tag = 2;
    self.pop3Btn = pop3Btn;
    pop3Btn.frame = pop1Btn.frame;
    [pop3Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *pop4Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop4Btn setTitle:@"复原" forState:UIControlStateNormal];
    pop4Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [pop4Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop4Btn.layer.cornerRadius = 15;
    pop4Btn.layer.masksToBounds = YES;
    pop4Btn.frame = pop3Btn.frame;
    self.pop4Btn = pop4Btn;
    [self.view addSubview:pop4Btn];
    pop4Btn.tag = 3;
    [pop4Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    pop2Btn.alpha = 0.8f;
    pop3Btn.alpha = 0.8f;
    pop1Btn.alpha = 0.8f;
    pop4Btn.alpha = 0.8f;
    
    [pop1Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop2Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop3Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop4Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    
    
    [pop1Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop2Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop3Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop4Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    
    self.topRightBtn.alpha = 0.8f;
    self.pop1Btn.hidden = YES;
    self.pop2Btn.hidden = YES;
    self.pop3Btn.hidden = YES;
    self.pop4Btn.hidden = YES;
}


/**
 *  navBarItem
 */
-(void)setUPNavBar
{
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navRightBtn setTitle:@"Push" forState:UIControlStateNormal];
    [navRightBtn addTarget:self action:@selector(navRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
    self.rulerView = [[TXHRrettyRuler alloc]initWithFrame:CGRectMake(0, 0, SW_SCREEN_WIDTH, 44)];
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
//    NSLog(@"拖动");
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
            self.vcToolView.hidden = YES;
            self.topRightBtn.hidden = YES;
            self.pop1Btn.hidden = YES;
            self.pop2Btn.hidden = YES;
            self.pop3Btn.hidden = YES;
            self.pop4Btn.hidden = YES;
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
    [self.view bringSubviewToFront:self.labelView];
    self.vcToolView.hidden = NO;
    self.topRightBtn.hidden = NO;
    self.pop1Btn.hidden = NO;
    self.pop2Btn.hidden = NO;
    self.pop3Btn.hidden = NO;
    self.pop4Btn.hidden = NO;
    [self bringThePOPButtonToFont];

}


#pragma mark - player播放监听代理
-(void)player:(SWPlayer *)player NotifCurrTimes:(CGFloat)times
{
    if (player.playerNumber == 1) {
        if (times < 10) {
            self.video1Label.text = [NSString stringWithFormat:@"底视频ONE : 0%.2f",times];
        }else{
            self.video1Label.text = [NSString stringWithFormat:@"底视频ONE : %.2f",times];
        }
    }else if (player.playerNumber == 2)
    {
        if (times < 10) {
            self.video2Label.text = [NSString stringWithFormat:@"顶视频TWO : 0%.2f",times];
        }else{
            self.video2Label.text = [NSString stringWithFormat:@"顶视频TWO : %.2f",times];
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

#pragma mark - 右上角POP菜单按钮点击
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

#pragma mark - popBtn点击事件:

-(void)popBtnClick:(UIButton *)popBtn
{
    
    //提示用户当前选择的哪个pop按钮
    [self selectPOPBtn:popBtn.tag];
    
    switch (popBtn.tag) {
        case 0:
            //叠合视频
            NSLog(@"popBtn1 : 叠合");
            [self pileUpVideo];
            break;
        case 1:
            NSLog(@"popBtn2 : video1");
            [self changeVideoPlayerToFont:self.player1 andView:self.player1View];
            break;
            
        case 2:
            NSLog(@"popBtn3 : video2");
            [self changeVideoPlayerToFont:self.player2 andView:self.player2View];
            break;
            
        case 3:
            NSLog(@"popBtn4 : 复原");
            [self recoverPlayer:self.player1 andView:self.player1View];
            [self recoverPlayer:self.player2 andView:self.player2View];
            
        default:
            break;
    }
    
    [self closeMoveBtn:self.topRightBtn];
    self.topRightBtn.selected = !self.topRightBtn.selected;
    
}
/**
 *  提示用户当前选择的哪个pop按钮
 *
 *  @param btnTag pop按钮的tag
 */
-(void)selectPOPBtn:(NSInteger)btnTag {
    switch (btnTag) {
        case 0:
            self.pop1Btn.selected = YES;
            self.pop2Btn.selected = NO;
            self.pop3Btn.selected = NO;
            self.pop4Btn.selected = NO;
            break;
            
        case 1:
            self.pop1Btn.selected = NO;
            self.pop2Btn.selected = YES;
            self.pop3Btn.selected = NO;
            self.pop4Btn.selected = NO;
            break;
           
        case 2:
            self.pop1Btn.selected = NO;
            self.pop2Btn.selected = NO;
            self.pop3Btn.selected = YES;
            self.pop4Btn.selected = NO;
            break;
            
        case 3:
            self.pop1Btn.selected = NO;
            self.pop2Btn.selected = NO;
            self.pop3Btn.selected = NO;
            self.pop4Btn.selected = YES;
            break;
        default:
            break;
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
            }completion:^(BOOL finished) {
                [UIView animateWithDuration:animationSec animations:^{
                    self.pop4Btn.frame = self.pop3Btn.frame;
                }];
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
    if (moveBtn.sw_x >= SW_SCREEN_WIDTH/2) {//展开
       [UIView animateWithDuration:animationSec animations:^{
           self.pop4Btn.frame =  CGRectMake(moveBtn.sw_x - moveBtn.sw_width * 4 - 5*4 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
       } completion:^(BOOL finished) {
           
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
       }];
        
    }else {
        
        [UIView animateWithDuration:animationSec animations:^{
            self.pop4Btn.frame = CGRectMake(CGRectGetMaxX(moveBtn.frame) + moveBtn.sw_width*3 + 5*4 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
        } completion:^(BOOL finished) {
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


#pragma mark - 复原player
-(void)recoverPlayer:(SWPlayer *)player andView:(UIView *)playerView
{
    if (player == nil) {
        NSLog(@"复原return了");
        return;
    }
    float anima = 0.25;
    player.playerIsFont = NO;//记录当前是否最前
    _isDoubleSreen = NO;//是否双屏
    if (_isLandscapeLeftOrRight == NO) {//如果不是横向的话 就显示navbar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    //复原
    [UIView animateWithDuration:anima animations:^{
        [player mas_remakeConstraints:^(MASConstraintMaker *make) {//缩小
            make.top.leading.trailing.bottom.mas_equalTo(playerView);
        }];
    }completion:^(BOOL finished) {
        player.alpha = 1;//透明度恢复
        player.backgroundColor = [UIColor blackColor];//底色
        [self hiddenPlayerSubViewsPlayer:player hiddenSubViews:NO];//不隐藏子view
        self.labelView.hidden = YES;
        [player.timeSlider hidePopover];
    }];
}


#pragma mark - 把player放最前
-(void)changeVideoPlayerToFont:(SWPlayer *)player andView:(UIView *)playerView
{
    if (player == nil) {
        NSLog(@"放最前return了");
        return;
    }
    float anima = 0.25;
    player.playerIsFont = YES;
    //隐藏navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    //放大放到最前
    [UIView animateWithDuration:anima animations:^{
        [player mas_remakeConstraints:^(MASConstraintMaker *make) {//放大
            make.leading.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.player1View);
            make.bottom.mas_equalTo(self.view).offset(-44);
        }];
    }completion:^(BOOL finished) {
        player.alpha = 1.0f;
        [self.view bringSubviewToFront:player];//奖视频view放最前
        [self hiddenPlayerSubViewsPlayer:player hiddenSubViews:NO];//不隐藏子View
        [self bringThePOPButtonToFont];//popBtn放最前
        [player.timeSlider hidePopover];
    }];
}

#pragma mark - 叠合视频
/**
 *  叠合视频
 */
-(void)pileUpVideo
{
    
    if (self.player1 == nil && self.player2 == nil) {
        NSLog(@"没有player - return");
        return;
    }
//    if (_isDoubleSreen == NO) {
        NSLog(@"是full");
        _isDoubleSreen = YES;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        [self.view bringSubviewToFront:self.player1];
        [self.view bringSubviewToFront:self.player2];
        [self.view bringSubviewToFront:self.vcToolView];
        [self.view bringSubviewToFront:self.labelView];
        
        [self bringThePOPButtonToFont];
        
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
            [self hiddenPlayerSubViewsPlayer:self.player1 hiddenSubViews:YES];
            [self hiddenPlayerSubViewsPlayer:self.player2 hiddenSubViews:YES];
            
        }completion:^(BOOL finished) {
            self.player2.backgroundColor = [UIColor clearColor];
            self.player1.backgroundColor = [UIColor blackColor];
        }];
        
        [self.player1.timeSlider hidePopover];
        [self.player2.timeSlider hidePopover];
    
    /*
     //一个按钮2件事情处理
//    }
//    else{
//        NSLog(@"不是full");
//        if (_isLandscapeLeftOrRight == NO) {//横屏状态的话
//            
//            [self.navigationController setNavigationBarHidden:NO animated:YES];
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
//        }
//        self.player1.playerIsFont = NO;
//        self.player2.playerIsFont = NO;
//        
//        _isDoubleSreen = NO;
//        self.player2.backgroundColor = [UIColor blackColor];
//        self.player2.alpha = 1;
//        [UIView animateWithDuration:0.25 animations:^{
//            
//            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.bottom.leading.trailing.mas_equalTo(self.player1View);
//            }];
//            
//            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
//                make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
//                
//            }];
//            
//            self.labelView.alpha = 0;
//            [self hiddenPlayerSubViewsPlayer:self.player1 hiddenSubViews:NO];
//            [self hiddenPlayerSubViewsPlayer:self.player2 hiddenSubViews:NO];
//            
//        }completion:^(BOOL finished) {
//            self.labelView.hidden = YES;
//        }];
//        
//        [self.player1.timeSlider showPopoverAnimated:YES];
//        [self.player2.timeSlider showPopoverAnimated:YES];
//    }
     */

}

/**
 *  将pop按钮拉倒上层
 */
-(void)bringThePOPButtonToFont
{
    [self.view bringSubviewToFront:self.pop1Btn];
    [self.view bringSubviewToFront:self.pop2Btn];
    [self.view bringSubviewToFront:self.pop3Btn];
    [self.view bringSubviewToFront:self.pop4Btn];
    [self.view bringSubviewToFront:self.topRightBtn];
}

/**
 *  隐藏player的子view
 */
-(void)hiddenPlayerSubViewsPlayer:(SWPlayer *)player hiddenSubViews:(BOOL)hidden
{
    //播放按钮隐藏
    player.playBtn.hidden = hidden;
    //timeSlider隐藏
    player.timeSlider.hidden = hidden;
    //标记隐藏
    player.clockView.hidden = hidden;
    //View隐藏
    //    player1.rangeView.hidden = hidden;
    //    player2.rangeView.hidden = hidden;
}

#pragma mark - 监听旋转
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    [self.player1.timeSlider hidePopover];
    [self.player2.timeSlider hidePopover];
    
    //cheak X和Y
    [self.topRightBtn moveTheBtnTheXYCheak];
    [self closeMoveBtn:self.topRightBtn];
    self.topRightBtn.selected = NO;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        NSLog(@"home键靠右");
        /**
         AVLayerVideoGravityResizeAspect        //  保持比例, 留黑边
         AVLayerVideoGravityResizeAspectFill    //  保持比例, 可能会有一不部分看不到
         AVLayerVideoGravityResize              // 填充全屏
         */
//        playerLayer.videoGravity =  AVLayerVideoGravityResizeAspect;
        self.player1.playerLayer.videoGravity = AVLayerVideoGravityResize;
        self.player2.playerLayer.videoGravity = AVLayerVideoGravityResize;
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        _isLandscapeLeftOrRight = YES;
    }
    
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        NSLog(@"home键靠左");
        self.player1.playerLayer.videoGravity = AVLayerVideoGravityResize;
        self.player2.playerLayer.videoGravity = AVLayerVideoGravityResize;
       
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        _isLandscapeLeftOrRight = YES;
    }
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        //
        NSLog(@"回复");
        if (_isDoubleSreen == NO && (self.player1.playerIsFont == NO && self.player2.playerIsFont  == NO)) {
        
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
        _isLandscapeLeftOrRight = NO;
        
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //
        NSLog(@"down");
    }
}

#pragma mark - dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    NSLog(@"ViewController释放");
}

@end

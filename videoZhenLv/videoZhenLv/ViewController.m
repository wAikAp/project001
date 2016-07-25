//
//  ViewController.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/8.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import "ViewController.h"
#import "SightPlayerViewController.h"
#import "SWPlayer.h"
#import "SWImagePlayer.h"
#import "SWMoivePlayer.h"

#import "Masonry.h"
#import "TXHRrettyRuler.h"
#import "NYSliderPopover.h"
#import "UIView+SWUtility.h"

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

const float CENTER_BUTTON_HEIGHT = 44;
const NSInteger maxRulerValue = 10000;

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,TXHRrettyRulerDelegate>


@property (nonatomic, strong)IBOutlet UIView *player1View;

@property (nonatomic, strong)IBOutlet UIView *player2View;

@property (nonatomic, strong) SWPlayer *player1;

@property (nonatomic, strong) SWPlayer *player2;


/**
 *  叠合按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *topRightBtn;
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

@property (nonatomic, assign) CGFloat ruleValue;

/**
 *  判断哪个按了添加 1和2
 */
@property (nonatomic, assign) CGFloat whichBtnNum;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.vcPlayBtn.layer.cornerRadius = 15;
    self.vcPlayBtn.layer.masksToBounds = YES;
//    尺子view
    [self setUPRulerView];
    
    //navBarItem
    [self setUPNavBar];

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
    
    [self.vcToolView addSubview:blurView];

    [blurView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.bottom.mas_equalTo(self.vcToolView);
    }];
    
    
    //尺子
    self.rulerView = [[TXHRrettyRuler alloc]initWithFrame:self.scrollTimeView.frame];
    [self.rulerView showRulerScrollViewWithCount:maxRulerValue average:[NSNumber numberWithFloat:1] currentValue:(maxRulerValue)/2 smallMode:NO];
    self.rulerView.rulerDeletate = self;
    [self.vcToolView addSubview:self.rulerView];

    self.rulerView.translatesAutoresizingMaskIntoConstraints = NO;
    self.rulerView.alpha = 0.7f;
    
    [self.rulerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.trailing.bottom.mas_equalTo(self.scrollTimeView);
    }];
    [self.vcToolView bringSubviewToFront:self.vcPlayBtn];
//    self.vcToolView.hidden = YES;
}


#pragma mark - 尺子拖动
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {

    NSLog(@"rulerScrollView.rulerValue = %f  rulerScrollView.count = %lu ",rulerScrollView.rulerValue,(unsigned long)rulerScrollView.rulerCount);
    
    self.vcPlayBtn.selected = NO;
    
    if (rulerScrollView.rulerValue == rulerScrollView.rulerCount) {
        NSLog(@"到点");
    }
    
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

- (IBAction)clickVideoBtn:(UIButton *)sender
{
    
    for (UIView *subView in self.view.subviews) {
        if ([subView isKindOfClass:[SWPlayer class]]) {
            [subView removeFromSuperview];
        }
    }
    self.player1View.backgroundColor = [UIColor grayColor];
}


#pragma mark - imagePicker回调
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    if (self.player1 == nil && self.whichBtnNum == 1) {
        SWPlayer *player1 = [[SWPlayer alloc]initWithFrame:self.player1View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];
        self.player1View.backgroundColor = [UIColor blackColor];
        self.player1 = player1;
        [self.view addSubview:player1];
        [player1 setPlayerDidPlayFinish:^{
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
        [player2 setPlayerDidPlayFinish:^{
            self.vcPlayBtn.selected = NO;
        }];
        player2.translatesAutoresizingMaskIntoConstraints = NO;
        [player2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
        }];
        
    }
    [self.view bringSubviewToFront:self.topRightBtn];
    [self.view bringSubviewToFront:self.vcToolView];
    self.vcToolView.hidden = NO;
    
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
- (IBAction)topRightBtnClick:(UIButton *)sender
{
    
    if (_isDoubleSreen == NO) {
        NSLog(@"是full");
        
        [UIApplication sharedApplication].statusBarHidden = NO;
        
        CGFloat navHeight = self.navigationController.navigationBar.sw_height;
        
        NSLog(@"navHight = %f",navHeight);
//        UIStatusBar
        
        CGRect statusFrame = [UIApplication sharedApplication].statusBarFrame;
        CGFloat statusHeight = statusFrame.size.height;
        NSLog(@"status height = %f",statusHeight);
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).mas_offset( navHeight + statusHeight);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).mas_offset( navHeight + statusHeight);
               
            }];
        }];
        
        self.player2.alpha = 0.5f;
        self.player2.backgroundColor = [UIColor clearColor];
        self.player1.backgroundColor = [UIColor blackColor];
        
        
        [self.view bringSubviewToFront:self.player1];
        [self.view bringSubviewToFront:self.player2];
        [self.view bringSubviewToFront:self.topRightBtn];
        [self.view bringSubviewToFront:self.vcToolView];
        _isDoubleSreen = YES;
        [self hiddenPlayerSubViewsPlayer1:self.player1 andPlayer2:self.player2 hiddenSubViews:YES];

    }else
    {
        NSLog(@"不是full");
        [UIView animateWithDuration:0.25 animations:^{
            
            self.player2.backgroundColor = [UIColor blackColor];
            
            
            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.leading.trailing.mas_equalTo(self.player1View);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
                
            }];
        }];
        
        self.player2.alpha = 1;
        _isDoubleSreen = NO;
        [self hiddenPlayerSubViewsPlayer1:self.player1 andPlayer2:self.player2 hiddenSubViews:NO];
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

    if (hidden) {
        [player1.timeSlider hidePopover];
        [player2.timeSlider hidePopover];
    }else
    {
        [player1.timeSlider showPopoverAnimated:YES];
        [player2.timeSlider showPopoverAnimated:YES];
    }
    //timeSlider隐藏
    player1.timeSlider.hidden = hidden;
    player2.timeSlider.hidden = hidden;
    //标记隐藏
    player1.clockBtn.hidden = hidden;
    player2.clockBtn.hidden = hidden;
    player1.clockLabel.hidden = hidden;
    player2.clockLabel.hidden = hidden;
}


- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}


@end

//
//  ViewController.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/8.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.


//my self
#import "SWContrastVideoPlayerController.h"
#import "SightPlayerViewController.h"
#import "SWPlayer.h"
#import "SWMoveButton.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

//第三方
#import "Masonry.h"
#import "TXHRrettyRuler.h"
#import "NYSliderPopover.h"
#import "UIView+SWUtility.h"
#import "SWDevelopmentTool.h"

const float CENTER_BUTTON_HEIGHT = 44;//按钮高度
const NSInteger maxRulerValue = 2222;//尺子长度

#define WINDOW [UIApplication sharedApplication].keyWindow

@interface SWContrastVideoPlayerController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,TXHRrettyRulerDelegate,SWPlayerDelegate , SWMoveButtonDelegate>

/**
 *  PlayerView1
 */
@property (nonatomic, strong)IBOutlet UIView *player1View;
/**
 *  PlayerView2
 */
@property (nonatomic, strong)IBOutlet UIView *player2View;
/**
 *  player1
 */
@property (nonatomic, strong) SWPlayer *player1;
/**
 *  player2
 */
@property (nonatomic, strong) SWPlayer *player2;
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
 *  添加视频1按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *addVideoOneBtn;
/**
 *  添加视频2按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *addVideoTwoBtn;
/**
 *  全屏时记录Video2label
 */
@property (nonatomic, strong) UILabel *video2Label;
/**
 *  装载label的view
 */
@property (nonatomic, strong) UIView *labelView;
/**
 *  右上浮动POP按钮
 */
@property (strong, nonatomic) SWMoveButton *topRightBtn;
/**
 *  是否横屏状态 yes为是
 */
@property (nonatomic, assign) BOOL isLandscapeLeftOrRight;
/**
 *  偏移按钮
 */
@property (nonatomic, strong) UIButton *pianYiBtn;
/**
 *  是否偏移
 */
@property (nonatomic, assign) BOOL isPianYi;
/**
 *  关闭叠合按钮
 */
@property (nonatomic, strong) UIButton *closeBtn;
/**
 *  nav右上角按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *navRightBtn;

@property (nonatomic, strong) UIButton *move;

@end

@implementation SWContrastVideoPlayerController

#pragma mark - ViewController生命周期
- (void)viewDidLoad
{
    [super viewDidLoad];
    //设置statusBar
    [self setUpStatusBar];
    //叠合按钮
    [self setUPTopRightBtn];
    //尺子view
    [self setUPRulerView];
    //label
    [self setUpVideoTimesLabel];
    //监听
    [self setUpNotifcation];
    
    self.vcToolView.hidden = YES;
    self.pianYiBtn.hidden = YES;
    
    [self.addVideoOneBtn setBackgroundImage:[UIImage imageNamed:@"AllBlack"] forState:UIControlStateHighlighted];
    [self.addVideoTwoBtn setBackgroundImage:[UIImage imageNamed:@"AllWhirt"] forState:UIControlStateHighlighted];
    
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.player1 || self.player2) {
        self.topRightBtn.hidden = NO;
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.topRightBtn.hidden = YES;
}


#pragma mark - SetUpUI
/**
 *  设置statusBar
 */
-(void)setUpStatusBar
{
    self.view.backgroundColor = [UIColor blackColor];
    self.vcPlayBtn.layer.cornerRadius = 15;
    self.vcPlayBtn.layer.masksToBounds = YES;
    //设置statusBar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    [self.navigationController.navigationBar setBackgroundColor:[UIColor blackColor]];
    self.title = @"鷹眼";
}


/**
 *  叠合按钮
 */
-(void)setUPTopRightBtn
{
    self.topRightBtn = [SWMoveButton SWMOveButtonOpeningTitle:@"OpenIng" CloseTitle:@"CloseIng" andPOPhTitle1:@"复原" title2:@"放大Video1" title3:@"放大Video2" title4:@"清除Video1" title5:@"清除Video2"];
    CGFloat btnWidth = 30;
    NSString * deviceType = [SWDevelopmentTool getDeviceType];
    if ([deviceType isEqualToString:@"iPad"]) {
        btnWidth *= 2;
        self.topRightBtn.frame = CGRectMake(btnWidth, btnWidth, btnWidth, btnWidth);
        
    }else{
        self.topRightBtn.frame = CGRectMake(btnWidth, btnWidth, btnWidth, btnWidth);
    }
    self.topRightBtn.moveButtonDelegate = self;
    self.topRightBtn.hidden = YES;
    [WINDOW addSubview:self.topRightBtn];
}


/**
 *  叠合状态下显示当前时间
 */
-(void)setUpVideoTimesLabel
{
    
    UIView *labelView = [[UIView alloc]init];
    [self.view addSubview:labelView];
    
    /**
     *  label1
     */
    UILabel *video1Label = [[UILabel alloc]init];
    video1Label.text = @"底视频ONE :";
    video1Label.textColor = [UIColor whiteColor];
    [labelView addSubview:video1Label];
    self.video1Label = video1Label;
    [video1Label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(labelView).offset(10);
    }];
    [video1Label setFont:[UIFont fontWithName:@"DBLCDTempBlack" size:18]];
    /**
     *  label2
     */
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
    
    /**
     *  偏移按钮
     */
    UIButton *pianYiBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pianYiBtn setTitle:@"偏移" forState:UIControlStateNormal];
    [pianYiBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [pianYiBtn setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:pianYiBtn];
    [pianYiBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.view).mas_offset(10);
        make.bottom.mas_equalTo(self.vcToolView.mas_top).mas_offset(-20);
        make.width.height.mas_equalTo(CENTER_BUTTON_HEIGHT);
    }];
    
    self.pianYiBtn = pianYiBtn;
    pianYiBtn.layer.cornerRadius = 15;
    pianYiBtn.layer.masksToBounds = YES;
    [pianYiBtn addTarget:self action:@selector(pianYiDidClick:) forControlEvents:UIControlEventTouchUpInside];
    
    /**
     *  关闭按钮
     */
    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [closeBtn setTitle:@"X" forState:UIControlStateNormal];
    [closeBtn setBackgroundColor:[UIColor whiteColor]];
    [closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    closeBtn.layer.cornerRadius = 20/2;
    closeBtn.layer.masksToBounds = YES;
    [self.view addSubview:closeBtn];
    [closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view).mas_offset(-20);
        make.top.mas_equalTo(self.labelView).mas_offset(20);
        make.width.height.mas_equalTo(20);
    }];
    
    [closeBtn addTarget:self action:@selector(closePileVideo:) forControlEvents:UIControlEventTouchUpInside];
    closeBtn.hidden = YES;
    self.closeBtn = closeBtn;
}


#pragma mark - setUp监听
-(void)setUpNotifcation
{
    //监听旋转
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(statusBarOrientationChange:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    //进入后台监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillInBackGround:) name:UIApplicationWillResignActiveNotification object:nil];
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
    [self.vcToolView bringSubviewToFront:self.vcPlayBtn];
    
}

#pragma mark - 尺子拖动
- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    
    //减去屏幕宽度的已移动多少宽度
    CGFloat contentOffSetWidth = rulerScrollView.contentSize.width - SW_SCREEN_WIDTH;
    
    if (rulerScrollView.contentOffset.x <= 0 || //到最左
        rulerScrollView.bounds.origin.x >= contentOffSetWidth)//到最右
    {
        NSLog(@"尺子到顶或底");
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


#pragma mark - 清空视频
/**
 *  隐藏pop按钮和工具条带动画
 */
-(void)hiddenPopBtnAndToolViewWithPlayer:(SWPlayer *)player
{
    [UIView animateWithDuration:0.25 animations:^{
        player.alpha = 0.0f;
    }completion:^(BOOL finished) {
        int playNum = player.playerNumber;
        if (playNum == 1) {
            
            self.player1 =nil;
            
        }else if ( playNum == 2)
        {
            self.player2 = nil;
        }
        [player removeFromSuperview];
        //都清除了的话
        if (self.player1 == nil && self.player2 == nil) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            
            [self.navRightBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            self.vcToolView.hidden = YES;
            self.topRightBtn.hidden = YES;
            self.closeBtn.hidden = YES;
            self.pianYiBtn.hidden = YES;
            self.labelView.hidden = YES;
        }
    }];
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
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"app不能获取相册权限" message:@"请在本机中设置本app的设置相册权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alertView show];
        return;
    }
    
    if (@available(iOS 11.0, *)) {//ios 11之后的判断
//       PHAuthorizationStatus  stauts = [PHPhotoLibrary authorizationStatus];
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
           
            if (status == PHAuthorizationStatusRestricted || status == PHAuthorizationStatusDenied) {
                NSLog(@"没有权限  = %ld",(long)status);
                dispatch_async(dispatch_get_main_queue(), ^{
                    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"不能获取相册权限" message:@"请在本机中设置本app的设置相册权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
                    [alertView show];
                    return;
                }) ;
                
            }else
            {
                NSLog(@"拿到权限");
                UIImagePickerController *pickController = [[UIImagePickerController alloc]init];
                pickController.delegate = self;
                pickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                //pickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
                pickController.view.backgroundColor = [UIColor whiteColor];
                pickController.mediaTypes =  [NSArray arrayWithObjects:@"public.movie", nil];
                pickController.allowsEditing = YES;
                
                pickController.videoQuality = UIImagePickerControllerQualityTypeHigh;
                
                [self presentViewController:pickController animated:YES completion:nil];
            }
        }];
    } else {//ios 11之前
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if (authStatus == AVAuthorizationStatusRestricted || authStatus ==AVAuthorizationStatusDenied)
        {
            //无权限
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@"不能获取相册权限" message:@"请在本机中设置本app的设置相册权限" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alertView show];
            return;
        }else
        {
            UIImagePickerController *pickController = [[UIImagePickerController alloc]init];
            pickController.delegate = self;
            pickController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            //pickController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            pickController.view.backgroundColor = [UIColor whiteColor];
            pickController.mediaTypes =  [NSArray arrayWithObjects:@"public.movie", nil];
            pickController.allowsEditing = YES;
            
            pickController.videoQuality = UIImagePickerControllerQualityTypeHigh;
            
            [self presentViewController:pickController animated:YES completion:nil];
        }
    }

    
}

#pragma mark - imagePicker回调
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    //防止block引用循环
    __weak typeof(self) weakSelf = self;
    if (self.player1 == nil && self.whichBtnNum == 1) {//playr1
        SWPlayer *player1 = [[SWPlayer alloc]initWithFrame:self.player1View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];//player1
        self.player1 = player1;
        player1.playerDelegate = self;
        player1.playerNumber = 1;//number
        [self.view addSubview:player1];
        [player1 setPlayerDidPlayFinish:^{//播放完成回调
            weakSelf.vcPlayBtn.selected = NO;
        }];
        
        [player1 setTapPlayerBlock:^{//tap回调
            [weakSelf.topRightBtn closeMoveBtn:weakSelf.topRightBtn];
        }];
        
        player1.translatesAutoresizingMaskIntoConstraints = NO;
        [player1 mas_makeConstraints:^(MASConstraintMaker *make) {//约束
            make.top.leading.bottom.trailing.mas_equalTo(weakSelf.player1View);
        }];
        
    }else if (self.player2 == nil && self.whichBtnNum == 2) {//player2
        SWPlayer *player2 = [[SWPlayer alloc]initWithFrame:self.player2View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];
        self.player2 = player2;
        [self.view addSubview:player2];
        player2.playerDelegate = self;
        player2.playerNumber = 2;
        [player2 setPlayerDidPlayFinish:^{//完成回调
            weakSelf.vcPlayBtn.selected = NO;
        }];
        
        [player2 setTapPlayerBlock:^{//tap回调
            [weakSelf.topRightBtn closeMoveBtn:weakSelf.topRightBtn];
        }];
        
        player2.translatesAutoresizingMaskIntoConstraints = NO;
        [player2 mas_makeConstraints:^(MASConstraintMaker *make) {//约束
            make.top.bottom.leading.trailing.mas_equalTo(weakSelf.player2View);
        }];
    }
    
    [self.view bringSubviewToFront:self.vcToolView];
    [self.view bringSubviewToFront:self.labelView];
    if (self.player1 && self.player2) {
        [self.navRightBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.topRightBtn.hidden = NO;
        self.vcToolView.hidden = NO;
    }
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

#pragma mark - 偏移点击
-(void)pianYiDidClick:(UIButton *)pianYiBtn
{
    if (self.player1 == nil && self.player2 == nil) {
        return;
    }
    __weak typeof(self) weakSelf = self;
    if (_isPianYi) {
        _isPianYi = NO;
        [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.leading.top.trailing.bottom.mas_equalTo(weakSelf.view);
        }];
        
    }else{
        _isPianYi = YES;
        [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(weakSelf.view);
            make.trailing.leading.mas_equalTo(weakSelf.view).mas_offset(30);
        }];
    }
}


#pragma mark - popBtn点击代理回调事件:
//pop子按钮点击事件
-(void)moveBtn:(SWMoveButton *)moveBtn didClickChildPopBtnWithTag:(NSInteger)tag
{
    switch (tag) {
        case 0:
            //叠合视频
//            NSLog(@"popBtn1 : 复原");
            [self recoverPlayer:self.player1 andView:self.player1View];
            [self recoverPlayer:self.player2 andView:self.player2View];
            self.closeBtn.hidden = YES;
            self.pianYiBtn.hidden = YES;
            [moveBtn.pop2Btn setTitle:@"放大Video1" forState:UIControlStateNormal];
            [moveBtn.pop3Btn setTitle:@"放大Video2" forState:UIControlStateNormal];
            break;
        case 1:
//            NSLog(@"popBtn2 : video1");
            if ( self.player1 == nil) {
                return;
            }
            if (self.player1.playerIsFont) {
                //复原
                [self recoverPlayer:self.player1 andView:self.player1View];
                [moveBtn.pop2Btn setTitle:@"放大Video1" forState:UIControlStateNormal];
            }else
            {
                //放最前
                [self changeVideoPlayerToFont:self.player1 andView:self.player1View];
                [moveBtn.pop2Btn setTitle:@"缩小Video1" forState:UIControlStateNormal];
            }
            
            break;
            
        case 2:
//            NSLog(@"popBtn3 : video2");
            if ( self.player2 == nil) {
                return;
            }
            if (self.player2.playerIsFont) {
                //复原
                [self recoverPlayer:self.player2 andView:self.player2View];
                [moveBtn.pop3Btn setTitle:@"放大Video2" forState:UIControlStateNormal];
            }else
            {
                //最前
                [self changeVideoPlayerToFont:self.player2 andView:self.player2View];
                [moveBtn.pop3Btn setTitle:@"缩小Video2" forState:UIControlStateNormal];
            }
            break;
            
        case 3:
//            NSLog(@"popBtn4 : clean1");
            if (self.player1 == nil) {return;}
            [self hiddenPopBtnAndToolViewWithPlayer:self.player1];
            break;
        case 4:
//            NSLog(@"popBtn5 :clean2");
            if (self.player2 == nil) {return;}
            [self hiddenPopBtnAndToolViewWithPlayer:self.player2];
            break;
        default:
            break;
    }
}


#pragma mark - 叠合视频按钮事件
- (IBAction)dieHeVideo:(UIButton *)sender {
    [self pileUpVideo];
}
//解除叠合
-(void)closePileVideo:(UIButton *)sender
{
    [self pileUpVideo];
}

#pragma mark - 截图
/**
 *  截图
 */
- (void)capScreenImage:(UIButton *)sender {
    UIImage *image = [self screenView:self.view];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
    imageView.frame = CGRectMake(100, 100, 300, 300);
    [self.view addSubview:imageView];
    
}


#pragma mark - 复原player
-(void)recoverPlayer:(SWPlayer *)player andView:(UIView *)playerView
{
    if (player == nil) {
        NSLog(@"复原时没有player%ld-return了",(long)player.playerNumber);
        return;
    }
    float animaTime = 0.25;
    player.playerIsFont = NO;//记录当前是否最前
    _isDoubleSreen = NO;//是否双屏
    if (_isLandscapeLeftOrRight == NO) {//如果不是横向的话 就显示navbar
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
    }
    //复原
    [UIView animateWithDuration:animaTime animations:^{
        [player mas_remakeConstraints:^(MASConstraintMaker *make) {//缩小
            make.top.leading.trailing.bottom.mas_equalTo(playerView);
        }];
    }completion:^(BOOL finished) {
        player.alpha = 1;//透明度恢复
        player.backgroundColor = [UIColor blackColor];//底色
        [self hiddenPlayerSubViewsPlayer:player hiddenSubViews:NO];//不隐藏子view
        self.labelView.hidden = YES;
    }];
}


#pragma mark - 把player放最前
/**
 *  把player放最前
 *
 *  @param player     player
 *  @param playerView 约束依赖的view
 */
-(void)changeVideoPlayerToFont:(SWPlayer *)player andView:(UIView *)playerView
{
    if (player == nil) {
        return;
    }
    float animaTime = 0.25;
    player.playerIsFont = YES;
    //隐藏navbar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    //放大放到最前
    [UIView animateWithDuration:animaTime animations:^{
        [player mas_remakeConstraints:^(MASConstraintMaker *make) {//放大
            make.leading.trailing.mas_equalTo(self.view);
            make.top.mas_equalTo(self.player1View);
            make.bottom.mas_equalTo(self.view).offset(-44);
        }];
    }completion:^(BOOL finished) {
        player.alpha = 1.0f;
        player.backgroundColor = [UIColor blackColor];
        [self.view bringSubviewToFront:player];//奖视频view放最前
        [self hiddenPlayerSubViewsPlayer:player hiddenSubViews:NO];//不隐藏子View
    }];
    
    /**
     AVLayerVideoGravityResizeAspect        //  保持比例, 留黑边
     AVLayerVideoGravityResizeAspectFill    //  保持比例, 可能会有一不部分看不到
     AVLayerVideoGravityResize              // 填充全屏
     */
//    player.playerLayer.videoGravity = AVLayerVideoGravityResize;
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
    }else if (self.player1 == nil || self.player2 == nil)
    {
        return;
    }

    if (_isDoubleSreen == NO) {
        //叠合
        _isDoubleSreen = YES;
        
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
        
        [self.view bringSubviewToFront:self.player1];
        [self.view bringSubviewToFront:self.player2];
        [self.view bringSubviewToFront:self.vcToolView];
        [self.view bringSubviewToFront:self.labelView];
        [self.view bringSubviewToFront:self.pianYiBtn];
        [self.view bringSubviewToFront:self.closeBtn];
        self.pianYiBtn.hidden = NO;
        self.closeBtn.hidden = NO;
        self.labelView.hidden = NO;
        self.pianYiBtn.alpha = 0;
        self.closeBtn.alpha = 0;
        self.labelView.alpha = 0;
        
        [UIView animateWithDuration:0.25 animations:^{
            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.trailing.bottom.mas_equalTo(self.view);
                make.leading.mas_equalTo(self.view).mas_offset(0);
                
            }];
    
            if (self.player1.timeSlider.value < 10) {
                
                self.video1Label.text = [NSString stringWithFormat:@"底视频ONE : 0%.2f",self.player1.timeSlider.value];
            }else
            {
                self.video1Label.text = [NSString stringWithFormat:@"底视频ONE : %.2f",self.player1.timeSlider.value];
            }
            if (self.player1.timeSlider.value < 10) {
                
                self.video2Label.text = [NSString stringWithFormat:@"底视频TWO : 0%.2f",self.player2.timeSlider.value];
            }else
            {
                self.video2Label.text = [NSString stringWithFormat:@"底视频TWO : %.2f",self.player2.timeSlider.value];
            }
            
            self.labelView.alpha = 1;
            self.pianYiBtn.alpha = 1;
            self.closeBtn.alpha = 1;
            self.player2.alpha = 0.66f;
            [self hiddenPlayerSubViewsPlayer:self.player1 hiddenSubViews:YES];
            [self hiddenPlayerSubViewsPlayer:self.player2 hiddenSubViews:YES];
            
        }completion:^(BOOL finished) {
            self.player2.backgroundColor = [UIColor clearColor];
            self.player1.backgroundColor = [UIColor blackColor];
        }];
    }else{//一个按钮2件事情处理
        //分屏
        if (_isLandscapeLeftOrRight == NO) {//横屏状态的话
            
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }
        self.player1.playerIsFont = NO;
        self.player2.playerIsFont = NO;
        self.player1.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        self.player2.playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
        
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
            self.closeBtn.alpha = 0;
            [self hiddenPlayerSubViewsPlayer:self.player1 hiddenSubViews:NO];
            [self hiddenPlayerSubViewsPlayer:self.player2 hiddenSubViews:NO];
            
        }completion:^(BOOL finished) {
            self.labelView.hidden = YES;
            self.pianYiBtn.hidden = YES;
            self.closeBtn.hidden = YES;
        }];
    }
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
    //尺子隐藏
    player.rulerView.hidden = hidden;
}

#pragma mark - 监听旋转
- (void)statusBarOrientationChange:(NSNotification *)notification
{
    //cheak X和Y
    [self.topRightBtn moveTheBtnTheXYCheak];
    [self.topRightBtn closeMoveBtn:self.topRightBtn];
    self.topRightBtn.selected = NO;
    
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    if (orientation == UIInterfaceOrientationLandscapeRight) // home键靠右
    {
        //        NSLog(@"home键靠右");
        [self screenLandsCapeLeftOrRight];
    }
    
    if (
        orientation ==UIInterfaceOrientationLandscapeLeft) // home键靠左
    {
        //        NSLog(@"home键靠左");
        [self screenLandsCapeLeftOrRight];
    }
    
    if (orientation == UIInterfaceOrientationPortrait)
    {
        //        NSLog(@"恢复");
        if (_isDoubleSreen == NO && (self.player1.playerIsFont == NO && self.player2.playerIsFont  == NO)) {
        
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
        }else if((self.player1 && self.player2 ==nil) || (self.player2 && self.player1 == nil))
        {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [[UIApplication sharedApplication]setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
            [self recoverPlayer:self.player2 andView:self.player2View];
            [self recoverPlayer:self.player1 andView:self.player1View];
        }
        _isLandscapeLeftOrRight = NO;
        
    }
    
    if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //        NSLog(@"down");
    }
}

/**
 *  旋转为左右时
 */
-(void)screenLandsCapeLeftOrRight{
    //隐藏nav
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[UIApplication sharedApplication]setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    _isLandscapeLeftOrRight = YES;
    
    if (self.player1 == nil && self.player2 != nil ) {
        //player1为空 player2全屏
        [self changeVideoPlayerToFont:self.player2 andView:self.view];
        
    }else if ( self.player2 == nil && self.player1 != nil)
    {
        //player2为空 Player1全屏
        [self changeVideoPlayerToFont:self.player1 andView:self.view];
    }
}


#pragma mark - 进入后台通知
-(void)appWillInBackGround:(NSNotification *)notif
{
    if (self.player1) {
        [self.player1 pause];
    }
    
    if (self.player2) {
        [self.player2 pause];
    }
    self.vcPlayBtn.selected = NO;
}

/**
 *  截屏
 */
- (UIImage*)screenView:(UIView *)view{
    
    CGSize size = view.bounds.size;
    
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    
    CGRect rec = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.bounds.size.width, view.bounds.size.height);
    [view drawViewHierarchyInRect:rec afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark - dealloc
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

@end

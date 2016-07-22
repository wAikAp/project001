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

#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>

const float CENTER_BUTTON_HEIGHT = 44;
const int maxRulerValue = 10000;

@interface ViewController () <UIImagePickerControllerDelegate,UINavigationControllerDelegate,TXHRrettyRulerDelegate>

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong)IBOutlet UIView *player1View;
@property (nonatomic, strong)IBOutlet UIView *player2View;

@property (nonatomic, strong) SWPlayer *player1;
@property (nonatomic, strong) SWPlayer *player2;


@property (nonatomic, strong) UISlider *vcTimeSlider;

@property (nonatomic, assign) CGFloat lastTimeValue;

@property (nonatomic, assign) int testNum;

@property (weak, nonatomic) IBOutlet UIButton *topRightBtn;
/**
 *  叠合状态
 */
@property (nonatomic, assign) BOOL isDoubleSreen;

@property (weak, nonatomic) IBOutlet UIButton *vcPlayBtn;
@property (weak, nonatomic) IBOutlet UIView *scrollTimeView;
@property (weak, nonatomic) IBOutlet UIView *vcToolView;

@property (nonatomic, strong) TXHRrettyRuler *rulerView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.vcPlayBtn.layer.cornerRadius = 15;
    self.vcPlayBtn.layer.masksToBounds = YES;
    self.scrollTimeView.layer.cornerRadius = 15;
    self.scrollTimeView.layer.masksToBounds = YES;
    
    self.rulerView = [[TXHRrettyRuler alloc]initWithFrame:self.scrollTimeView.frame];
    [self.rulerView showRulerScrollViewWithCount:maxRulerValue average:[NSNumber numberWithFloat:0.1] currentValue:(maxRulerValue*0.1f)/2 smallMode:NO];
    self.rulerView.rulerDeletate = self;
    [self.vcToolView addSubview:self.rulerView];
    self.rulerView.layer.cornerRadius = 15;
    self.rulerView.layer.masksToBounds = YES;
    
    
    //navBarItem
    UIButton *navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [navRightBtn setTitle:@"单独" forState:UIControlStateNormal];
    [navRightBtn addTarget:self action:@selector(navRightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [navRightBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    navRightBtn.frame = CGRectMake(0, 0, 60, 60);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:navRightBtn];
}


- (void)txhRrettyRuler:(TXHRulerScrollView *)rulerScrollView {
    NSLog(@"拖动~");
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
    
    [self openThePickerController];
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    //1.
    if (self.player1 == nil) {
        SWPlayer *player1 = [[SWPlayer alloc]initWithFrame:self.player1View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];
        self.player1 = player1;
        [self.view addSubview:player1];
        player1.translatesAutoresizingMaskIntoConstraints = NO;
        [player1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.leading.bottom.trailing.mas_equalTo(self.player1View);
        }];
        
    }else if (self.player2 == nil) {
        SWPlayer *player2 = [[SWPlayer alloc]initWithFrame:self.player2View.frame vidoURLStr:info[UIImagePickerControllerMediaURL]];
        self.player2 = player2;
        [self.view addSubview:player2];
        player2.translatesAutoresizingMaskIntoConstraints = NO;
        [player2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
        }];
        
    }
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
- (IBAction)addVideoPlayerOne:(UIButton *)sender
{
    self.player1 = nil;
    [self openThePickerController];
}

- (IBAction)addVideoPlayerTwo:(UIButton *)sender
{
    self.player2 = nil;
    [self openThePickerController];
}

/**
 *  开启图库
 */
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


//叠合
- (IBAction)topRightBtnClick:(UIButton *)sender
{
    
    if (_isDoubleSreen == NO) {
        NSLog(@"是full");
        [UIView animateWithDuration:0.25 animations:^{

            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).mas_offset( 64);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.bottom.mas_equalTo(self.view);
                make.top.mas_equalTo(self.view).mas_offset( 64);
               
            }];
            [self hiddenPlayerSubViewsPlayer1:self.player1 andPlayer2:self.player2 hiddenSubViews:YES];
        }];
        
        self.player2.alpha = 0.5f;
        self.player2.backgroundColor = [UIColor clearColor];
        self.player1.backgroundColor = [UIColor blackColor];
        
        
        [self.view bringSubviewToFront:self.player1];
        [self.view bringSubviewToFront:self.player2];
        [self.view bringSubviewToFront:self.topRightBtn];
        [self.view bringSubviewToFront:self.vcToolView];
        _isDoubleSreen = YES;
    }else
    {
        NSLog(@"不是full");
        [UIView animateWithDuration:0.25 animations:^{
            
            self.player2.backgroundColor = [UIColor blackColor];
            self.player2.alpha = 1;
            
            [self.player1 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.leading.trailing.mas_equalTo(self.player1View);
            }];
            
            [self.player2 mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.bottom.leading.trailing.mas_equalTo(self.player2View);
                
            }];
        [self hiddenPlayerSubViewsPlayer1:self.player1 andPlayer2:self.player2 hiddenSubViews:NO];
        }];
        
        _isDoubleSreen = NO;
        
        
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
    player1.rangeView.hidden = hidden;
    player2.rangeView.hidden = hidden;
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

//
//  SWMoveButton.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/26.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import "SWMoveButton.h"
#import "Masonry.h"
#import "UIView+SWUtility.h"

CGFloat const marring = 5;
CGFloat const navbarHeight = 64;
const float animationSec = 0.1f;//按钮动画时间

@interface SWMoveButton()

@property (nonatomic, strong) UIPanGestureRecognizer *pan;
/**
 *  叠合按钮
 *  pop1
 */
@property (nonatomic, strong) UIButton *pop1Btn;
/**
 *  pop2
 */
@property (nonatomic, strong) UIButton *pop2Btn;
/**
 *  pop3
 */
@property (nonatomic, strong) UIButton *pop3Btn;
/**
 *  pop4
 */
@property (nonatomic, strong) UIButton *pop4Btn;
/**
 *  pop5
 */
@property (nonatomic, strong) UIButton *pop5Btn;

@property (nonatomic, strong) UIButton *lastBtn;

@end

@implementation SWMoveButton

-(void)setHighlighted:(BOOL)highlighted{}//取消高亮


-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self setThePan];
        
    }
    return self;
}

-(instancetype)init
{
    if (self = [super init]) {
        [self setThePan];
        
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        
        [self setThePan];
    }
    return self;
}

/**
 *  初始化
 */
+(instancetype)SWMOveButton
{
    SWMoveButton *btn = [super buttonWithType:UIButtonTypeCustom];
    [btn setThePan];
    [btn addTarget:btn action:@selector(topRightBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;//文字水平居中
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;//垂直
    btn.titleLabel.numberOfLines = 0;
    [btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateNormal];
    
    [btn setTitle:@"Closing" forState:UIControlStateNormal];
    [btn setTitle:@"Opening" forState:UIControlStateSelected];
    
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    btn.selected = NO;
    btn.layer.cornerRadius = 15;
    btn.layer.masksToBounds = YES;
    [btn setUpChildPopBtn];
    return btn;
}



#pragma mark - 手势
-(void)setThePan
{
    if (self.pan == nil) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panSelf:)];
        [self addGestureRecognizer:pan];
        self.pan = pan;
    }
}

/**
 *  设置子POP按钮
 */
-(void)setUpChildPopBtn
{
    UIButton *pop1Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop1Btn setTitle:@"复原" forState:UIControlStateNormal];
    pop1Btn.backgroundColor = [UIColor redColor];
    pop1Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [pop1Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop1Btn.layer.cornerRadius = 15;
    pop1Btn.layer.masksToBounds = YES;
    
    pop1Btn.tag = 0;
    pop1Btn.frame = self.frame;
    self.pop1Btn = pop1Btn;
    [pop1Btn addTarget:self action:@selector(popBtnClick:) forControlEvents: UIControlEventTouchUpInside];
    
    UIButton *pop2Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop2Btn setTitle:@"放大V1" forState:UIControlStateNormal];
    pop2Btn.backgroundColor = [UIColor blueColor];
    [pop2Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop2Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    pop2Btn.layer.cornerRadius = 15;
    pop2Btn.layer.masksToBounds = YES;
    
    pop2Btn.tag = 1;
    self.pop2Btn = pop2Btn;
    pop2Btn.frame = pop1Btn.frame;
    [pop2Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pop3Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop3Btn setTitle:@"放大V2" forState:UIControlStateNormal];
    [pop3Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop3Btn.backgroundColor = [UIColor whiteColor];
    pop3Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    pop3Btn.layer.cornerRadius = 15;
    pop3Btn.layer.masksToBounds = YES;
    
    pop3Btn.tag = 2;
    self.pop3Btn = pop3Btn;
    pop3Btn.frame = pop1Btn.frame;
    [pop3Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pop4Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop4Btn setTitle:@"清除V1" forState:UIControlStateNormal];
    pop4Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [pop4Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop4Btn.layer.cornerRadius = 15;
    pop4Btn.layer.masksToBounds = YES;
    pop4Btn.frame = pop3Btn.frame;
    self.pop4Btn = pop4Btn;
    
    pop4Btn.tag = 3;
    [pop4Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *pop5Btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [pop5Btn setTitle:@"清除V2" forState:UIControlStateNormal];
    pop5Btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [pop5Btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    pop5Btn.layer.cornerRadius = 15;
    pop5Btn.layer.masksToBounds = YES;
    pop5Btn.frame = pop4Btn.frame;
    self.pop5Btn = pop5Btn;
    pop5Btn.tag = 4;
    [pop5Btn addTarget:self action:@selector(popBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [pop1Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop2Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop3Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop4Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    [pop5Btn setBackgroundImage:[UIImage imageNamed:@"mao2"] forState:UIControlStateNormal];
    
    
    [pop1Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop2Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop3Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop4Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    [pop5Btn setBackgroundImage:[UIImage imageNamed:@"mao3"] forState:UIControlStateSelected];
    self.hidden = YES;
}

-(void)didMoveToSuperview
{
    [super didMoveToSuperview];
    self.alpha = 0.88f;
    [self.superview  addSubview:self.pop1Btn];
    [self.superview  addSubview:self.pop2Btn];
    [self.superview  addSubview:self.pop3Btn];
    [self.superview  addSubview:self.pop4Btn];
    [self.superview  addSubview:self.pop5Btn];
    self.pop1Btn.frame = self.frame;
    self.pop2Btn.frame = self.frame;
    self.pop3Btn.frame = self.frame;
    self.pop4Btn.frame = self.frame;
    self.pop5Btn.frame = self.frame;
    [self.superview bringSubviewToFront:self];
}

/**
 *  POP子按钮点击
 */
-(void)popBtnClick:(UIButton *)popBtn
{
    //提示用户当前选中哪个pop按钮
    self.lastBtn.selected = NO;
    popBtn.selected = !popBtn.selected;
    self.lastBtn = popBtn;
    //执行代理
    if ([self.moveButtonDelegate respondsToSelector:@selector(moveBtn:didClickChildPopBtnWithTag:)]) {
        [self.moveButtonDelegate moveBtn:self didClickChildPopBtnWithTag:popBtn.tag];
    }
    //关闭按钮
    [self closeMoveBtn:self];
}

//self点击
- (void)topRightBtnClick:(UIButton *)sender
{
    [self changeBtnConstraints:sender];
}

//改变pop1的位置
-(void)changeBtnConstraints:(UIButton *)sender
{
    if (sender.selected == NO) { //闭合了的状态
        //展开
        [self moveBtnIsOpenIngToPopBtnXDidMove:sender];
        sender.selected = YES;
        
    }else if (sender.selected == YES) {//展开了的状态
        //闭合
        [self closeMoveBtn:sender];
        sender.selected = NO;
    }
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
            if (moveBtn.sw_x - moveBtn.sw_width * 5 - 5*5 < 0) {
                //如果x比0还小就换行
                self.pop5Btn.frame = CGRectMake(moveBtn.sw_x - moveBtn.sw_width * 4 - 5*4, moveBtn.sw_y + moveBtn.sw_width + 5, moveBtn.sw_width, moveBtn.sw_height);
            }else
            {
                self.pop5Btn.frame =  CGRectMake(moveBtn.sw_x - moveBtn.sw_width * 5 - 5*5 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
            }
            
        }completion:^(BOOL finished) {
            
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
        }];
    }else {
        
        [UIView animateWithDuration:animationSec animations:^{
            if (CGRectGetMaxX(moveBtn.frame) + moveBtn.sw_width*4 + 5*5 >= SW_SCREEN_WIDTH - moveBtn.sw_width) {
                //换行
                self.pop5Btn.frame = CGRectMake(CGRectGetMaxX(moveBtn.frame) + moveBtn.sw_width*3 + 5*4 , moveBtn.sw_y + moveBtn.sw_width + 5, moveBtn.sw_width, moveBtn.sw_height);
                
            }else{
                self.pop5Btn.frame = CGRectMake(CGRectGetMaxX(moveBtn.frame) + moveBtn.sw_width*4 + 5*5 , moveBtn.sw_y, moveBtn.sw_width, moveBtn.sw_height);
            }
            
        } completion:^(BOOL finished) {
            
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
        }];
    }
}


/**
 *  闭合按钮
 *
 *  @param moveBtn 移动的按钮
 */
-(void)closeMoveBtn:(UIButton *)moveBtn
{
    moveBtn.selected = NO;
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
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:animationSec animations:^{
                        self.pop5Btn.frame = self.pop4Btn.frame;
                    }];
                }];
            }];
        }];
    }];
}

//检查坐标
-(void)moveTheBtnTheXYCheak
{
    [self moveTheButtonCheakFrame];
}

-(void)panSelf:(UIPanGestureRecognizer *)pan
{
    if (pan.state == UIGestureRecognizerStateChanged) {
        
        CGPoint curP = [pan locationInView:self.superview];
        self.center = curP;
    }
    
    if (pan.state == UIGestureRecognizerStateEnded ) {
        [self moveTheButtonCheakFrame];
    }
    //触发代理
    if ([self.moveButtonDelegate respondsToSelector:@selector(moveBtn:didMoveTheX:theY:)]) {
        [self.moveButtonDelegate moveBtn:self didMoveTheX:self.frame.origin.x theY:self.frame.origin.y];
    }
    if (self.selected) {//打开状态
        [self moveBtnIsOpenIngToPopBtnXDidMove:self];
    }else
    {//闭合
        [self closeMoveBtn:self];
    }
}

/**
 *  父控件的x检测
 */
-(void)moveTheButtonCheakFrame {
    
    [UIView animateWithDuration:0.25 animations:^{
        //            NSLog(@"frame y = %f",self.sw_y);
        if (self.frame.origin.x >= SW_SCREEN_WIDTH / 2) {//x大于屏幕一半
            //                NSLog(@"x大于屏幕一半");
            self.sw_x = SW_SCREEN_WIDTH - self.sw_width - marring;
        }
        if (self.frame.origin.x <= SW_SCREEN_WIDTH / 2) {//x小于屏幕一半
            //                NSLog(@"x小于屏幕一半");
            self.sw_x = marring;
        }
        if (self.frame.origin.y >= SW_SCREEN_HEIGHT - self.sw_height) {//y大于屏幕
            //                NSLog(@"y大于屏幕");
            self.sw_y = SW_SCREEN_HEIGHT - self.sw_height - marring;
        }
        if (self.frame.origin.y <= 0) {//y小于屏幕
            //                NSLog(@"y小于屏幕");
            self.sw_y = marring + 0;
        }
    }];
}

-(void)setAlpha:(CGFloat)alpha
{
    [UIView animateWithDuration:0.25 animations:^{
        
        self.pop1Btn.alpha = alpha;
        self.pop2Btn.alpha = alpha;
        self.pop3Btn.alpha = alpha;
        self.pop4Btn.alpha = alpha;
        self.pop5Btn.alpha = alpha;
        [super setAlpha:alpha];
    }];
}

-(void)setHidden:(BOOL)hidden
{
    [UIView animateWithDuration:0.25 animations:^{
        self.alpha = !hidden;
    }completion:^(BOOL finished) {
        [super setHidden:hidden];
        self.pop1Btn.hidden = hidden;
        self.pop2Btn.hidden = hidden;
        self.pop3Btn.hidden = hidden;
        self.pop4Btn.hidden = hidden;
        self.pop5Btn.hidden = hidden;
    }];
}


@end

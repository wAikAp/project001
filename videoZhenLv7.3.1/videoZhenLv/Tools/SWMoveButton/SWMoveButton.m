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


@interface SWMoveButton()

@property (nonatomic, strong) UIPanGestureRecognizer *pan;

@property (nonatomic, strong) UIButton *pop1Btn;

@end

@implementation SWMoveButton

-(void)setHighlighted:(BOOL)highlighted{}//取消高亮

+(instancetype)buttonWithType:(UIButtonType)buttonType
{
    SWMoveButton *btn = [super buttonWithType:buttonType];
    [btn setThePan];
    return btn;
}

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
//        self = [super butt];
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

#pragma mark - 手势
-(void)setThePan
{
    if (self.pan == nil) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panSelf:)];
        [self addGestureRecognizer:pan];
        self.pan = pan;
        
    }
}


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
}

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
        if (self.frame.origin.y >= SW_SCREEN_HEIGHT - navbarHeight) {//y大于屏幕
            //                NSLog(@"y大于屏幕");
            self.sw_y = SW_SCREEN_HEIGHT - self.sw_height - marring;
        }
        if (self.frame.origin.y <= navbarHeight) {//y小于屏幕
            //                NSLog(@"y小于屏幕");
            self.sw_y = marring + navbarHeight;
        }
    }];
}



@end

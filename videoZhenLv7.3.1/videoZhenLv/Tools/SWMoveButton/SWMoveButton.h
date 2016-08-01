//
//  SWMoveButton.h
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/26.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SWMoveButton;
@protocol SWMoveButtonDelegate <NSObject>

-(void)moveBtn:(SWMoveButton *)moveBtn didMoveTheX:(CGFloat)x theY:(CGFloat)y;

@end

@interface SWMoveButton : UIButton

@property (nonatomic, weak) id<SWMoveButtonDelegate> moveButtonDelegate;

-(void)moveTheBtnTheXYCheak;
@end

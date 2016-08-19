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

@optional;
-(void)moveBtn:(SWMoveButton *)moveBtn didClickChildPopBtnWithTag:(NSInteger)tag;

@optional;
-(void)moveBtn:(SWMoveButton *)moveBtn didMoveTheX:(CGFloat)x theY:(CGFloat)y;


@end

@interface SWMoveButton : UIButton


+(instancetype)SWMOveButton;

@property (nonatomic, weak) id<SWMoveButtonDelegate> moveButtonDelegate;
/**
 *  关闭按钮
 *
 *  @param moveBtn 自己
 */
-(void)closeMoveBtn:(UIButton *)moveBtn;
/**
 *  检查坐标
 */
-(void)moveTheBtnTheXYCheak;

@end

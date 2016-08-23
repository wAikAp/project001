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

/**
 *  点击回调 tag代表第几个POP按钮
 */
@optional;
-(void)moveBtn:(SWMoveButton *)moveBtn didClickChildPopBtnWithTag:(NSInteger)tag;

/**
 *  一移动就回用
 */
@optional;
-(void)moveBtn:(SWMoveButton *)moveBtn didMoveTheX:(CGFloat)x theY:(CGFloat)y;


@end

@interface SWMoveButton : UIButton

/**
 *  初始化
 *  只能通过此类方法创建对象
 *
 *  @param openTitle  开启时的title
 *  @param closeTitle 关闭时的title
 *
 *  @param title1 最靠近母Button的为第1个 tag = 0
 *  @param title2 第2个                 tag = 1
 *  @param title3 第3个                 tag = 2
 *  @param title4 第4个                 tag = 3
 *  @param title5 第5个                 tag = 4
 *
 *  @return
 */
+(instancetype)SWMOveButtonOpeningTitle:(NSString *)openTitle CloseTitle:(NSString *)closeTitle andPOPhTitle1:(NSString *)title1 title2:(NSString *)title2 title3:(NSString *)title3 title4:(NSString *)title4 title5:(NSString *)title5;
/**
 *  关闭按钮
 *
 *  @param moveBtn 自己
 */
-(void)closeMoveBtn:(UIButton *)moveBtn;

/**
 *  检查坐标 依靠屏幕左右两边
 */
-(void)moveTheBtnTheXYCheak;

/**
 *  代理
 */
@property (nonatomic, weak) id<SWMoveButtonDelegate> moveButtonDelegate;

@end

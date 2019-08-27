//
//  SWMoivePlayer.h
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/13.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWMoivePlayer : UIView

-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr;
-(void)play ;
@end

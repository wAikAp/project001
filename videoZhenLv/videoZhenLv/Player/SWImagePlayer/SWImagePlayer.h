//
//  SWImagePlayer.h
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/12.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWImagePlayer : UIView


@property (nonatomic, strong) UIImageView *imageView;
-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr;
@end

//
//  sightPlayerViewController.h
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/22.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SightPlayerViewController : UIViewController

/**
 *  控制器释放block
 */
@property (nonatomic, copy) void (^deallocBlock)();

@end

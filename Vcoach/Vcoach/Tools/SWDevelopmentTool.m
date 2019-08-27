//
//  SWDevelopmentTool.m
//  Vcoach
//
//  Created by shingwai chan on 2018/1/30.
//  Copyright © 2018年 ShingWai帅威. All rights reserved.
//

#import "SWDevelopmentTool.h"
#import <UIKit/UIKit.h>

@implementation SWDevelopmentTool


+ (NSString *)getDeviceType

{
    NSString *deviceType = [UIDevice currentDevice].model;
    if([deviceType isEqualToString:@"iPhone"]) {
        
        //iPhone
        return @"iPhone";
        
    }
    else if([deviceType isEqualToString:@"iPod touch"]) {
        
        //iPod Touch
        return @"iPod touch";
        
    }
    else if([deviceType isEqualToString:@"iPad"]) {
        
        //iPad
        return @"iPad";
    }
    return @"can not find the Drivce";
}

@end

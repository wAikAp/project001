//
//  UIImage+videoTool.h
//  videoZhenLvCopy
//
//  Created by shingwai chan on 16/8/10.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (videoTool)
/**
 *  获取视频第一帧
 *
 *  @param url  video的URL
 *  @param size 想要的图片大小
 *
 *  @return image
 */
+ (UIImage *)firstFrameWithVideoURL:(NSURL *)url size:(CGSize)size;
@end

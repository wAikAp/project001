//
//  SWImagePlayer.m
//  videoZhenLv
//
//  Created by shingwai chan on 16/7/12.
//  Copyright © 2016年 ShingWai帅威. All rights reserved.
//

#import "SWImagePlayer.h"

#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>



@interface SWImagePlayer()

@property (nonatomic, strong) UIActivityIndicatorView *activView;

@property (nonatomic, strong) NSMutableArray *images;

@end

@implementation SWImagePlayer

-(instancetype)initWithFrame:(CGRect)frame vidoURLStr:(NSURL *)urlStr
{
    if (self = [super init]) {
        
        self.frame = frame;
//        self.backgroundColor = [UIColor blackColor];
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:frame];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.imageView = imageView;
        
        [self addSubview:imageView];
        
        UIButton *playBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [playBtn setTitle:@"停止" forState:UIControlStateNormal];
        [playBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [playBtn addTarget:self action:@selector(playBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//        [self addSubview:playBtn];
        playBtn.frame = CGRectMake(0, self.bounds.size.height - 100, 60, 60);
        
        
        UIActivityIndicatorView *activView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [self addSubview:activView];
        activView.frame = CGRectMake( 0,  0, 60, 60);
        activView.center = self.center;
//        [activView startAnimating];
        self.activView.hidesWhenStopped = YES;
        self.activView = activView;
        
        
//        AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:<#(nonnull NSURL *)#> fileType:<#(nonnull NSString *)#> error:<#(NSError *__autoreleasing  _Nullable * _Nullable)#>];
        
        
        [self splitVideo:urlStr fps:10 completedBlock:^(NSString *pathStr, NSInteger timesCount) {
            NSLog(@"path -  - %@ count = %ld",pathStr,timesCount);
            NSMutableArray *imageArr = [NSMutableArray array];
            CGSize imaSize;
            for (int i = 1; i <= timesCount; i++) {
                NSString *imaPath = [NSString stringWithFormat:@"%@/%d.png",pathStr,i];
//                NSLog(@"path = %@",imaPath);
                UIImage *sanImage = [UIImage imageWithContentsOfFile:imaPath];
//                NSLog(@"图片：%@",sanImage);
                [imageArr addObject:sanImage];
                imaSize = sanImage.size;
            }
            NSLog(@"数组:%@",imageArr);
            imageView.animationImages = imageArr;
            imageView.animationRepeatCount = 0;
            [imageView startAnimating];
            
        }];
        
        
        //        AVAssetReaderTrackOutput
        //        AVAssetImageGenerator
        //        AVAssetTrack
    }
    return self;
}


/**
 *  把视频文件拆成图片保存在沙盒中
 *
 *  @param fileUrl        本地视频文件URL
 *  @param fps            拆分时按此帧率进行拆分
 *  @param completedBlock 所有帧被拆完成后回调
 */
- (void)splitVideo:(NSURL *)fileUrl fps:(float)fps completedBlock:(void(^)(NSString *pathStr, NSInteger timesCount))completedBlock {
    if (!fileUrl) {
        return;
    }
    NSDictionary *optDict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
    AVURLAsset *avasset = [[AVURLAsset alloc] initWithURL:fileUrl options:optDict];
    
    CMTime cmtime = avasset.duration; //视频时间信息结构体
    Float64 durationSeconds = CMTimeGetSeconds(cmtime); //视频总秒数
    
    NSMutableArray *times = [NSMutableArray array];
    Float64 totalFrames = durationSeconds * fps; //获得视频总帧数
    CMTime timeFrame;
    for (int i = 1; i <= totalFrames; i++) {
        timeFrame = CMTimeMake(i, fps); //第i帧  帧率
        NSValue *timeValue = [NSValue valueWithCMTime:timeFrame];
        [times addObject:timeValue];
    }
    
    NSLog(@"------- start");
    AVAssetImageGenerator *imgGenerator = [[AVAssetImageGenerator alloc] initWithAsset:avasset];
    //防止时间出现偏差
    imgGenerator.requestedTimeToleranceBefore = kCMTimeZero;
    imgGenerator.requestedTimeToleranceAfter = kCMTimeZero;
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSInteger timesCount = [times count];
//    NSMutableArray *imageArr = [NSMutableArray array];
    
    //创建文件夹
    NSFileManager *fileManager = [NSFileManager defaultManager];
    //文件夹路径名称
    NSString *path = [cachePath stringByAppendingPathComponent:@"timePhoto"];
    
    //是否已存在
    BOOL isHaveFile = [fileManager fileExistsAtPath:path];
    int i = 0 ;
    while (isHaveFile) {//已经存在这个文件夹
        i++;
        NSLog(@"文件夹已存在");
        //新的文件夹名称
        NSString *newPath = [NSString stringWithFormat:@"timePhoto%d",i];
        path = [cachePath stringByAppendingPathComponent:newPath];
        if ([fileManager fileExistsAtPath:path]) {//在while里再次判断是否有相同名称
            //有就继续
            continue;
        }else
        {
            //没有就跳出循环
            break;
        }
    }
    
    NSLog(@"创建了帧图片存放的文件夹：%@",path);
    [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    
    //取出帧图片
    [imgGenerator generateCGImagesAsynchronouslyForTimes:times completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        printf("current-----: %lld\n", requestedTime.value);
        switch (result) {
            case AVAssetImageGeneratorCancelled://取消
                NSLog(@"Cancelled");
                break;
            case AVAssetImageGeneratorFailed://失败
                NSLog(@"Failed");
                break;
            case AVAssetImageGeneratorSucceeded: {//成功
               
                NSString *filePath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"/%lld.png",requestedTime.value]];
//                NSLog(@"file - %@",filePath);
                UIImage *uImage = [UIImage imageWithCGImage:image];
                NSData *imgData = UIImagePNGRepresentation(uImage);
                [imgData writeToFile:filePath atomically:YES];
                uImage = nil;
                
                if (requestedTime.value == timesCount) {
                    NSLog(@"completed");
                    if (completedBlock) {
                        //回调
                        completedBlock(path,timesCount);
                    }
                }
            }
                break;
        }
    }];
}





-(void) setAssestWithURL:(NSURL *)url {
    
    AVURLAsset *asset = [[AVURLAsset alloc]initWithURL:url options:nil];
    NSError *error = nil;
    AVAssetReader *reader = [[AVAssetReader alloc]initWithAsset:asset error:&error];
    
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    AVAssetTrack *videoTrack =[videoTracks objectAtIndex:0];
    int m_pixelFormatType;
    //     视频播放时
    m_pixelFormatType = kCVPixelFormatType_32BGRA;
    
    NSMutableDictionary *options = [NSMutableDictionary dictionary];
    [options setObject:@(m_pixelFormatType) forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    AVAssetReaderTrackOutput *videoReaderOutput = [[AVAssetReaderTrackOutput alloc] initWithTrack:videoTrack outputSettings:options];
    [reader addOutput:videoReaderOutput];
    [reader startReading];//开始读取
    
    // 要确保nominalFrameRate>0，之前出现过android拍的0帧视频
    while ([reader status] == AVAssetReaderStatusReading && videoTrack.nominalFrameRate > 0) {
        // 读取 video sample
        CMSampleBufferRef videoBuffer = [videoReaderOutput copyNextSampleBuffer];
        //            [self.delegate mMoveDecoder:self onNewVideoFrameReady:videoBuffer];
        
        // 根据需要休眠一段时间；比如上层播放视频时每帧之间是有间隔的,这里的 sampleInternal 我设置为0.001秒
        float sampleInternal = 0.001;
        [NSThread sleepForTimeInterval:sampleInternal];
        
        [self imagesAddCGimageVideoBuffer:videoBuffer];
        //            NSLog(@"images = %@",self.images);
        
    }
    NSLog(@"images = %@",self.images);
    [self mMoveDecoderOnDecoderFinished:url];
}

- (void)mMoveDecoderOnDecoderFinished:(NSURL *)strUrl
{
    NSLog(@"视频解档完成");
    // 得到媒体的资源
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:strUrl options:nil];
    // 通过动画来播放我们的图片
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
    // asset.duration.value/asset.duration.timescale 得到视频的真实时间
    animation.duration = asset.duration.value/asset.duration.timescale;
    animation.values = self.images;
    animation.repeatCount = MAXFLOAT;
    [self.imageView.layer addAnimation:animation forKey:nil];
    // 确保内存能及时释放掉
    [self.images enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj) {
            obj = nil;
        }
    }];
}


-(void) imagesAddCGimageVideoBuffer:(CMSampleBufferRef)videoBuffer
{

    CGImageRef cgimage = [self imageFromSampleBufferRef:videoBuffer];
    if (!(__bridge id)(cgimage)){return;}
    [self.images addObject:((__bridge id)(cgimage))];
    CGImageRelease(cgimage);
}

// AVFoundation 捕捉视频帧，很多时候都需要把某一帧转换成 image
- (CGImageRef)imageFromSampleBufferRef:(CMSampleBufferRef)sampleBufferRef
{
    // 为媒体数据设置一个CMSampleBufferRef
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBufferRef);
    // 锁定 pixel buffer 的基地址
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    // 得到 pixel buffer 的基地址
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    // 得到 pixel buffer 的行字节数
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // 得到 pixel buffer 的宽和高
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // 创建一个依赖于设备的 RGB 颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // 用抽样缓存的数据创建一个位图格式的图形上下文（graphic context）对象
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    //根据这个位图 context 中的像素创建一个 Quartz image 对象
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // 解锁 pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);
    
    // 释放 context 和颜色空间
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    // 用 Quzetz image 创建一个 UIImage 对象
    // UIImage *image = [UIImage imageWithCGImage:quartzImage];
    
    // 释放 Quartz image 对象
    //    CGImageRelease(quartzImage);
    
    return quartzImage;
    
}


-(void)playBtnClick:(UIButton *)playBtn {
    if (self.imageView.isAnimating) {
        
        NSArray *arr = self.imageView.animationImages;
        [self.imageView stopAnimating];
        self.imageView.image = arr[arr.count / 2];
        
        NSLog(@"当前时间？ %f",self.imageView.animationDuration);
        
    }else{
        
        [self.imageView startAnimating];
        
        
    }
}


// 异步获取帧图片，可以一次获取多帧图片
- (void)centerFrameImageWithVideoURL:(NSURL *)videoURL completion:(void (^)(UIImage *image))completion {
    // AVAssetImageGenerator
    AVAsset *asset = [AVAsset assetWithURL:videoURL];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    // calculate the midpoint time of video
    Float64 duration = CMTimeGetSeconds([asset duration]);
    // 取某个帧的时间，参数一表示哪个时间（秒），参数二表示每秒多少帧
    // 通常来说，600是一个常用的公共参数，苹果有说明:
    // 24 frames per second (fps) for film, 30 fps for NTSC (used for TV in North America and
    // Japan), and 25 fps for PAL (used for TV in Europe).
    // Using a timescale of 600, you can exactly represent any number of frames in these systems
    CMTime midpoint = CMTimeMakeWithSeconds(duration / 2.0, 600);
    
    // 异步获取多帧图片
    NSValue *midTime = [NSValue valueWithCMTime:midpoint];
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[midTime] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (result == AVAssetImageGeneratorSucceeded && image != NULL) {//成功取出
            UIImage *centerFrameImage = [[UIImage alloc] initWithCGImage:image];
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(centerFrameImage);
                }
            });
        } else {//失败
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil);
                }
            });
        }
    }];
}

#pragma mark - 懒加载
-(NSMutableArray *)images
{
    if (_images == nil) {
        _images = [NSMutableArray array];
    }
    return _images;
}


@end

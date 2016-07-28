//
//  TXHRulerScrollView.h
//  PrettyRuler

//

#import <UIKit/UIKit.h>

#define DISTANCELEFTANDRIGHT 5.f // 标尺左右距离
#define DISTANCEVALUE 5.f // 每隔刻度实际长度8个点
#define DISTANCETOPANDBOTTOM 5.f // 标尺上下距离

@interface TXHRulerScrollView : UIScrollView

@property (nonatomic) NSUInteger rulerCount;

@property (nonatomic) NSNumber * rulerAverage;

@property (nonatomic) NSUInteger rulerHeight;

@property (nonatomic) NSUInteger rulerWidth;

@property (nonatomic) CGFloat rulerValue;

@property (nonatomic) BOOL mode;

- (void)drawRuler;

@end

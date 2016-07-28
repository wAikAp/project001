//
//  NYSliderPopover.h
//  NYReader
//
//  Created by Cassius Pacheco on 21/12/12.
//  Copyright (c) 2012 Nyvra Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NYPopover.h"

@interface NYSliderPopover : UISlider

@property (nonatomic, strong) NYPopover *popover;

- (void)showPopover;
- (void)showPopoverAnimated:(BOOL)animated;
- (void)hidePopover;
- (void)hidePopoverAnimated:(BOOL)animated;

//改变高度 默认10 要在m里改才有反应
-(CGRect)trackRectForBounds:(CGRect)bounds;
@end

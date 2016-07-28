//
//  NYSliderPopover.m
//  NYReader
//
//  Created by Cassius Pacheco on 21/12/12.
//  Copyright (c) 2012 Nyvra Software. All rights reserved.
//

#import "NYSliderPopover.h"
#import "NYPopover.h"

#import "Masonry.h"

const CGFloat sliderHeight = 10;

@interface NYSliderPopover()

@property (nonatomic, assign) BOOL isFirstLoad;

@end

@implementation NYSliderPopover

#pragma mark -
#pragma mark UISlider methods

- (NYPopover *)popover
{
    if (_popover == nil) {
        //Default size, can be changed after
        [self addTarget:self action:@selector(updatePopoverFrame) forControlEvents:UIControlEventValueChanged];
        _popover = [[NYPopover alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - 32 - 5, 55, 32)];
        _popover.alpha = 1;
        
        _isFirstLoad = YES;
        
        [self.superview addSubview:_popover];
        [self updatePopoverFrame];
        
    }
    
    return _popover;
}

- (void)setValue:(float)value
{
    [super setValue:value];
    [self updatePopoverFrame];
}


-(CGRect)trackRectForBounds:(CGRect)bounds
{
    
    bounds =  CGRectMake(0, 0, bounds.size.width, sliderHeight);
//    NSLog(@"2bounds????%@",NSStringFromCGRect(bounds));
    return bounds;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updatePopoverFrame];
    [self showPopoverAnimated:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePopoverAnimated:YES];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hidePopoverAnimated:YES];
    [super touchesCancelled:touches withEvent:event];
}

#pragma mark -
#pragma mark - Popover methods

- (void)updatePopoverFrame
{
    CGFloat minimum =  self.minimumValue;
	CGFloat maximum = self.maximumValue;
	CGFloat value = self.value;
	
	if (minimum < 0.0) {
        
		value = self.value - minimum;
		maximum = maximum - minimum;
		minimum = 0.0;
	}
	
	CGFloat x = self.frame.origin.x;
    CGFloat maxMin = (maximum + minimum) / 2.0;
    
    x += (((value - minimum) / (maximum - minimum)) * self.frame.size.width) - (self.popover.frame.size.width / 2.0);
	
	if (value > maxMin) {
		
		value = (value - maxMin) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x - value;
        
	} else {
		
		value = (maxMin - value) + (minimum * 1.0);
		value = value / maxMin;
		value = value * 11.0;
		
		x = x + value;
	}
    
    CGRect popoverRect = self.popover.frame;
    popoverRect.origin.x = x;
    if (_isFirstLoad) {//第一次显示的时候self.y是不对的 要减
            popoverRect.origin.y = self.frame.origin.y - (popoverRect.size.height - 5)*2 - sliderHeight;
        _isFirstLoad = NO;
    }else{
        popoverRect.origin.y = self.frame.origin.y - popoverRect.size.height - 5;
    }
//    NSLog(@"self.y = %f ,popoverRect.y = %f ",self.frame.origin.y,popoverRect.origin.y );
    self.popover.frame = popoverRect;
}

- (void)showPopover
{
    [self showPopoverAnimated:NO];
}

- (void)showPopoverAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 1.0;
        }];
    } else {
        self.popover.alpha = 1.0;
    }
    
}

- (void)hidePopover
{
    [self hidePopoverAnimated:NO];
}

- (void)hidePopoverAnimated:(BOOL)animated
{
//    [self updatePopoverFrame];
    if (animated) {
        [UIView animateWithDuration:0.25 animations:^{
            self.popover.alpha = 0;
        }];
    } else {
        self.popover.alpha = 0;
    }
}

@end

//
//  NYSliderPopover.m
//  NYReader
//

#import "NYSliderPopover.h"
#import "NYPopover.h"


const CGFloat sliderHeight = 10;

@interface NYSliderPopover()

@property (nonatomic, assign) BOOL isFirstLoad;
@property (assign, nonatomic) CGFloat sliderHeight;
@property (nonatomic, assign) BOOL isIpad;
@end

@implementation NYSliderPopover

#pragma mark -
#pragma mark UISlider methods

- (NYPopover *)popover
{
    if (_popover == nil) {
        //Default size, can be changed after
        [self addTarget:self action:@selector(updatePopoverFrame) forControlEvents:UIControlEventValueChanged];
        _popover = [[NYPopover alloc] initWithFrame:CGRectMake(self.frame.origin.x, self.frame.origin.y - 32 - 5, 10, 10)];
        _popover.alpha = 0.75;
        self.backgroundColor = [UIColor clearColor];
        _isFirstLoad = YES;
//        [self.superview addSubview:_popover];
        [self updatePopoverFrame];
        
    }
    
    return _popover;
}

- (void)setValue:(float)value
{
    [super setValue:value];
//    [self updatePopoverFrame];
//    [self nowDeviceType];
}

-(void)nowDeviceType
{
    NSString *deviceType = [UIDevice currentDevice].model;
    
    if ([deviceType isEqualToString:@"iPad"]) {
        self.isIpad = YES;
        self.sliderHeight = 5;
        
    }else{
        self.isIpad = NO;
        self.sliderHeight = 10;
    }
}
-(CGRect)trackRectForBounds:(CGRect)bounds
{
    [self nowDeviceType];
    CGFloat y = 0;
    if (self.isIpad) {
        y = 8;
    }
    bounds =  CGRectMake(0, y, bounds.size.width, self.sliderHeight);

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
    [self nowDeviceType];
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
            popoverRect.origin.y = self.frame.origin.y - (popoverRect.size.height - 5)*2 - self.sliderHeight;
        _isFirstLoad = NO;
    }else{
        popoverRect.origin.y = self.frame.origin.y - popoverRect.size.height - self.sliderHeight/2;
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
            self.popover.alpha = 0.75;
        }];
    } else {
        self.popover.alpha = 0.75;
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

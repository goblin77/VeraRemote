//
//  LongHoldButton.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 7/26/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ThermostatControlButton.h"
#import "CircularShapeView.h"
#import "PropertyInvalidator.h"

@interface ThermostatControlButton () <Invalidatable>

@property (nonatomic) CircularShapeView *backgroundView;

@property (nonatomic) BOOL buttonPressed;

@property (nonatomic) PropertyInvalidator *propertyInvalidator;

@end

@implementation ThermostatControlButton

@synthesize mode = _mode;

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[CircularShapeView alloc] initWithFrame:CGRectZero];
        self.backgroundView.fillColor = [UIColor whiteColor];
        self.backgroundView.strokeColor = [UIColor colorWithRGBHex:0x3f75ff];
        [self addSubview:self.backgroundView];
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.textColor = [UIColor colorWithRGBHex:0x3f75ff];
        [self addSubview:self.titleLabel];
        
        [self.titleLabel addObserver:self forKeyPath:K(text) options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
        
        self.buttonPressed = NO;
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
    }
    
    return self;
}

- (void)dealloc
{
    [self.titleLabel removeObserver:self forKeyPath:K(text)];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat side = MIN(self.bounds.size.width, self.bounds.size.height);
    
    self.backgroundView.frame = CGRectMake((self.bounds.size.width - side)/2, (self.bounds.size.height - side)/2,side,side);
    [self.titleLabel sizeToFit];
    self.titleLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height/2 - 1);
}

- (void)commitProperties
{
    if (self.mode == ThermostatControlButtonModeDisabled)
    {
        self.backgroundView.fillColor = [UIColor whiteColor];
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.backgroundView.strokeColor = [UIColor lightGrayColor];
        return;
    }
    
    UIColor *nonWhiteColor = self.mode == ThermostatControlButtonModeHeat ? [UIColor redColor] : [UIColor colorWithRGBHex:0x3f75ff];
    
    self.backgroundView.strokeColor = nonWhiteColor;
    if (self.buttonPressed)
    {
        self.backgroundView.fillColor = nonWhiteColor;
        self.titleLabel.textColor = [UIColor whiteColor];
    }
    else
    {
        self.backgroundView.fillColor = [UIColor whiteColor];
        self.titleLabel.textColor = nonWhiteColor;
    }
}

- (ThermostatControlButtonMode)mode
{
    return _mode;
}

- (void)setMode:(ThermostatControlButtonMode)value
{
    if (_mode == value)
    {
        return;
    }
    
    _mode = value;
    [self.propertyInvalidator invalidateProperties];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.titleLabel sizeToFit];
    [self setNeedsLayout];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.mode != ThermostatControlButtonModeDisabled)
    {
        self.buttonPressed = YES;
        [self.propertyInvalidator invalidateProperties];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.buttonPressed && self.didTap != nil)
    {
        self.didTap();
    }
    self.buttonPressed = NO;
    [self.propertyInvalidator invalidateProperties];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.buttonPressed = NO;
    [self.propertyInvalidator invalidateProperties];
}

@end

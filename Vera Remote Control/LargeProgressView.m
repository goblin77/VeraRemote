//
//  LargeProgressView.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "LargeProgressView.h"
#import <QuartzCore/QuartzCore.h>
#import "ObserverUtils.h"

@implementation LargeProgressView

@synthesize progressArea;
@synthesize spinner;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.backgroundColor = [UIColor colorWithRGBHex:0x000000 alpha:0.1];
        self.progressArea = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
        self.progressArea.backgroundColor = [UIColor colorWithRGBHex:0x000000 alpha:0.5];
        self.progressArea.layer.cornerRadius = 10;
        [self addSubview:self.progressArea];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectZero];
        self.label.backgroundColor = [UIColor clearColor];
        self.label.font = [UIFont defaultBoldFontWithSize:14];
        self.label.numberOfLines = 2;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
        self.label.textAlignment = NSTextAlignmentCenter;
        self.label.textColor = [UIColor whiteColor];
        self.label.alpha = 0.8;
        [self.progressArea addSubview:self.label];
        
        self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        self.spinner.hidesWhenStopped = NO;
        [self.spinner sizeToFit];
        
        self.spinner.center = CGPointMake(self.progressArea.bounds.size.width / 2, self.progressArea.bounds.size.height / 2);
        [self.progressArea addSubview:self.spinner];
        
        self.userInteractionEnabled = YES;
        [self.label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    return self;
}

-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self.label forKeyPaths:@[@"text"]];
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    
    CGFloat y = self.progressArea.bounds.size.height / 2;
    if(self.label.text.length > 0)
    {
        CGFloat textHeight = [self.label.text sizeWithFont:self.label.font constrainedToSize:CGSizeMake(self.progressArea.bounds.size.width - 10, 1000) lineBreakMode:self.label.lineBreakMode].height;
        y = (self.progressArea.bounds.size.height - textHeight - 5 - self.spinner.bounds.size.height) / 2;
        self.spinner.frame = CGRectOffset(self.spinner.bounds,(self.progressArea.bounds.size.width - self.spinner.bounds.size.width)/2, y);
        y += self.spinner.bounds.size.height + 5;
        self.label.frame = CGRectMake(5, y, self.progressArea.bounds.size.width - 10, textHeight);
    }
    else
    {
        y = (self.progressArea.bounds.size.height - self.spinner.bounds.size.height)/2;
        self.spinner.frame = CGRectOffset(self.spinner.bounds,(self.progressArea.bounds.size.width - self.spinner.bounds.size.width)/2, y);
    }
    
    
    self.progressArea.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
}


#pragma mark -
#pragma mark KVO

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self setNeedsLayout];
}

#pragma mark -
#pragma mark misc helper functions

+(LargeProgressView *) sharedInstance
{
    static LargeProgressView * instance = nil;
    
    if(instance == nil)
    {
        instance = [[LargeProgressView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    }
    
    return instance;
}

+(void) showWithTitle:(NSString *) title
{
    [LargeProgressView sharedInstance].label.text = title;
    [LargeProgressView show];
}

+(void) show
{
    if([LargeProgressView sharedInstance].label.text.length == 0)
    {
       [LargeProgressView sharedInstance].label.text = @"Please wait ...";
    }
    [LargeProgressView updateCount:1];
    
}


+(void) hide
{
    [LargeProgressView updateCount:-1];
}


+(void) updateCount:(NSInteger) countIncrement
{
    @synchronized([LargeProgressView class])
    {
        static NSInteger count = 0;
        
        count += countIncrement;
        if(count < 0)
        {
            count = 0;
        }
        
        LargeProgressView * instance = [LargeProgressView sharedInstance];
        
        if(count == 0)
        {
            [instance performSelectorOnMainThread:@selector(removeFromSuperview) withObject:nil waitUntilDone:YES];
            [instance.spinner performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
        }
        else
        {
            if(instance.superview == nil) // if not shown yet
            {
                UIWindow * window = (UIWindow *)[UIApplication sharedApplication].windows[0];
                [window addSubview:instance];
            }
            
            [instance.spinner startAnimating];
        }
    }
}




@end

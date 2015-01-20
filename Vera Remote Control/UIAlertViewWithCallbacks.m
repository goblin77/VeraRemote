//
//  UIAlertViewWithCallbacks.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "UIAlertViewWithCallbacks.h"

@implementation UIAlertViewWithCallbacks


@synthesize alertViewCancel;
@synthesize willPresentAlertView;
@synthesize didPresentAlertView;
@synthesize alertViewWillDismissWithButtonIndex;
@synthesize alertViewDidDismissWithButtonIndex;
@synthesize alertViewShouldEnableFirstOtherButton;
@synthesize alertViewClickedButtonAtIndex;


-(id) initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    if(self = [super initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitles,nil])
    {
        va_list args;
        va_start(args, otherButtonTitles);
        for (NSString * arg = otherButtonTitles; arg != nil; arg = va_arg(args, id))
        {
            if(arg != nil && ![arg isEqualToString:otherButtonTitles])
            {
                [self addButtonWithTitle:arg];
            }
        }
        va_end(args);
        
    }
    
    return self;
}

#pragma mark -
#pragma mark UIAlertViewDelegate implementation
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(self.alertViewClickedButtonAtIndex != nil)
    {
        self.alertViewClickedButtonAtIndex(self, buttonIndex);
    }
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
    if(self.alertViewCancel != nil)
    {
        self.alertViewCancel(self);
    }
}


- (void)willPresentAlertView:(UIAlertView *)alertView
{
    if(self.willPresentAlertView != nil)
    {
        self.willPresentAlertView(self);
    }
}

- (void)didPresentAlertView:(UIAlertView *)alertView
{
    if(self.didPresentAlertView != nil)
    {
        self.didPresentAlertView(self);
    }
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(self.alertViewWillDismissWithButtonIndex != nil)
    {
        self.alertViewWillDismissWithButtonIndex(self, buttonIndex);
    }
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(self.alertViewDidDismissWithButtonIndex != nil)
    {
        self.alertViewDidDismissWithButtonIndex(alertView, buttonIndex);
    }
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    if(self.alertViewShouldEnableFirstOtherButton != nil)
    {
        return self.alertViewShouldEnableFirstOtherButton(self);
    }
    
    return YES;
}


@end

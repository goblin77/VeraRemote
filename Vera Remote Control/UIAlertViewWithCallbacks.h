//
//  UIAlertViewWithCallbacks.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertViewWithCallbacks : UIAlertView <UIAlertViewDelegate>

@property (nonatomic, copy) void (^alertViewCancel)(UIAlertView * alertView);
@property (nonatomic, copy) void (^willPresentAlertView)(UIAlertView * alertView);
@property (nonatomic, copy) void (^didPresentAlertView)(UIAlertView * alertView);
@property (nonatomic, copy) void (^alertViewClickedButtonAtIndex)(UIAlertView * alertView, NSUInteger buttonIndex);
@property (nonatomic, copy) void (^alertViewWillDismissWithButtonIndex)(UIAlertView * alertView, NSUInteger buttonIndex);
@property (nonatomic, copy) void (^alertViewDidDismissWithButtonIndex)(UIAlertView * alertView, NSUInteger buttonIndex);
@property (nonatomic, copy) BOOL (^alertViewShouldEnableFirstOtherButton)(UIAlertView * alertView);

-(id) initWithTitle:(NSString *)title
            message:(NSString *)message
  cancelButtonTitle:(NSString *)cancelButtonTitle
  otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end

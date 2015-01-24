//
//  FaultUtils.m
//  SpayceCard
//
//  Created by Dmitry Miller on 5/5/13.
//  Copyright (c) 2013 Spayce Inc. All rights reserved.
//

#import "FaultUtils.h"
#import "UIAlertViewWithCallbacks.h"

@implementation FaultUtils

+(void) genericFaultHandler:(NSError *) fault
{
    NSString * message = [fault.userInfo objectForKey:@"description"];
    NSString * title   = [fault.userInfo objectForKey:@"title"];
    
    if([fault.domain isEqualToString:NSURLErrorDomain] && fault.code == -1001)
    {
        message = @"Cannot reach the server. Please make sure that you have data connection";
    }
    else if([fault.domain isEqualToString:@"Parse"])
    {
        message = fault.userInfo[@"error"];
    }
    
    
    
    if(title == nil)
    {
        title = @"Oops!";
    }
    
    if(message == nil)
    {
        message = @"An error has occurred";
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:title
                                                     message:message
                                                    delegate:nil
                                           cancelButtonTitle:@"Dismiss"
                                           otherButtonTitles:nil
                           ];
    
    [alert show];
}


+(NSError *) generalErrorWithDescription:(NSString *) description
{
    return [FaultUtils generalErrorWithTitle:nil andDescription:description];
}


+(NSError *) generalErrorWithTitle:(NSString *) title andDescription:(NSString *) description
{
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    if(title != nil)
    {
        [userInfo setObject:title forKey:@"title"];
    }
    
    if(description != nil)
    {
        [userInfo setObject:description forKey:@"description"];
    }
    
    return [NSError errorWithDomain:@"GeneralError"
                               code:0
                           userInfo:userInfo];
}

+(NSError *) generalErrorWithCode:(NSInteger) code andTitle:(NSString *) title andDescription:(NSString *) description
{
    NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    
    if(title != nil)
    {
        [userInfo setObject:title forKey:@"title"];
    }
    
    if(description != nil)
    {
        [userInfo setObject:description forKey:@"description"];
    }
    
    return [NSError errorWithDomain:@"GeneralError"
                               code:code
                           userInfo:userInfo];
}


+(void) retryFaultHandlerWithErrorMessage:(NSString *)erroMessage retryCallback:(void(^)(void)) retryCallback
{
    UIAlertViewWithCallbacks * alertView = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                                   message:erroMessage
                                                                         cancelButtonTitle:@"Cancel"
                                                                         otherButtonTitles:@"Retry", nil];
    alertView.alertViewClickedButtonAtIndex = ^(UIAlertView * av, NSUInteger buttonIndex)
    {
        if(buttonIndex == 1)
        {
            if(retryCallback != nil)
            {
                retryCallback();
            }
        }
    };
    
    [alertView show];
}


@end

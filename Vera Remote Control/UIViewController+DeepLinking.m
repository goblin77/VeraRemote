//
//  UIViewController+DeepLinking.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/14/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "UIViewController+DeepLinking.h"

@implementation UIViewController(DeepLinking)

- (void)processURLPathComponents:(NSArray *)pathComponents completion:(void (^)(void))completion
{
    if (completion != nil)
    {
        completion();
    }
}

@end

//
//  UIViewController+DeepLinking.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 8/14/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIViewController(DeepLinking)

- (void)processURLPathComponents:(NSArray *)pathComponents completion:(void (^)(void))completion;

@end

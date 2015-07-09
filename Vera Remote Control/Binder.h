//
//  Binder.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 7/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Binder : NSObject

- (instancetype)initWithObject:(NSObject *)object keyPaths:(NSArray *)keyPaths callback:(void(^)(void))callback;
- (void)startObserving;
- (void)stopObserving;

@end

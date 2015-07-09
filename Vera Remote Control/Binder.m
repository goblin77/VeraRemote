//
//  Binder.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 7/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "Binder.h"
#import "ObserverUtils.h"


@interface Binder()
@property (nonatomic) NSObject *object;
@property (nonatomic) NSArray  *keyPaths;
@property (nonatomic, copy) void (^callback)(void);

@property (nonatomic, assign) BOOL observing;
@end

@implementation Binder

-(instancetype)init NS_UNAVAILABLE
{
    return self = [super init];
}

-(instancetype)initWithObject:(NSObject *)object keyPaths:(NSArray *)keyPaths callback:(void (^)(void))callback {
    NSAssert(object != nil, @"Object cannot be nil");
    NSAssert(keyPaths.count > 0, @"keyPaths should not be empty");
    NSAssert(callback != nil, @"callback cannot be nil");
    
    if (self = [super init])
    {
        self.object = object;
        self.keyPaths = keyPaths;
        self.callback = callback;
    }
    
    return self;
}

- (void)dealloc
{
    [self stopObserving];
}

- (void)startObserving
{
    if (self.observing)
    {
        return;
    }
    
    self.observing = YES;
    [ObserverUtils addObserver:self toObject:self.object forKeyPaths:self.keyPaths withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}

- (void)stopObserving
{
    self.observing = NO;
    [ObserverUtils removeObserver:self fromObject:self.object forKeyPaths:self.keyPaths];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    self.callback();
}

@end

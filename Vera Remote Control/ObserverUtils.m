//
//  ObserverUtils.m
//  SpayceBook
//
//  Created by Dmitry Miller on 5/27/13.
//  Copyright (c) 2013 Spayce Inc. All rights reserved.
//

#import "ObserverUtils.h"

@implementation ObserverUtils

+(void) removeObserver:(NSObject *) observer fromObject:(NSObject *) object forKeyPaths:(NSArray *) keyPaths
{
    for(NSString * keyPath in keyPaths)
    {
        
        @try
        {
            [object removeObserver:observer forKeyPath:keyPath];
        }
        @catch (NSException *exception)
        {
            //do nothing
        }
    }
}

+(void) addObserver:(NSObject *) observer toObject:(NSObject *) object forKeyPaths:(NSArray *) keyPaths
{
    [ObserverUtils addObserver:observer toObject:object forKeyPaths:keyPaths withOptions:NSKeyValueObservingOptionNew];
}

+(void) addObserver:(NSObject *) observer toObject:(NSObject *) object forKeyPaths:(NSArray *) keyPaths withOptions:(NSKeyValueObservingOptions) options
{
    for(NSString * keyPath in keyPaths)
    {
        [object addObserver:observer forKeyPath:keyPath options:options context:nil];
    }
}


@end

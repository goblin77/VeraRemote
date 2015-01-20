//
//  ObserverUtils.h
//  SpayceBook
//
//  Created by Dmitry Miller on 5/27/13.
//  Copyright (c) 2013 Spayce Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ObserverUtils : NSObject

+(void) removeObserver:(NSObject *) observer fromObject:(NSObject *) object forKeyPaths:(NSArray *) keyPaths;
+(void) addObserver:(NSObject *) observer toObject:(NSObject *) object forKeyPaths:(NSArray *) keyPaths;
+(void) addObserver:(NSObject *) observer toObject:(NSObject *) object forKeyPaths:(NSArray *) keyPaths withOptions:(NSKeyValueObservingOptions) options;

@end

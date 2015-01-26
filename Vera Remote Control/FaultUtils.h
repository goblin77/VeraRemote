//
//  FaultUtils.h
//  SpayceCard
//
//  Created by Dmitry Miller on 5/5/13.
//  Copyright (c) 2013 Spayce Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FaultUtils : NSObject


#ifndef IS_EXTENSION
+(void) genericFaultHandler:(NSError *) fault;
+(NSError *) generalErrorWithDescription:(NSString *) description;
+(NSError *) generalErrorWithTitle:(NSString *) title andDescription:(NSString *) description;
+(NSError *) generalErrorWithCode:(NSInteger) code andTitle:(NSString *) title andDescription:(NSString *) description;
+(void) retryFaultHandlerWithErrorMessage:(NSString *) erroMessage retryCallback:(void(^)(void)) retryCallback;
#endif

+(BOOL) unaccessableUrlFault:(NSError *) fault;

@end

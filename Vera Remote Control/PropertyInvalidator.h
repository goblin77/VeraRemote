//
//  PropertyInvalidator.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Invalidatable

-(void) commitProperties;

@end


@interface PropertyInvalidator : NSObject

@property (nonatomic, strong) NSObject  <Invalidatable> * host;
@property (nonatomic, assign) NSTimeInterval delay;

-(id) initWithHostObject:(NSObject <Invalidatable> *) host;
-(void) invalidateProperties;

@end

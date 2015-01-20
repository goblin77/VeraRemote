//
//  JSONSerializable.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol JSONSerializable

@required
-(void) updateWithDictionary:(NSDictionary *) src;

@end

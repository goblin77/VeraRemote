//
//  Room.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONSerializable.h"

@interface Room : NSObject <JSONSerializable>

@property (nonatomic, assign) NSInteger roomId;
@property (nonatomic, strong) NSString * name;

@end

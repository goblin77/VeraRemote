//
//  Room.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "Room.h"

@implementation Room

-(void) updateWithDictionary:(NSDictionary *)src
{
    self.roomId = [src[@"id"] integerValue];
    self.name   = src[@"name"];
}

@end

//
//  VeraAccessPoint.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "VeraAccessPoint.h"

@implementation VeraAccessPoint

- (id)copyWithZone:(NSZone *)zone
{
    VeraAccessPoint * res = [[VeraAccessPoint alloc] init];
    res.localUrl = [self.localUrl copyWithZone:zone];
    res.remoteUrl= [self.remoteUrl copyWithZone:zone];
    res.localMode = self.localMode;
    return res;
}

@end

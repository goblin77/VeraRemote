//
//  VeraDevice.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "VeraDevice.h"

@implementation VeraDevice


#pragma mark -
#pragma mark JSONSerializable implementation
-(void) updateWithDictionary:(NSDictionary *)src
{
    self.name = src[@"name"];
    self.serialNumber = src[@"serialNumber"];
    self.firmwareVersion = src[@"FirmwareVersion"];
    self.ipAddress = src[@"ipAddress"];
    self.forwardServer = src[@"active_server"];
}

#pragma mark -
#pragma NSCoding implementation
-(id) initWithCoder:(NSCoder *)aDecoder
{
    if(self = [super init])
    {
        NSString * value = nil;
        for(NSString * key in [self keys])
        {
            value = [aDecoder decodeObjectForKey:key];
            if(value != nil)
            {
                [self setValue:value forKey:key];
            }
        }
    }
    
    return self;
}


-(void) encodeWithCoder:(NSCoder *)aCoder
{
    NSString * value = nil;
    for(NSString * key in [self keys])
    {
        value = [self valueForKey:key];
        if(value != nil)
        {
            [aCoder encodeObject:value forKey:key];
        }
    }
}

-(NSArray *) keys
{
    static NSArray * keys = nil;
    if(keys == nil)
    {
        keys = @[@"name",@"serialNumber",@"firmwareVersion",@"ipAddress",@"forwardServer"];
    }
    
    return keys;
}



@end

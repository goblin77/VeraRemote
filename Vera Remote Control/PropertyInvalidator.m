//
//  PropertyInvalidator.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "PropertyInvalidator.h"
#import "dispatch_cancelable_block.h"
@interface PropertyInvalidator ()

@property (nonatomic, strong) dispatch_cancelable_block_t scheduledCommitProperties;

@end

@implementation PropertyInvalidator

-(id) init
{
    if(self = [super init])
    {
        self.delay = 0.04; // 25 fps
        self.scheduledCommitProperties = nil;
    }
    
    return self;
}

-(id) initWithHostObject:(NSObject<Invalidatable> *)hostObject
{
    if(self = [self init])
    {
        self.host = hostObject;
    }
    
    return self;
}

-(void) dealloc
{
    if(self.scheduledCommitProperties != nil)
    {
        cancel_block(self.scheduledCommitProperties);
        self.scheduledCommitProperties = nil;
    }
}


-(void) invalidateProperties
{
    if(self.scheduledCommitProperties == nil)
    {
        __weak PropertyInvalidator * thisObject = self;
        self.scheduledCommitProperties = dispatch_after_delay(self.delay, ^{
            if([thisObject.host respondsToSelector:@selector(commitProperties)])
            {
                [thisObject.host commitProperties];
                thisObject.scheduledCommitProperties = nil;
            }
        });
    }
}

@end

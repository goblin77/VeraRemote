//
//  dispatch_cancelable_block.h
//  SafePage
//
//  Created by Dmitry Miller on 9/25/14.
//  Copyright (c) 2014 Personal Capital Corporation. All rights reserved.
//

#ifndef SafePage_dispatch_cancelable_block_h
#define SafePage_dispatch_cancelable_block_h

typedef void(^dispatch_cancelable_block_t)(BOOL cancel);

static dispatch_cancelable_block_t dispatch_after_delay(CGFloat delayInSeconds, dispatch_block_t block)
{
    if(block == nil)
    {
        return nil;
    }
    
    __block dispatch_cancelable_block_t cancellableBlock = nil;
    __block dispatch_block_t originalBlock = [block copy];
    
    
    // declare wrapper for originalBlock
    dispatch_cancelable_block_t delayedBlock = ^(BOOL shouldCancel)
    {
        if(!shouldCancel && originalBlock != nil)
        {
            dispatch_async(dispatch_get_main_queue(), originalBlock);
        }
        
        // clean up
        originalBlock = nil;
        cancellableBlock = nil;
    };
    
    cancellableBlock = [delayedBlock copy];
    
    // schedule executing wrapper for cancellableBlock
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if(cancellableBlock != nil)
        {
            cancellableBlock(NO);
        }
    });
    
    
    return cancellableBlock;
}


// cancels the scehduled execution
static void cancel_block(dispatch_cancelable_block_t block)
{
    if(block == nil)
    {
        return;
    }
    
    block(YES);
}


#endif

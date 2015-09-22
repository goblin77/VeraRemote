//
//  DoorLockCell.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 9/17/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "ControlledDevice.h"

@interface DoorLockCell : UITableViewCell


@property (nonatomic) DoorLock *doorLock;

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier NS_UNAVAILABLE;
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@property (nonatomic,copy) void (^willCommitValue)(BOOL value);

@end

//
//  LightsAndSwitchesTableSection.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/21/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Room.h"

@interface LightsAndSwitchesTableSection : NSObject

@property (nonatomic, strong) NSArray * items;
@property (nonatomic, readonly) NSString * title;

@end

@interface RoomTableSection : LightsAndSwitchesTableSection

@property (nonatomic, strong) Room * room;

@end



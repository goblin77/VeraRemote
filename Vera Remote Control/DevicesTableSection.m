//
//  LightsAndSwitchesTableSection.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/21/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DevicesTableSection.h"
#import "ControlledDevice.h"

@implementation DevicesTableSection


@end

@implementation RoomTableSection

-(NSString *) title
{
    return self.room.name;
}


+(NSArray *) createRoomSectionsWithDevices:(NSArray *)devices rooms:(NSArray *)rooms
{
    Room * noRoom = [[Room alloc] init];
    noRoom.roomId = 0;
    noRoom.name = @"No Room";
    NSArray * allRooms = [@[noRoom] arrayByAddingObjectsFromArray:rooms];
    NSMutableDictionary * sectionLookup = [[NSMutableDictionary alloc] initWithCapacity:allRooms.count];
    
    
    for(Room * r in allRooms)
    {
        RoomTableSection * section  = [[RoomTableSection alloc] init];
        section.room = r;
        sectionLookup[@(r.roomId)] = section;
    }
    
    
    for(ControlledDevice * device in devices)
    {
        RoomTableSection * section = sectionLookup[@(device.roomId)];
        if(section == nil)
        {
            continue;
        }
        
        if(section.items == nil)
        {
            section.items = [[NSMutableArray alloc] init];
        }
        
        [(NSMutableArray *)section.items addObject:device];
    }
    
    
    
    
    NSArray * allRoomSections = [[sectionLookup allValues] sortedArrayUsingComparator:^NSComparisonResult(RoomTableSection * s1, RoomTableSection * s2) {
        return [s1.title compare:s2.title];
    }];
    
    NSMutableArray * res = [[NSMutableArray alloc] initWithCapacity:allRoomSections.count];
    for(RoomTableSection * section in allRoomSections)
    {
        if(section.items.count > 0)
        {
            section.items = [section.items sortedArrayUsingComparator:^NSComparisonResult(ControlledDevice * d1, ControlledDevice * d2)
            {
                if(d1.parentDeviceId < d2.parentDeviceId)
                {
                    return NSOrderedAscending;
                }
                else if (d1.parentDeviceId > d1.parentDeviceId)
                {
                    return NSOrderedDescending;
                }
                
                return d1.deviceId < d2.deviceId ? NSOrderedAscending : NSOrderedDescending;
            }];
            [res addObject:section];
        }
    }
    
    return res;
}

@end

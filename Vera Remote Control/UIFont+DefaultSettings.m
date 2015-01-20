//
//  UIFont+DefaultSettings.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "UIFont+DefaultSettings.h"

@implementation UIFont(DefaultSettings)

+(UIFont *) defaultFont
{
    return [UIFont defaultFontWithSize:14];
}

+(UIFont *) defaultBoldFont
{
    return [UIFont defaultBoldFontWithSize:14];
}

@end

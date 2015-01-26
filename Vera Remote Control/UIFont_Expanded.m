//
//  UIFont.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "UIFont_Expanded.h"
#import <UIKit/UIKit.h>

@implementation UIFont (Expanded)

+(UIFont *) defaultFontWithSize:(int) fontSize
{
    return [UIFont systemFontOfSize:fontSize];
}

+(UIFont *) defaultBoldFontWithSize:(int) fontSize
{
    return [UIFont boldSystemFontOfSize:fontSize];
}


+(UIFont *) defaultItalicFontWithSize:(int) fontSize
{
    return [UIFont italicSystemFontOfSize:fontSize];
}

-(CGFloat) lineHeightPx
{
    return ceilf(self.lineHeight);
}



@end

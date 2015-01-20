//
//  UIFont.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIFont(Expanded)

+(UIFont *) defaultFontWithSize:(int) fontSize;
+(UIFont *) defaultBoldFontWithSize:(int) fontSize;
+(UIFont *) defaultItalicFontWithSize:(int) fontSize;

-(CGFloat) lineHeightPx;

@end

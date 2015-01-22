//
//  StyleUtils.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/26/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "StyleUtils.h"
#import <QuartzCore/QuartzCore.h>

@implementation StyleUtils

+(void) applyDefaultStyleOnTextField:(UITextField *) textField
{
    textField.font = [UIFont defaultFont];
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.borderWidth = 1;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
    textField.layer.cornerRadius = 5;
    textField.backgroundColor = [UIColor whiteColor];
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

+(void) applyDefaultStyleOnTextFieldWithinTableCell:(UITextField *) textField
{
    textField.font = [StyleUtils fontForNonMissingValues];
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.layer.borderColor = [UIColor blackColor].CGColor;
    textField.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

+(void) applyDefaultStyleOnLabel:(UILabel *) label
{
    label.font = [UIFont defaultFont];
    label.textColor = [StyleUtils defaultTextColor];
    label.backgroundColor = [UIColor clearColor];
}

+(void) applyDefaultStyleOnValueLabelWithTableCell:(UILabel *) label
{
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [StyleUtils fontForNonMissingValues];
}

+(void) applyStyleOnDescriptiveTextLabel:(UILabel *)label
{
    label.textColor = [StyleUtils promptTextColor];
    label.backgroundColor = [UIColor clearColor];
    label.font = [StyleUtils fontForCellPrompt];
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
}

+(void) applyDefaultStyleOnTableTitleLabel:(UILabel *)label
{
    
    static UITableViewHeaderFooterView * sampleHeader = nil;
    
    if(sampleHeader == nil)
    {
        sampleHeader = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:nil];
    }
    
    label.backgroundColor = [UIColor clearColor];
    
    
    label.font = [UIFont defaultFontWithSize:16];
    label.textColor   = [UIColor darkGrayColor];
    
}


+(UIFont *) fontForNonMissingValues
{
    static UIFont * font = nil;
    
    if(font == nil)
    {
        font = [UIFont defaultFontWithSize:16];
    }
    
    return font;
}


+(UIFont *) fontForCellPrompt
{
    static UIFont * font = nil;
    if(font == nil)
    {
        font = [UIFont defaultFontWithSize:14];
    }
    
    return font;
}

+(UIColor *) defaultTextColor
{
    static UIColor * color = nil;
    if(color == nil)
    {
        color = [UIColor darkGrayColor];
    }
    
    return color;
}


+(UIColor *) promptTextColor
{
    static UIColor * color = nil;
    
    if(color == nil)
    {
        color = [UIColor darkGrayColor];
    }
    
    return color;
}

+(UIColor *) primaryActionButtonColor
{
    return [UIColor colorWithRGBHex:0x222e6f];
}

+(UIColor *) secondaryActionButtonColor
{
    return [UIColor colorWithRGBHex:0x666666];
}


+(UIColor *) colorForFieldOrLabelWithMissingItem
{
    return [UIColor lightGrayColor];
}

+(UIColor *) colorForSelectedValueInTableCell
{
    static UIColor * c = nil;
    if(c == nil)
    {
        c = [UIColor colorWithRGBHex:0x3F75FF];
    }
    
    return c;
}

+(CGFloat) horizontalTableCellMargin
{
    static CGFloat margin = -1;
    if(margin < 0)
    {
        margin = 15;
    }
    
    return margin;
}

+(UIColor *) goColor
{
    static UIColor * goColor = nil;
    if(goColor == nil)
    {
        goColor = [UIColor colorWithRGBHex:0x6Fb334];
    }
    
    return goColor;
}


+(CGFloat) defaultTableCellMargin
{
    return 15;
}

+(UIColor *) activeColor
{
    static UIColor * activeColor = nil;
    if(activeColor == nil)
    {
        activeColor = [UIColor colorWithRGBHex:0x85d866];
    }
    
    return activeColor;
}


+(void) setUpAppearance
{
    //[[UINavigationBar appearance] setTitleTextAttributes:@{UITextAttributeFont : [UIFont defaultFontWithSize:18]}];
}


@end

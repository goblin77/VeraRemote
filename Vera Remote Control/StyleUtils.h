//
//  StyleUtils.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/26/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StyleUtils : NSObject

+(void) applyDefaultStyleOnTextField:(UITextField *) textField;
+(void) applyDefaultStyleOnTextFieldWithinTableCell:(UITextField *) textField;
+(void) applyDefaultStyleOnLabel:(UILabel *) label;
+(void) applyDefaultStyleOnValueLabelWithTableCell:(UILabel *) label;


+(void) applyDefaultStyleOnTableTitleLabel:(UILabel *)label;
+(void) applyStyleOnDescriptiveTextLabel:(UILabel *)label;
+(void) applyStyleOnLargeInfoTextLabel:(UILabel *)label;
+(UIFont *) fontForNonMissingValues;
+(UIFont *) fontForCellPrompt;

+(UIColor *) defaultTextColor;
+(UIColor *) promptTextColor;
+(UIColor *) primaryActionButtonColor;
+(UIColor *) secondaryActionButtonColor;
+(UIColor *) colorForFieldOrLabelWithMissingItem;
+(UIColor *) colorForSelectedValueInTableCell;
+(CGFloat) horizontalTableCellMargin;
+(void) setUpAppearance;
+(UIColor *) goColor;

+(CGFloat) defaultTableCellMargin;
+(UIColor *) activeColor;


@end

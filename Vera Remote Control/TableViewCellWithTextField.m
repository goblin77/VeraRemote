//
//  TableViewCellWithTextFieldCell.m
//  Time Tracker
//
//  Created by Dmitry Miller on 11/26/12.
//  Copyright (c) 2012 Dmitry Miller. All rights reserved.
//

#import "TableViewCellWithTextField.h"
#import "StyleUtils.h"
#import "DefaultKeyboardAccessoryView.h"

@implementation TableViewCellWithTextField

@synthesize textField;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier
{
    return [self initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        cellStyle = style;
        self.leftColumnWidth = 120;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.textColor = [StyleUtils promptTextColor];
        self.textLabel.font = [UIFont defaultFontWithSize:14];
        
        self.textField = [[UITextField alloc] initWithFrame:CGRectZero];
        
        self.textField.inputAccessoryView = [[DefaultKeyboardAccessoryView alloc] initWithCloseButtonAndResponder:self.textField];
        [StyleUtils applyDefaultStyleOnTextFieldWithinTableCell:self.textField];
        self.textField.textAlignment = cellStyle == UITableViewCellStyleValue1 ? NSTextAlignmentRight : NSTextAlignmentLeft;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:self.textField];
        
        
    }
    
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    CGFloat horizontalMargin = [StyleUtils horizontalTableCellMargin];
    CGFloat textHeight = MAX(self.textField.font.lineHeight, 21);
    
    if(cellStyle == UITableViewCellStyleValue1)
    {
        self.textField.frame= CGRectMake(self.contentView.bounds.size.width/2,
                                         (self.contentView.bounds.size.height - textHeight) / 2,
                                         self.contentView.bounds.size.width/2 - horizontalMargin,
                                         textHeight);
    }
    else if(cellStyle == UITableViewCellStyleValue2)
    {
        CGFloat x = horizontalMargin;
        CGFloat y = (self.contentView.bounds.size.height - self.textLabel.font.lineHeight) / 2;
        self.textLabel.frame = CGRectMake(x, y, self.leftColumnWidth - horizontalMargin - 3, self.textLabel.font.lineHeight);
        
        x = self.leftColumnWidth;
        y = (self.contentView.bounds.size.height - textHeight) / 2;
        self.textField.frame = CGRectMake(x, y, self.contentView.bounds.size.width - x - horizontalMargin, textHeight);
    }
    else if(cellStyle == UITableViewCellStyleSubtitle)
    {
        CGFloat y = (self.contentView.bounds.size.height - self.textLabel.font.lineHeight - self.textField.font.lineHeight) / 2;
        CGFloat contentWidth = self.contentView.bounds.size.width - 2 * horizontalMargin;
        CGFloat x = horizontalMargin;
        
        self.textLabel.frame = CGRectMake(x, y, contentWidth, self.textLabel.font.lineHeight);
        y+= self.textLabel.bounds.size.height;
        self.textField.frame = CGRectMake(x, y, contentWidth, self.textField.font.lineHeight);
    }
    else
    {
        self.textField.frame = CGRectMake(horizontalMargin,
                                          (self.contentView.bounds.size.height - textHeight) / 2,
                                          self.contentView.bounds.size.width - 2*horizontalMargin,
                                          textHeight);
    }
}

@end

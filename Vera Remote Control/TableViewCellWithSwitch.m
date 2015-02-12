//
//  TableViewCellWithSwitch.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/9/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "TableViewCellWithSwitch.h"

@implementation TableViewCellWithSwitch

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.switchView sizeToFit];
        [self.contentView addSubview:self.switchView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    static CGFloat columnGap = 3;
    static CGFloat marginLeft = 10;
    static CGFloat marginRight= 10;
    
    CGFloat x = marginLeft;
    CGFloat y = (self.contentView.bounds.size.height - self.textLabel.font.lineHeightPx) / 2;
    self.textLabel.frame = CGRectMake(x,y, self.contentView.bounds.size.width - marginLeft - marginRight - self.switchView.bounds.size.width - columnGap, self.textLabel.font.lineHeightPx);
    
    x += self.textLabel.bounds.size.width + columnGap;
    y = (self.contentView.bounds.size.height - self.switchView.bounds.size.height)/2;
    
    self.switchView.frame = CGRectOffset(self.switchView.bounds, x, y);
}

@end

//
//  VeraDeviceTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "VeraDeviceTableViewCell.h"
#import "StyleUtils.h"
#import "ObserverUtils.h"


@interface VeraDeviceTableViewCell ()
{
    BOOL dataChanged;
}

@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UILabel * serialNumberLabel;


@end

@implementation VeraDeviceTableViewCell


-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyDefaultStyleOnLabel:self.nameLabel];
        self.nameLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.nameLabel];
        
        
        self.serialNumberLabel  = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyDefaultStyleOnLabel:self.serialNumberLabel];
        self.serialNumberLabel.textColor = [UIColor blackColor];
        
        [self.contentView addSubview:self.serialNumberLabel];
        
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:@[@"veraDevice.name",@"veraDevice.serialNumber"]];
    }
    
    return self;
}


-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:@[@"veraDevice.name",@"veraDevice.serialNumber"]];
}


-(void) layoutSubviews
{
    [super layoutSubviews];

    CGFloat contentWidth = self.contentView.bounds.size.width - [StyleUtils defaultTableCellMargin];
    
    CGFloat x = [StyleUtils defaultTableCellMargin];
    CGFloat y = (self.contentView.bounds.size.height - self.nameLabel.font.lineHeightPx - self.serialNumberLabel.font.lineHeightPx) / 2;
    self.nameLabel.frame = CGRectMake(x, y, contentWidth, self.nameLabel.font.lineHeightPx);
    
    y += self.nameLabel.font.lineHeightPx;
    self.serialNumberLabel.frame = CGRectMake(x, y, contentWidth, self.serialNumberLabel.font.lineHeightPx);
    
    if(dataChanged)
    {
        self.nameLabel.text = self.veraDevice.name;
        self.serialNumberLabel.text = [NSString stringWithFormat:@"#%@",self.veraDevice.serialNumber];
        dataChanged = NO;
    }
}



-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    [self setNeedsLayout];
}


@end

//
//  BinarySwitchTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/21/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "BinarySwitchTableViewCell.h"
#import "StyleUtils.h"
#import "ObserverUtils.h"

@interface BinarySwitchTableViewCell()
{
    BOOL layoutChanged;
    BOOL dataChanged;

    CGSize oldSize;
}


@end

@implementation BinarySwitchTableViewCell


-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        
        self.deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:self.deviceNameLabel];
        [self.contentView addSubview:self.deviceNameLabel];
        
        
        self.statusView = [[CircularShapeView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.statusView.fillColor = [UIColor redColor];
        self.statusView.strokeColor = [UIColor blackColor];
        self.statusView.hidden = YES;
        [self.contentView addSubview:self.statusView];
        
        self.progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        self.progressView.color = [UIColor blueColor];
        [self.progressView sizeToFit];
        self.progressView.hidden = YES;
        [self.contentView addSubview:self.progressView];
        
        self.switchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.switchView sizeToFit];
        [self.contentView addSubview:self.switchView];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        oldSize = self.bounds.size;
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerKeyPaths]];
        
        
        [self.switchView addTarget:self action:@selector(handleSwitchOnOff:) forControlEvents:UIControlEventValueChanged];
        self.didTurnSwitchOnOrOff = nil;
    }
    
    return self;
}


-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerKeyPaths]];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    if(oldSize.width != self.bounds.size.width || oldSize.height != self.bounds.size.height)
    {
        static CGFloat marginSide = 5;
        static CGFloat columnGap = 3;
    
        CGFloat contentWidth = self.contentView.bounds.size.width;
        
        // status and progress column
        CGFloat columnWidth  = 26;
        CGFloat x = (columnWidth - self.statusView.bounds.size.width) / 2;
        CGFloat y = (self.contentView.bounds.size.height - self.statusView.bounds.size.height) / 2;
        
        self.statusView.frame = CGRectOffset(self.statusView.bounds, x, y);
        
        x = (columnWidth - self.progressView.bounds.size.width) / 2;
        y = (self.contentView.bounds.size.height - self.progressView.bounds.size.height) / 2;
        self.progressView.frame = CGRectOffset(self.progressView.bounds, x, y);
        
        
        // device name
        
        x += columnWidth;
        columnWidth = contentWidth - x - self.switchView.bounds.size.width - marginSide;
        y = (self.contentView.bounds.size.height - self.deviceNameLabel.font.lineHeightPx) / 2;
        self.deviceNameLabel.frame = CGRectMake(x, y, columnWidth - columnGap, self.deviceNameLabel.font.lineHeightPx);
        x += columnWidth;
        
        y = (self.contentView.bounds.size.height - self.switchView.bounds.size.height)/2;
        self.switchView.frame = CGRectOffset(self.switchView.bounds, x, y);
        
        oldSize = self.bounds.size;
    }
    
    if(dataChanged)
    {
        BOOL value = self.device.manualOverride ? self.device.manualValue : self.device.value;
        BOOL busy = self.device.manualOverride || self.device.state == DeviceStateBusy;
        
        self.switchView.on = value;
        self.deviceNameLabel.text = self.device.name;
        if(busy)
        {
            self.statusView.hidden = YES;
            
            self.progressView.hidden = NO;
            [self.progressView startAnimating];
        }
        else
        {
            self.progressView.hidden = YES;
            [self.progressView stopAnimating];
            
            self.statusView.hidden = self.device.state != DeviceStateError;
        }
        
        
        
        dataChanged = NO;
    }
    
}


#pragma mark -
#pragma mark event handlers
-(void) handleSwitchOnOff:(UISwitch *) sender
{
    if(self.didTurnSwitchOnOrOff != nil)
    {
        self.didTurnSwitchOnOrOff(self);
    }
}

#pragma mark -
#pragma mark misc 
-(NSArray *) observerKeyPaths
{
    static NSArray * paths = nil;
    if(paths == nil)
    {
        paths = @[@"device.name",@"device.state",@"device.value",@"device.manualValue",@"device.manualOverride"];
    }
    
    return paths;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    [self setNeedsLayout];
}

@end

//
//  DimmableSwitchTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DimmableSwitchTableViewCell.h"
#import "StyleUtils.h"
#import "ObserverUtils.h"


@interface DimmableSwitchTableViewCell ()
{
    BOOL dataChanged;
    CGSize oldSize;
}


@end

@implementation DimmableSwitchTableViewCell

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
        
        self.onOffSwitchView = [[UISwitch alloc] initWithFrame:CGRectZero];
        [self.onOffSwitchView sizeToFit];
        [self.contentView addSubview:self.onOffSwitchView];
        
        self.levelSliderView = [[UISlider alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
        self.levelSliderView.minimumValue = 0;
        self.levelSliderView.maximumValue = 100;
        self.levelSliderView.continuous = NO;
        self.levelSliderView.userInteractionEnabled = YES;
        
        
        [self.contentView addSubview:self.levelSliderView];
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerKeyPaths]];
        
        [self.onOffSwitchView addTarget:self action:@selector(handleOnOffSwitch:) forControlEvents:UIControlEventValueChanged];
        [self.levelSliderView addTarget:self action:@selector(handleLevelSlider:) forControlEvents:UIControlEventValueChanged];
        
        self.didSetValue = nil;
        oldSize = self.bounds.size;
    }
    
    return self;
}


-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerKeyPaths]];
}


-(void) layoutSubviews
{
    if(!CGSizeEqualToSize(oldSize, self.bounds.size))
    {
        [super layoutSubviews];
        static CGFloat margin = 5;
        
        CGFloat row1Height = MAX(self.progressView.bounds.size.height, self.deviceNameLabel.font.lineHeightPx);
        CGFloat row2Height = MAX(self.onOffSwitchView.bounds.size.height, self.levelSliderView.bounds.size.height);
        
        CGFloat columnWidth = 26;
        
        CGFloat x = 0;
        CGFloat y = (self.contentView.bounds.size.height - row1Height - row2Height) / 2;
        
        
        self.statusView.frame = CGRectMake(x + (columnWidth - self.statusView.bounds.size.width) / 2,
                                           y + (row1Height - self.statusView.bounds.size.height)/2,
                                           self.statusView.bounds.size.width,
                                           self.statusView.bounds.size.height);
        
        
        self.progressView.frame = CGRectMake(x + (columnWidth - self.progressView.bounds.size.width) / 2,
                                             y + (row1Height - self.progressView.bounds.size.height)/2,
                                             self.progressView.bounds.size.width,
                                             self.progressView.bounds.size.height);
        
        
        x += columnWidth;
        
        
        columnWidth = self.contentView.bounds.size.width - x - margin;
        self.deviceNameLabel.frame = CGRectMake(x, y, columnWidth, self.deviceNameLabel.font.lineHeightPx);
        
        y += row1Height;
        self.levelSliderView.frame = CGRectMake(x,
                                                y + (row2Height - self.levelSliderView.bounds.size.height)/2,
                                                columnWidth - self.onOffSwitchView.bounds.size.width - 20,
                                                self.levelSliderView.bounds.size.height);
        
        x += self.levelSliderView.bounds.size.width + 20;
        self.onOffSwitchView.frame = CGRectMake(x,
                                                y + (row2Height - self.onOffSwitchView.bounds.size.height)/2,
                                                self.onOffSwitchView.bounds.size.width,
                                                self.onOffSwitchView.bounds.size.height);
        
        
        oldSize = self.contentView.bounds.size;
    }
    
    if(dataChanged)
    {
        BOOL busy = self.device.state == DeviceStateBusy || self.device.manualOverride;
        NSUInteger value = self.device.manualOverride ? self.device.manualValue : self.device.value;
        
        self.deviceNameLabel.text = self.device.name;
        self.levelSliderView.value = (float) value;
        self.onOffSwitchView.on = value != 0;
        
        
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
#pragma mark events
-(void) handleOnOffSwitch:(UISwitch *) sender
{
    [self.levelSliderView setValue:(sender.on ? 100 : 0) animated:YES];
    if(self.didSetValue != nil)
    {
        self.didSetValue(self);
    }
}


-(void) handleLevelSlider:(UISlider *) sender
{
    [self.onOffSwitchView setOn:sender.value != 0 animated:YES];
    if(self.didSetValue != nil)
    {
        self.didSetValue(self);
    }
}




#pragma mark -
#pragma mark KVO
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

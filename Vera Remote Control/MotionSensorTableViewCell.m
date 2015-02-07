//
//  MotionSensorTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/6/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "MotionSensorTableViewCell.h"
#import "CircularShapeView.h"
#import "BatteryLevelView.h"
#import "StyleUtils.h"
#import "ObserverUtils.h"

@interface MotionSensorTableViewCell ()
{
    BOOL dataChanged;
    CGSize oldSize;
}

@property (nonatomic, strong) CircularShapeView * statusView;
@property (nonatomic, strong) UIActivityIndicatorView * progressView;
@property (nonatomic, strong) UILabel * deviceNameLabel;
@property (nonatomic, strong) CircularShapeView * trippedStatusView;
@property (nonatomic, strong) BatteryLevelView  * batteryLevelView;
@property (nonatomic, strong) UISegmentedControl * controlView;


@end

@implementation MotionSensorTableViewCell


-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])
    {
        self.statusView = [[CircularShapeView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.statusView.fillColor = [UIColor redColor];
        [self.contentView addSubview:self.statusView];
        
        self.progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        self.progressView.color = [UIColor blueColor];
        [self.progressView sizeToFit];
        self.progressView.hidden = YES;
        [self.contentView addSubview:self.progressView];
        
        
        self.deviceNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:self.deviceNameLabel];
        [self.contentView addSubview:self.deviceNameLabel];
        
        self.trippedStatusView = [[CircularShapeView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.trippedStatusView.strokeColor = [UIColor blackColor];
        [self.contentView addSubview:self.trippedStatusView];

        self.batteryLevelView = [[BatteryLevelView alloc] initWithFrame:CGRectZero];
        [self.batteryLevelView sizeToFit];
        [self.contentView addSubview:self.batteryLevelView];
        
        self.controlView = [[UISegmentedControl alloc] initWithItems:@[@"Armed",@"Bypass"]];
        self.controlView.frame = CGRectMake(0, 0, 200, 35);
        [self.controlView addTarget:self action:@selector(handleControlViewAction:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.controlView];
        
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.didChangeArmedStatus = nil;
        
        oldSize = CGSizeZero;
        dataChanged = YES;
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self oberserKeyPaths] withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
    }
    
    return self;
}

-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self oberserKeyPaths]];
}

-(void) layoutSubviews
{
    [super layoutSubviews];
    
    if(!CGSizeEqualToSize(oldSize, self.bounds.size))
    {
        static CGFloat firstColumnWidth = 26;
        static CGFloat marginSide = 5;
        static CGFloat columnGap = 3;
        static CGFloat rowGap = 5;
        
        CGFloat contentWidth = self.contentView.bounds.size.width - marginSide;
        
        // status and progress column
        CGFloat columnWidth  = firstColumnWidth;
        CGFloat x = (columnWidth - self.statusView.bounds.size.width) / 2;
        CGFloat y = (self.contentView.bounds.size.height - self.deviceNameLabel.font.lineHeightPx - self.controlView.bounds.size.height - rowGap)/2;
        
        self.statusView.frame = CGRectMake(x + (columnWidth - self.statusView.bounds.size.width)/2, y, self.statusView.bounds.size.width, self.statusView.bounds.size.height);
        
        x = (columnWidth - self.progressView.bounds.size.width) / 2;
        self.progressView.frame = CGRectOffset(self.progressView.bounds, x, y + (self.deviceNameLabel.font.lineHeightPx - self.progressView.bounds.size.height)/2);
        
        
        x += columnWidth;
        
        columnWidth = contentWidth - x - self.trippedStatusView.bounds.size.width;
        self.deviceNameLabel.frame = CGRectMake(x, y, columnWidth - columnGap, self.deviceNameLabel.font.lineHeightPx);
        x += columnWidth;
        self.trippedStatusView.frame = CGRectOffset(self.trippedStatusView.bounds, x, y);
        y += self.deviceNameLabel.bounds.size.height + rowGap;
        
        
        x = firstColumnWidth + 4;
        self.batteryLevelView.frame = CGRectOffset(self.batteryLevelView.bounds, x, y + self.controlView.bounds.size.height - self.batteryLevelView.bounds.size.height);
        
        x = self.contentView.bounds.size.width - marginSide - self.controlView.bounds.size.width;
        self.controlView.frame = CGRectOffset(self.controlView.bounds, x, y);
        
        oldSize = self.contentView.bounds.size;
    }
    
    if(dataChanged)
    {
        BOOL busy = self.sensor.manualOverride || self.sensor.state == DeviceStateBusy;
        
        self.deviceNameLabel.text = self.sensor.name;
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
            self.statusView.hidden = self.sensor.state != DeviceStateError;
        }
        
        
        self.trippedStatusView.fillColor = self.sensor.tripped ? [UIColor colorWithRGBHex:0x85d966] : [UIColor lightGrayColor];
        
        self.batteryLevelView.hidden = self.sensor.batteryLevel < 0;
        if(self.sensor.batteryLevel > -1)
        {
            self.batteryLevelView.level = self.sensor.batteryLevel;
        }
        
        BOOL armed = self.sensor.manualOverride ? self.sensor.manualArmed : self.sensor.armed;
        self.controlView.selectedSegmentIndex = armed ? 0 : 1;
        dataChanged = YES;
    }
}


#pragma mark -
#pragma mark events
-(void) handleControlViewAction:(UISegmentedControl *) sender
{
    if(self.didChangeArmedStatus != nil)
    {
        self.didChangeArmedStatus(self.sensor, sender.selectedSegmentIndex == 0);
    }
}

#pragma mark -
#pragma mark KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    [self setNeedsLayout];
}

-(NSArray *) oberserKeyPaths
{
    return @[@"sensor.tripped",@"sensor.batteryLevel",@"sensor.armed",@"sensor.manualArmed",@"sensor.manualOverride",@"sensor.state",@"sensor.batteryLevel"];
}

@end

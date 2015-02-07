//
//  SensorTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/4/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SensorTableViewCell.h"
#import "ObserverUtils.h"
#import "StyleUtils.h"

@interface SensorTableViewCell()
{
    BOOL dataChanged;
    CGSize oldSize;
}


@property (nonatomic, strong) CircularShapeView * statusView;
@property (nonatomic, strong) UILabel * deviceNameLabel;
@property (nonatomic, strong) UILabel * readingLabel;

-(void) commitProperties;
-(NSArray *) observerKeyPaths;


@end

@implementation SensorTableViewCell


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
        
        self.readingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.readingLabel.backgroundColor = [UIColor clearColor];
        self.readingLabel.textColor = [UIColor darkGrayColor];
        self.readingLabel.textAlignment = NSTextAlignmentRight;
        self.readingLabel.font = [UIFont defaultBoldFontWithSize:30];
        
        [self.contentView addSubview:self.readingLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        oldSize = CGSizeZero;
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerKeyPaths]];
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
        static CGFloat marginRight= 10;
        static CGFloat columnGap = 3;
        
        
        CGFloat contentWidth = self.contentView.bounds.size.width;
        
        // status and progress column
        CGFloat columnWidth  = 26;
        CGFloat x = (columnWidth - self.statusView.bounds.size.width) / 2;
        CGFloat y = (self.contentView.bounds.size.height - self.self.deviceNameLabel.font.lineHeight - self.readingLabel.font.lineHeight) / 2;
        
        self.statusView.frame = CGRectOffset(self.statusView.bounds, x, y + (self.deviceNameLabel.font.lineHeightPx - self.statusView.bounds.size.height)/2);
        
        // device name
        
        x += columnWidth;
        columnWidth = contentWidth - x - marginRight;
        self.deviceNameLabel.frame = CGRectMake(x, y, columnWidth - columnGap, self.deviceNameLabel.font.lineHeightPx);
        
        y += self.deviceNameLabel.bounds.size.height;
        self.readingLabel.frame = CGRectMake(x, y, columnWidth, self.readingLabel.font.lineHeightPx);
        
        oldSize = self.contentView.bounds.size;
    }
    
    if(dataChanged)
    {
        [self commitProperties];
        dataChanged = NO;
    }
}

-(void) commitProperties
{
    // do nothing
}


#pragma mark -
#pragma mark misc
-(NSArray *) observerKeyPaths
{
    return nil;
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    [self setNeedsLayout];
}


@end


@implementation TemperatureSensorTableViewCell

-(void) commitProperties
{
    self.deviceNameLabel.text = self.sensor.name;
    self.readingLabel.text = [NSString stringWithFormat:@"%d%@", self.sensor.temperature, self.temperatureUnit];
    self.statusView.hidden = self.sensor.state != DeviceStateError;
}

-(NSArray *) observerKeyPaths
{
    static NSArray * paths = nil;
    
    if(paths == nil)
    {
        paths = @[@"temperatureUnit",@"sensor.name",@"sensor.state",@"sensor.manualOverride",@"sensor.temperature"];
    }
    
    return paths;
}

@end



@implementation LightSensorTableViewCell

-(void) commitProperties
{
    self.deviceNameLabel.text = self.sensor.name;
    self.readingLabel.text = [NSString stringWithFormat:@"%d", self.sensor.light];
    self.statusView.hidden = self.sensor.state != DeviceStateError;
}

-(NSArray *) observerKeyPaths
{
    static NSArray * paths = nil;
    
    if(paths == nil)
    {
        paths = @[@"sensor.name",@"sensor.state",@"sensor.manualOverride",@"sensor.light"];
    }
    
    return paths;
}

@end


@implementation HumiditySensorTableViewCell

-(void) commitProperties
{
    self.deviceNameLabel.text = self.sensor.name;
    self.readingLabel.text = [NSString stringWithFormat:@"%d%%", self.sensor.humidity];
    self.statusView.hidden = self.sensor.state != DeviceStateError;
}

-(NSArray *) observerKeyPaths
{
    static NSArray * paths = nil;
    
    if(paths == nil)
    {
        paths = @[@"sensor.name",@"sensor.state",@"sensor.manualOverride",@"sensor.humidity"];
    }
    
    return paths;
}

@end


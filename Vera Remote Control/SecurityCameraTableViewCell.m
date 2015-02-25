//
//  SecurityCameraTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/22/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SecurityCameraTableViewCell.h"
#import "CircularShapeView.h"
#import "StyleUtils.h"
#import "PropertyInvalidator.h"
#import "ObserverUtils.h"

@interface SecurityCameraTableViewCell () <Invalidatable>

@property (nonatomic, strong) CircularShapeView * statusView;
@property (nonatomic, strong) UILabel * deviceNameLabel;
@property (nonatomic, strong) PropertyInvalidator * propertyInvalidator;

@end

@implementation SecurityCameraTableViewCell


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
        
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerKeyPaths] withOptions:NSKeyValueObservingOptionNew];
        
    }
    
    return self;
}



-(void) layoutSubviews
{
    [super layoutSubviews];
    
    static CGFloat marginSide = 5;
    static CGFloat columnGap = 3;
    
    CGFloat contentWidth = self.contentView.bounds.size.width;
    
    // status and progress column
    CGFloat columnWidth  = 26;
    CGFloat x = (columnWidth - self.statusView.bounds.size.width) / 2;
    CGFloat y = (self.contentView.bounds.size.height - self.statusView.bounds.size.height) / 2;
    x = columnGap + columnWidth;
    columnWidth = contentWidth - x - marginSide;
    y = (self.contentView.bounds.size.height - self.deviceNameLabel.font.lineHeightPx)/2;
    self.deviceNameLabel.frame = CGRectMake(x, y, contentWidth, self.deviceNameLabel.font.lineHeightPx);
}


#pragma mark -
#pragma mark Invalidatable implementation
-(void) commitProperties
{
    self.statusView.hidden = self.camera.state != DeviceStateError;
    self.deviceNameLabel.text = self.camera.name;
}


#pragma mark -
#pragma mark KVO
-(NSArray *) observerKeyPaths
{
    return @[@"camera.name",@"camera.state"];
}

-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.propertyInvalidator invalidateProperties];
}



@end

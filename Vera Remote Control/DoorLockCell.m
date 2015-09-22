//
//  DoorLockCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 9/17/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "DoorLockCell.h"
#import "Binder.h"
#import "PropertyInvalidator.h"
#import "CircularShapeView.h"
#import "StyleUtils.h"

@interface DoorLockCell () <Invalidatable>

@property (nonatomic) UILabel *deviceNameLabel;
@property (nonatomic) UISegmentedControl *switchControl;
@property (nonatomic) CircularShapeView *statusView;
@property (nonatomic) UIActivityIndicatorView *progressView;

@property (nonatomic) Binder *binder;
@property (nonatomic) PropertyInvalidator *propertyInvalidator;
@property (nonatomic) CGSize oldSize;

@end


@implementation DoorLockCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
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
        
        self.switchControl = [[UISegmentedControl alloc] initWithItems:@[@"Locked",@"Unlocked"]];
        self.switchControl.bounds = CGRectMake(0, 0, 200, 35);
        [self.contentView addSubview:self.switchControl];
        
        [self.switchControl addTarget:self action:@selector(handleSegmentedControlValueChange:) forControlEvents:UIControlEventValueChanged];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        __weak typeof(self)weakSelf = self;
        self.binder = [[Binder alloc] initWithObject:self
                                            keyPaths:@[K(doorLock.name),K(doorLock.state),K(doorLock.locked),K(doorLock.manualLocked),K(doorLock.manualOverride)]
                                            callback:^{
                                                [weakSelf.propertyInvalidator invalidateProperties];
                                            }];
        self.propertyInvalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
        [self.binder startObserving];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if(self.oldSize.width != self.bounds.size.width || self.oldSize.height != self.bounds.size.height)
    {
        static CGFloat marginSide = 5;
        
        CGFloat contentWidth = self.contentView.bounds.size.width;
        static CGFloat columnGap = 3;
        static CGFloat rowGap = 5;
        
        // status and progress column
        CGFloat columnWidth  = 26;
        CGFloat x = (columnWidth - self.statusView.bounds.size.width) / 2;
        //CGFloat y = (self.contentView.bounds.size.height - self.statusView.bounds.size.height) / 2;
        CGFloat y = (self.contentView.bounds.size.height - self.deviceNameLabel.font.lineHeightPx - self.switchControl.bounds.size.height - rowGap)/2;
        CGFloat dY = (self.deviceNameLabel.font.lineHeightPx - self.statusView.bounds.size.height)/2;
        
        self.statusView.frame = CGRectOffset(self.statusView.bounds, x, y + dY);
        
        
        x = (columnWidth - self.progressView.bounds.size.width) / 2;
        dY = (self.deviceNameLabel.font.lineHeightPx - self.progressView.bounds.size.height)/2;
        self.progressView.frame = CGRectOffset(self.progressView.bounds, x, y + dY);
        
        // device name
        x = columnWidth + columnGap;
        y = (self.contentView.bounds.size.height - self.deviceNameLabel.font.lineHeightPx - self.switchControl.bounds.size.height)/2;
        self.deviceNameLabel.frame = CGRectMake(x, y, contentWidth, self.deviceNameLabel.font.lineHeightPx);
        
        y += self.deviceNameLabel.bounds.size.height + rowGap;
        x = self.contentView.bounds.size.width - self.switchControl.bounds.size.width - marginSide;
        self.switchControl.frame = CGRectMake(x, y, self.switchControl.bounds.size.width, self.switchControl.bounds.size.height);
        
        self.oldSize = self.contentView.bounds.size;
    }
}

#pragma mark - Invalidatable implementation

- (void)commitProperties {
    BOOL value = self.doorLock.manualOverride ? self.doorLock.manualLocked : self.doorLock.locked;
    BOOL busy = self.doorLock.manualOverride || self.doorLock.state == DeviceStateBusy;
    
    
    self.switchControl.enabled = !busy;
    self.switchControl.selectedSegmentIndex = value ? 0 : 1;
    self.deviceNameLabel.text = self.doorLock.name;
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
        
        self.statusView.hidden = self.doorLock.state != DeviceStateError;
    }
}


#pragma mark - events / notifications


- (void)handleSegmentedControlValueChange:(UISegmentedControl *)control {
    BOOL newValue = control.selectedSegmentIndex == 0;
    control.selectedSegmentIndex = newValue ? 1 : 0;
    if (self.willCommitValue != nil)
    {
        self.willCommitValue(newValue);
    }
}


@end

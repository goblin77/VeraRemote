//
//  DevicesViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/19/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "VeraDevicesViewController.h"
#import "ObserverUtils.h"
#import "StyleUtils.h"
#import "VeraDeviceTableViewCell.h"
#import "dispatch_cancelable_block.h"


@interface VeraDevicesViewController ()
{
    dispatch_cancelable_block_t scheduledCommitProperties;
}


@end


static CGFloat HomeDevicesRowHeight = 60;

@implementation VeraDevicesViewController


-(id) init
{
    if(self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.didSelectDevice = nil;
        scheduledCommitProperties = nil;
    }
    
    return self;
}



-(void) dealloc
{
    if(scheduledCommitProperties != nil)
    {
        cancel_block(scheduledCommitProperties);
        scheduledCommitProperties = nil;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.deviceManager = [DeviceManager sharedInstance];
    
    self.navigationItem.title = @"Vera Devices";
}


-(void) viewWillAppear:(BOOL)animated
{
    [ObserverUtils addObserver:self toObject:self.deviceManager
                   forKeyPaths:[self observerKeyPaths]
                   withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [ObserverUtils removeObserver:self fromObject:self.deviceManager forKeyPaths:[self observerKeyPaths]];
}


#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(self.deviceManager.availableVeraDevicesLoading && self.deviceManager.availableVeraDevices.count == 0)
    {
        return 0;
    }
    
    if(self.deviceManager.availableVeraDevices.count == 0)
    {
        return 1;
    }
    
    return self.deviceManager.availableVeraDevices.count;
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return HomeDevicesRowHeight;
}



-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.deviceManager.availableVeraDevices.count == 0)
    {
        UITableViewCell * res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
        res.textLabel.text = @"No devices found";
        res.selectionStyle = UITableViewCellSelectionStyleNone;
        return res;
    }
    
    
    static NSString * CellId = @"VeraTableCell";
    
    VeraDeviceTableViewCell * res  = (VeraDeviceTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellId];
    if(res == nil)
    {
        res = [[VeraDeviceTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellId];
        res.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    VeraDevice * veraDevice = self.deviceManager.availableVeraDevices[indexPath.row];
    
    res.veraDevice = veraDevice;
    res.accessoryType = [veraDevice.serialNumber isEqualToString:self.deviceManager.currentDevice.serialNumber] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return res;
}



-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.deviceManager.availableVeraDevices.count == 0)
    {
        return;
    }
    
    
    VeraDevice * device = self.deviceManager.availableVeraDevices[indexPath.row];
    if(self.didSelectDevice != nil)
    {
        self.didSelectDevice(device);
    }
}

#pragma mark -
#pragma mark invalidation
-(void) invalidateProperties
{
    if(scheduledCommitProperties == nil)
    {
        __weak VeraDevicesViewController * thisObject = self;
        scheduledCommitProperties = dispatch_after_delay(0.1, ^{
            [thisObject commitProperties];
            scheduledCommitProperties = nil;
        });
    }
}


-(void) commitProperties
{
    [self.tableView reloadData];
}

#pragma mark -
#pragma mark misc functions
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self invalidateProperties];
}

-(NSArray *) observerKeyPaths
{
    return @[@"availableVeraDevices",@"availableVeraDevicesLoading",@"currentDevice"];
}



@end

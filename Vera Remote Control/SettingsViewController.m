//
//  SettingsViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 2/6/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SettingsViewController.h"
#import "WidgetSettingsViewController.h"
#import "StyleUtils.h"
#import "MainAppWidgetSettingsManager.h"

typedef NS_ENUM(NSInteger, SettingsSection)
{
    SettingsSectionApp,
    SettingsSectionSupport
};


typedef NS_ENUM(NSInteger, AppSettingsRow)
{
    AppSettingsRowHomeDevice = 0,
    AppSettingsRowWidgets
};


typedef NS_ENUM(NSInteger, SupportRow)
{
    SuportRowVersion = 0,
    SupportRowContactSupport,
    SupportRowFAQ
};



@interface SettingsViewController ()


@end

@implementation SettingsViewController


-(id) init
{
    if(self = [super initWithStyle:UITableViewStyleGrouped])
    {
        
    }
    
    return self;
}


-(void) viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Settings";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out" style:UIBarButtonItemStylePlain target:nil action:nil];
}


-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == SettingsSectionApp ? 2 : 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SettingsSectionApp)
    {
        if(indexPath.row == AppSettingsRowHomeDevice)
        {
            static NSString * CellId = @"HomeDeviceCellId";
            
            UITableViewCell * res = [tableView dequeueReusableCellWithIdentifier:CellId];
            if(res == nil)
            {
                res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
                res.detailTextLabel.numberOfLines = 0;
                res.detailTextLabel.lineBreakMode = NSLineBreakByWordWrapping;
                [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
                [StyleUtils applyDefaultStyleOnValueLabelWithTableCell:res.detailTextLabel];
                res.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                
            }
            
            
            res.textLabel.text = @"Home Device";
            res.detailTextLabel.text = [NSString stringWithFormat:@"%@\n#%@", self.deviceManager.currentDevice.name, self.deviceManager.currentDevice.serialNumber];
            
            return res;
        }
        else if(indexPath.row == AppSettingsRowWidgets)
        {
            static NSString * CellId = @"WidgetsCellId";
            
            UITableViewCell * res = [tableView dequeueReusableCellWithIdentifier:CellId];
            if(res == nil)
            {
                res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
                [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
                [StyleUtils applyDefaultStyleOnValueLabelWithTableCell:res.detailTextLabel];
                res.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                res.textLabel.text = @"Widgets";
            }
            
            NSString * numSelectedStr = self.widgetSettingsManager.widgetSceneIds.count > 0 ? [NSString stringWithFormat:@"%d", (int)self.widgetSettingsManager.widgetSceneIds.count] : @"none";
            
            res.detailTextLabel.text = numSelectedStr;
            
            return res;
        }
    }
    else if(indexPath.section == SettingsSectionSupport)
    {

    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == SettingsSectionApp)
    {
        return @"Application Settings";
    }
    
    return @"Support";
}


-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SettingsSectionApp && indexPath.row == AppSettingsRowHomeDevice)
    {
        return 60;
    }
    
    return 50;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == SettingsSectionApp)
    {
        if(indexPath.row == AppSettingsRowWidgets)
        {
            WidgetSettingsViewController * vc = [[WidgetSettingsViewController alloc] init];
            vc.widgetSettingsManager = [MainAppWidgetSettingsManager sharedInstance];
            vc.deviceManager = self.deviceManager;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}








@end

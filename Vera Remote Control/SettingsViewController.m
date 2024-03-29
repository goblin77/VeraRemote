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
#import "VeraDevicesViewController.h"
#import "UIAlertViewWithCallbacks.h"
#import "TipJarViewControllerTableViewController.h"
#import <MessageUI/MessageUI.h>
#import "UIViewController+DeepLinking.h"


typedef NS_ENUM(NSInteger, SettingsSection)
{
    SettingsSectionApp,
    SettingsSectionTipJar,
    SettingsSectionSupport
};


typedef NS_ENUM(NSInteger, AppSettingsRow)
{
    AppSettingsRowHomeDevice = 0,
    AppSettingsRowWidgets
};


typedef NS_ENUM(NSInteger, SupportRow)
{
    SupportRowVersion = 0,
    SupportRowContactSupport,
    SupportRowFAQ
};



@interface SettingsViewController () <MFMailComposeViewControllerDelegate>


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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Log out"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(handleLogoutTapped:)];
}

-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section)
    {
        case SettingsSectionApp: return 2;
        case SettingsSectionTipJar: return 1;
        case SettingsSectionSupport: return 2;
    }
    
    return 0;
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
                res.textLabel.text = @"Widget Scenes";
            }
            
            NSString * numSelectedStr = self.widgetSettingsManager.widgetSceneIds.count > 0 ? [NSString stringWithFormat:@"%d", (int)self.widgetSettingsManager.widgetSceneIds.count] : @"none";
            
            res.detailTextLabel.text = numSelectedStr;
            
            return res;
        }
    }
    else if(indexPath.section == SettingsSectionTipJar)
    {
        static NSString * CellId = @"TipJar";
        
        UITableViewCell * res = [tableView dequeueReusableCellWithIdentifier:CellId];
        if(res == nil)
        {
            res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
            [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
            res.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            //res.textLabel.font = [UIFont defaultFontWithSize:12];
            res.textLabel.numberOfLines = 0;
            res.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
            res.textLabel.text = @"Leave a Tip";
            res.detailTextLabel.text = @"Support HomePal development.";
        }
        
        
        return res;
        
    }
    else if(indexPath.section == SettingsSectionSupport)
    {
        if(indexPath.row == SupportRowVersion)
        {
            static NSString * CellId = @"VersionCell";
            UITableViewCell * res = [tableView dequeueReusableCellWithIdentifier:CellId];
            if(res == nil)
            {
                res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
                [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
                [StyleUtils applyDefaultStyleOnValueLabelWithTableCell:res.detailTextLabel];
                res.textLabel.text = @"Version";
                res.detailTextLabel.text = [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"];
                res.selectionStyle = UITableViewCellSeparatorStyleNone;
            }
            
            return res;
        }
        else if (indexPath.row == SupportRowContactSupport)
        {
            static NSString * CellId = @"ContactSupport";
            
            UITableViewCell *res = [tableView dequeueReusableCellWithIdentifier:CellId];
            if (res == nil)
            {
                res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellId];
                [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
                res.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                res.textLabel.numberOfLines = 0;
                res.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                res.textLabel.text = @"Contact Support";
                res.detailTextLabel.text = @"Your questions and feedback are very welcome.";
            }
            
            return res;
        }
    }
    
    return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == SettingsSectionApp)
    {
        return @"Application Settings";
    }
    else if (section == SettingsSectionTipJar)
    {
        return @"Tip Jar";
    }
    
    return @"Support";
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == SettingsSectionApp && indexPath.row == AppSettingsRowHomeDevice)
    {
        return 60;
    }
    else if(indexPath.section == SettingsSectionTipJar)
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
        else if(indexPath.row == AppSettingsRowHomeDevice)
        {
            __weak SettingsViewController * thisObject = self;
            VeraDevicesViewController * vc = [[VeraDevicesViewController alloc] init];
            vc.deviceManager = self.deviceManager;
            vc.didSelectDevice = ^(VeraDevice * device)
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SetSelectedVeraDeviceNotification object:device];
                [thisObject.navigationController popViewControllerAnimated:YES];
            };
            
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if (indexPath.section == SettingsSectionTipJar)
    {
        TipJarViewControllerTableViewController *vc = [[TipJarViewControllerTableViewController alloc] init];
        vc.productManager = self.productManager;
        vc.navigationItem.title = @"Tip Jar";
        [self presentViewController:[[UINavigationController alloc] initWithRootViewController:vc] animated:YES completion:nil];
    }
    else if (indexPath.section == SettingsSectionSupport)
    {
        if (indexPath.row == SupportRowContactSupport)
        {
            [self displayEmailControls];
        }
    }
}

#pragma mark -
#pragma mark Deep linking
- (void)processURLPathComponents:(NSArray *)pathComponents completion:(void (^)(void))completion
{
    if ([pathComponents.firstObject isEqualToString:@"widgets"])
    {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:AppSettingsRowWidgets inSection:SettingsSectionApp]];
    }
    
    completion();
}


#pragma mark -
#pragma mark events
-(void) handleLogoutTapped:(id) sender
{
    UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                               message:@"Are you sure you want to log out?"
                                                                     cancelButtonTitle:@"Cancel"
                                                                     otherButtonTitles:@"Log out", nil];
    
    alert.alertViewWillDismissWithButtonIndex = ^(UIAlertView * av, NSUInteger buttonIndex)
    {
        if(buttonIndex == 1)
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:LogoutNotification object:nil];
        }
    };
    
    [alert show];
    
}

#pragma mark - MFMailComposeViewControllerDelegate implementation
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    if (result == MFMailComposeResultSent)
    {
       [[[UIAlertView alloc] initWithTitle:@""
                                   message:@"Thank you for your feedback!"
                                  delegate:nil
                         cancelButtonTitle:@"Dismiss"
                         otherButtonTitles: nil] show];
    }
}

#pragma mark -
#pragma mark misc functions
- (void) displayEmailControls
{
    MFMailComposeViewController *emailVC = [[MFMailComposeViewController alloc] init];
    [emailVC setSubject:@"RE: HomePal"];
    [emailVC setToRecipients:@[@"dmitry@coldfishinc.com"]];
    emailVC.mailComposeDelegate = self;
    
    NSString *emailBody = [NSString stringWithFormat:@"<br><br><br><hr>App Version : <strong>%@</strong>", [NSBundle mainBundle].infoDictionary[@"CFBundleVersion"]];
    [emailVC setMessageBody:emailBody isHTML:YES];
    [self presentViewController:emailVC animated:YES completion:nil];
}

@end

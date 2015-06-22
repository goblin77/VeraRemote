//
//  CredentialsViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/18/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "CredentialsViewController.h"
#import "TableViewCellWithTextField.h"
#import "DefaultTextFieldDelegate.h"
#import "UIAlertViewWithCallbacks.h"
#import "LargeProgressView.h"
#import "ObserverUtils.h"
#import "VeraDevicesViewController.h"


@interface CredentialsViewController ()

@property (nonatomic, strong) NSString * username;
@property (nonatomic, strong) NSString * password;


@property (nonatomic, strong) DefaultTextFieldDelegate * loginDelegate;
@property (nonatomic, strong) DefaultTextFieldDelegate * passwordDelegate;

@end


@implementation CredentialsViewController


-(id) init
{
    if(self = [super initWithStyle:UITableViewStyleGrouped])
    {
        self.loginDelegate = nil;
        self.passwordDelegate = nil;
    }
    
    return self;
}

-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self.deviceManager forKeyPaths:[self observerKeyPaths]];
}




-(void) viewDidLoad
{
    [super viewDidLoad];
    self.username = self.deviceManager.username;
    self.password = self.deviceManager.password;
    
    
    self.navigationItem.title = @"Login";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticationSuccess:) name:AuthenticationSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAuthenticationFailed:) name:AuthenticationFailedNotification object:nil];
}


-(void) viewWillAppear:(BOOL)animated
{
    [ObserverUtils addObserver:self toObject:self.deviceManager forKeyPaths:[self observerKeyPaths]];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [ObserverUtils removeObserver:self fromObject:self.deviceManager forKeyPaths:[self observerKeyPaths]];
}



-(void) viewDidAppear:(BOOL)animated
{
    if(self.username.length == 0)
    {
        [self tableView:self.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    }
}


#pragma mark -
#pragma mark UITableViewDataSource and UITableViewDelegate
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}


-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    __weak CredentialsViewController * thisObject = self;
    
    if(indexPath.row == 0)
    {
        if(self.loginDelegate == nil)
        {
            self.loginDelegate = [[DefaultTextFieldDelegate alloc] init];
            self.loginDelegate.textFieldDidEndEditing = ^(UITextField * textField)
            {
                thisObject.username = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                textField.text = thisObject.username;
            };
            
            self.loginDelegate.textFieldShouldClear = ^BOOL(UITextField * textField)
            {
                thisObject.username = nil;
                return YES;
            };
            
            self.loginDelegate.textFieldShouldReturn = ^BOOL(UITextField * textField)
            {
                [thisObject tableView:thisObject.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                return YES;
            };
        }
        
        static NSString * UsernameCell = @"UsernameCell";
        TableViewCellWithTextField * res = (TableViewCellWithTextField *)[tableView dequeueReusableCellWithIdentifier:UsernameCell];
        if(res == nil)
        {
            res = [[TableViewCellWithTextField alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:UsernameCell];
            res.textLabel.text = @"username";
            res.textField.textAlignment = NSTextAlignmentRight;
            res.textField.delegate = self.loginDelegate;
            res.textField.returnKeyType = UIReturnKeyNext;
        }
        
        res.textField.text = self.username;
        
        return res;
    }
    else if(indexPath.row == 1)
    {
        
        if(self.passwordDelegate == nil)
        {
            self.passwordDelegate = [[DefaultTextFieldDelegate alloc] init];
            self.passwordDelegate.textFieldDidEndEditing = ^(UITextField * textField)
            {
                thisObject.password = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                textField.text = thisObject.password;
            };
            
            self.passwordDelegate.textFieldShouldClear = ^BOOL(UITextField * textField)
            {
                thisObject.password = nil;
                return YES;
            };
            
            self.passwordDelegate.textFieldShouldReturn = ^BOOL(UITextField * textField)
            {
                [thisObject validateAndSubmitCredentials];
                return YES;
            };
        }
        
        
        static NSString * PasswordCell = @"PasswordCell";
        TableViewCellWithTextField * res = (TableViewCellWithTextField *)[tableView dequeueReusableCellWithIdentifier:PasswordCell];
        if(res == nil)
        {
            res = [[TableViewCellWithTextField alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:PasswordCell];
            res.textLabel.text = @"password";
            res.textField.textAlignment = NSTextAlignmentRight;
            res.textField.secureTextEntry = YES;
            res.textField.returnKeyType = UIReturnKeyDone;
            res.textField.delegate = self.passwordDelegate;
        }
        
        res.textField.text = self.password;
        
        return res;
    }
    
    return nil;
}


-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
    if(cell != nil && [cell isKindOfClass:[TableViewCellWithTextField class]])
    {
        TableViewCellWithTextField * textFieldCell = (TableViewCellWithTextField *)cell;
        [textFieldCell.textField becomeFirstResponder];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


-(NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Vera Credentials (cp.mios.com)";
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 150;
}


#pragma mark -
#pragma mark misc functions
-(void) validateAndSubmitCredentials
{
    [self.view endEditing:YES];
    
    NSIndexPath * indexPath = nil;
    NSString * error = nil;
    
    if(self.username.length == 0)
    {
        error = @"Username cannot be empty";
        indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    }
    
    if(error == nil && self.password.length == 0)
    {
        error = @"Password cannot be empty";
        indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    }
    
    
    __weak CredentialsViewController * thisObject = self;
    
    if(error != nil)
    {
        UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                                   message:error
                                                                         cancelButtonTitle:@"Dismiss"
                                                                         otherButtonTitles:nil];
        alert.alertViewClickedButtonAtIndex = ^(UIAlertView * av, NSUInteger buttonIndex)
        {
            [thisObject tableView:thisObject.tableView didSelectRowAtIndexPath:indexPath];
        };
        
        [alert show];
        return;
    }
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:AuthenticateUserNotification
                                                        object:nil
                                                      userInfo:@{@"username" : self.username,
                                                                 @"password" : self.password}];
    
    
    
}


#pragma mark -
#pragma mark notifications
-(void) handleAuthenticationSuccess:(NSNotification *) notification
{
    __weak CredentialsViewController * thisObject = self;
    //[self dismissViewControllerAnimated:YES completion:nil];
    VeraDevicesViewController * vc = [[VeraDevicesViewController alloc] init];
    vc.deviceManager = self.deviceManager;
    vc.didSelectDevice = ^(VeraDevice * veraDevice)
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:SetSelectedVeraDeviceNotification object:veraDevice];
        [thisObject.navigationController dismissViewControllerAnimated:YES completion:nil];
    };
    
    [self.navigationController pushViewController:vc animated:YES];
    
}


-(void) handleAuthenticationFailed:(NSNotification *) notification
{
    __weak CredentialsViewController * thisObject = self;
    UIAlertViewWithCallbacks * alert = [[UIAlertViewWithCallbacks alloc] initWithTitle:@""
                                                                               message:@"Invalid username/password"
                                                                     cancelButtonTitle:@"Close"
                                                                     otherButtonTitles:nil];
    alert.alertViewClickedButtonAtIndex = ^(UIAlertView * alertView, NSUInteger buttonIndex)
    {
        thisObject.password = nil;
        [thisObject.tableView reloadData];
        [thisObject tableView:thisObject.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    };
    
    [alert show];
}



#pragma mark -
#pragma mark KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if(self.deviceManager.authenticating)
    {
        [LargeProgressView show];
    }
    else
    {
        [LargeProgressView hide];
    }
}

-(NSArray *) observerKeyPaths
{
    return @[@"authenticating"];
}





@end

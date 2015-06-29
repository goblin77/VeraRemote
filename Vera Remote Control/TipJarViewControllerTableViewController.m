//
//  TipJarViewControllerTableViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 6/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "TipJarViewControllerTableViewController.h"
#import "StyleUtils.h"
#import "TipJarSectionHeaderView.h"
#import "UIAlertViewWithCallbacks.h"

typedef NS_ENUM(NSInteger, TipJarRow)
{
    TipJarRowGenerousTip,
    TipJarRowAwesomeTip,
    TipJarRowAmazingTip
};


@interface TipJarViewControllerTableViewController ()

@end

@implementation TipJarViewControllerTableViewController


- (id)init
{
    return [self initWithStyle:UITableViewStyleGrouped];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(handleCancelButtonTapped:)];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellId = @"Cell";
    
    UITableViewCell *res = [tableView dequeueReusableCellWithIdentifier:CellId];
    if (res == nil)
    {
        res = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellId];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:res.textLabel];
        [StyleUtils applyDefaultStyleOnValueLabelWithTableCell:res.detailTextLabel];
        res.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    switch (indexPath.row)
    {
        case TipJarRowGenerousTip:
            res.textLabel.text = @"Generous Tip";
            res.detailTextLabel.text = @"$0.99";
            break;
            
        case TipJarRowAwesomeTip:
            res.textLabel.text = @"Awesome Tip";
            res.detailTextLabel.text = @"$1.99";
            break;
        
        case TipJarRowAmazingTip:
            res.textLabel.text = @"Amazing Tip";
            res.detailTextLabel.text = @"$2.99";
            break;
    }
    
    return res;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    TipJarSectionHeaderView *res = [[TipJarSectionHeaderView alloc] initWithFrame:CGRectZero];
    res.titleLabel.text = @"Vera Remote relies on your support to fund its development. If you find Vera Remote useful and would like to support please, do so by leaving a tip.";
    
    return res;
    
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * productName = @"Generous Tip";
    NSString * priceString = @"$0.99";
    
    if (indexPath.row == 1)
    {
        productName = @"Awesome Tip";
        priceString = @"$1.99";
    }
    else if(indexPath.row == 2)
    {
        productName = @"Amazing Tip";
        priceString = @"$2.99";
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Your In-App Purchase" message:[NSString stringWithFormat:@"Do you want to buy one %@ for %@?",productName,priceString] delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
    [alert show];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120;
}


#pragma mark - event handlers
- (void)handleCancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end

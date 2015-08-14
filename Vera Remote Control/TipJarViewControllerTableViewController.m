//
//  TipJarViewControllerTableViewController.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 6/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

@import StoreKit;

#import "TipJarViewControllerTableViewController.h"
#import "StyleUtils.h"
#import "TipJarSectionHeaderView.h"
#import "UIAlertViewWithCallbacks.h"
#import "LargeProgressView.h"
#import "Binder.h"
#import "PropertyInvalidator.h"


typedef NS_ENUM(NSInteger, TipJarRow)
{
    TipJarRowGenerousTip,
    TipJarRowAwesomeTip,
    TipJarRowAmazingTip
};


@interface TipJarViewControllerTableViewController () <Invalidatable>

@property (nonatomic) Binder *productManagerBinder;
@property (nonatomic) PropertyInvalidator *invalidator;

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
    
    __weak typeof(self) weakSelf = self;
    self.productManagerBinder = [[Binder alloc] initWithObject:self.productManager
                                                      keyPaths:@[K(initializing),K(purchaseInProgress),K(availableProducts)]
                                                      callback:^{
                                                          [weakSelf.invalidator invalidateProperties];
                                                      }];
    self.invalidator = [[PropertyInvalidator alloc] initWithHostObject:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.productManagerBinder startObserving];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.productManagerBinder stopObserving];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productManager.availableProducts.count;
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
    
    SKProduct *product = self.productManager.availableProducts[indexPath.row];
    res.textLabel.text = product.localizedTitle;
    res.detailTextLabel.text = [NSString stringWithFormat:@"$%@",product.price.stringValue];
    
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
    SKProduct *product = self.productManager.availableProducts[indexPath.row];
    [[NSNotificationCenter defaultCenter] postNotificationName:ProductManagerPurchaseProductNotification object:product];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 120;
}

#pragma mark - Invalidatable implementation
- (void)commitProperties
{
    if (self.productManager.initializing || self.productManager.purchaseInProgress)
    {
        [LargeProgressView show];
    }
    else
    {
        [LargeProgressView hide];
    }
    
    [self.tableView reloadData];
}

#pragma mark - event handlers
- (void)handleCancelButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

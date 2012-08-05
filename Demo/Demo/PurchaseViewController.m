//
//  PurchaseViewController.m
//  Demo
//
//  Created by Maurizio Cremaschi on 8/2/12.
//  Copyright (c) 2012 Flubber Media Ltd. All rights reserved.
//

#import "PurchaseViewController.h"
#import "FMPurchaseManager.h"
#import "SKProduct+FormattedPrice.h"

@interface PurchaseViewController ()

@property (strong, nonatomic) NSArray *datasource;

@end

@implementation PurchaseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSArray *products = @[
    //Replace this with your real products
    //@"com.flubbermedia.product1",
    //@"com.flubbermedia.product2",
    //@"com.flubbermedia.product3"
    ];
    
    [FMPurchaseManager setProductRequestCompletion:^(NSArray *products, NSArray *invalidProductIdentifiers) {
        NSLog(@"didReceiveProducts valid(%d) invalid(%d)", products.count, invalidProductIdentifiers.count);
        _datasource = products;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    
    [FMPurchaseManager setProductPurchaseCompletion:^(SKPaymentTransaction *transaction, NSError *error) {
        if (error == nil)
        {
            NSLog(@"Purchase completed: %@", transaction.payment.productIdentifier);
        }
        else
        {
            NSLog(@"Purchase failed: %@ [%@]", transaction.payment.productIdentifier, error);
        }
    }];
    
    [FMPurchaseManager setProductRestoreCompletion:^(SKPaymentTransaction *transaction, NSString *productIdentifier) {
        NSLog(@"Product restored: %@", productIdentifier);
    }];
    
    [FMPurchaseManager requestProducts:products];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table View

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _datasource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ProductCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    SKProduct *product = [_datasource objectAtIndex:indexPath.row];
    
    cell.textLabel.text = [product localizedTitle];
    cell.detailTextLabel.text = [product formattedPrice];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKProduct *product = [_datasource objectAtIndex:indexPath.row];    
    [FMPurchaseManager buyProduct:product.productIdentifier];
}

#pragma mark - Actions

- (IBAction)restorePurchases:(id)sender
{
    [FMPurchaseManager restorePurchases];
}

@end

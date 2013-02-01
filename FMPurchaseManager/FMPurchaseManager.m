//
//  FMPurchaseManager.m
//
//  Created by Maurizio Cremaschi and Andrea Ottolina on 8/2/12.
//  Copyright 2012 Flubber Media Ltd.
//
//  Distributed under the permissive zlib License
//  Get the latest version from https://github.com/flubbermedia/FMPurchaseManager
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "FMPurchaseManager.h"

@interface FMPurchaseManager ()

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) NSArray *productIdentifiers;
@property (copy, nonatomic) ProductRequestCompletion productRequestCompletion;
@property (copy, nonatomic) ProductPurchaseCompletion productPurchaseCompletion;
@property (copy, nonatomic) ProductRestoreCompletion productRestoreCompletion;

@end

@implementation FMPurchaseManager

+ (FMPurchaseManager *)sharedInstance
{
    static FMPurchaseManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [FMPurchaseManager new];
    });
    return sharedInstance;
}

#pragma mark - Class methods

+ (void)setProductRequestCompletion:(ProductRequestCompletion)productRequestCompletion
{
    [[FMPurchaseManager sharedInstance] setProductRequestCompletion:productRequestCompletion];
}

+ (void)setProductPurchaseCompletion:(ProductPurchaseCompletion)productPurchaseCompletion
{
    [[FMPurchaseManager sharedInstance] setProductPurchaseCompletion:productPurchaseCompletion];
}

+ (void)setProductRestoreCompletion:(ProductRestoreCompletion)productRestoreCompletion
{
    [[FMPurchaseManager sharedInstance] setProductRestoreCompletion:productRestoreCompletion];
}

+ (void)requestProducts:(NSArray *)identifiers
{
    [[FMPurchaseManager sharedInstance] requestProducts:identifiers];
}

+ (void)buyProduct:(NSString *)identifier
{
    [[FMPurchaseManager sharedInstance] buyProduct:identifier];
}

+ (void)restorePurchases
{
    [[FMPurchaseManager sharedInstance] restorePurchases];
}

#pragma mark - Instance methods

- (void)requestProducts:(NSArray *)identifiers
{
    if (identifiers && [SKPaymentQueue canMakePayments])
    {
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        SKProductsRequest *request= [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithArray:identifiers]];
        request.delegate = self;
        [request start];
    }
    else
    {
        if (_productRequestCompletion)
		{
			_productRequestCompletion(nil, nil);
		}
	}
}

- (void)buyProduct:(NSString *)identifier
{
    if (identifier)
    {
        SKProduct *selectedProduct = [self productWithIdentifier:identifier];
        SKPayment *payment = [SKPayment paymentWithProduct:selectedProduct];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restorePurchases
{
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

#pragma mark - StoreKit

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.products = response.products;
	if (_productRequestCompletion)
	{
		_productRequestCompletion(response.products, response.invalidProductIdentifiers);
	}
}


/*******

 NOTE: Sometimes this method doesn't get called by [SKPaymentQueue restoreCompletedTransactions]; with some test users
 Carefull when testing!

*******/
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
	//NSLog(@"paymentQueue updateTransactions | transactions: %d", [queue.transactions count]);
	for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchasing:
                break;
            case SKPaymentTransactionStatePurchased:
				if (_productPurchaseCompletion)
				{
					_productPurchaseCompletion(transaction, transaction.payment.productIdentifier, nil);
				}
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
				if (_productPurchaseCompletion)
				{
					_productPurchaseCompletion(transaction, transaction.payment.productIdentifier, transaction.error);
				}
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored:
				if (_productPurchaseCompletion)
				{
					_productPurchaseCompletion(transaction, transaction.originalTransaction.payment.productIdentifier, nil);
				}
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
				break;
            default:
                break;
        }
    }
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
	//NSLog(@"paymentQueue restoreFailed | transactions: %d", [queue.transactions count]);
	if (_productRestoreCompletion)
	{
		_productRestoreCompletion(error);	
	}
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
	//NSLog(@"paymentQueue restoreCompleted | transactions: %d", [queue.transactions count]);
	if (_productRestoreCompletion)
	{
		NSError *error = nil;
		if ([queue.transactions count] == 0)
		{
			NSMutableDictionary *errorDetail = [NSMutableDictionary dictionary];
			[errorDetail setValue:@"No available In-App purchases to restore" forKey:NSLocalizedDescriptionKey];
			error = [NSError errorWithDomain:SKErrorDomain code:SKErrorClientInvalid userInfo:errorDetail];
		}
		_productRestoreCompletion(error);
	}
}

#pragma mark - Utilities

- (SKProduct *)productWithIdentifier:(NSString *)identifier
{
    for (SKProduct *product in _products)
    {
        if ([product.productIdentifier isEqualToString:identifier])
        {
            return product;
        }
    }
    return nil;
}

@end

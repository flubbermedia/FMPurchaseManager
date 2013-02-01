//
//  FMPurchaseManager.h
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

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

typedef void (^ProductRequestCompletion)(NSArray *products, NSArray *invalidProductIdentifiers);
typedef void (^ProductPurchaseCompletion)(SKPaymentTransaction *transaction, NSString *productIdentifier, NSError *error);
typedef void (^ProductRestoreCompletion)(NSError *error);

@interface FMPurchaseManager : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

+ (void)setProductRequestCompletion:(ProductRequestCompletion)productRequestCompletion;
+ (void)setProductPurchaseCompletion:(ProductPurchaseCompletion)productPurchaseCompletion;
+ (void)setProductRestoreCompletion:(ProductRestoreCompletion)productRestoreCompletion;

+ (void)requestProducts:(NSArray *)identifiers;
+ (void)buyProduct:(NSString *)identifier;
+ (void)restorePurchases;

@end
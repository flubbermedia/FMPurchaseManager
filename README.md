Purpose
-------
FMPurchaseManager is a wrapper on the StoreKit framework that makes the whole purchase process easier.

**NOTE: the supported build target is iOS 5.1 (Xcode 4.4)*

Installation
------------
Add the `<StoreKit/StoreKit.h>` framework and drag the FMPurchaseManager class files into your project.

Usage
-----
(see sample Xcode project `/Demo`)

First of all you must setup the two blocks that are called during the purchase process.

1. Handle the product request completion

	```objectivec
	[FMPurchaseManager setProductRequestCompletion:
	^(NSArray *products, NSArray *invalidProductIdentifiers) {
		//you receive an array of SKProduct objects
		//and a list of invalid product identifiers
	}];
	```

2. Handle the purchase completion

	```objectivec
	[FMPurchaseManager setProductPurchaseCompletion:
	^(SKPaymentTransaction *transaction, NSString *productIdentifier, NSError *error) {
		if (error == nil)
		{
			//the purchase has completed, do whatever you want with the transaction
		}
		else
		{
			//something went wrong with your purchase or the user cancelled it
		}
	}];
	```
	
Once you prepared the completion blocks you can:

* request the products with the related identifiers `[FMPurchaseManager requestProducts:someProducts]`
* buy a product with its identifier `[FMPurchaseManager buyProduct:anIdentifier]`
* restore the previously purchased products `[FMPurchaseManager restorePurchases]`

Credits
-------
FMFacebookPanel was created by [Maurizio Cremaschi](http://cremaschi.me) and [Andrea Ottolina](http://andreaottolina.com) for [Flubber Media Ltd](http://flubbermedia.com).
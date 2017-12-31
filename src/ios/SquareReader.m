/*
 * PhoneGap is available under *either* the terms of the modified BSD license *or* the
 * MIT License (2008). See http://opensource.org/licenses/alphabetical for full text.
 *
 * Copyright 2011 Matt Kane. All rights reserved.
 * Copyright (c) 2011, IBM Corporation
 */

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

//------------------------------------------------------------------------------
// use the all-in-one version of zxing that we built
//------------------------------------------------------------------------------
#import <Cordova/CDVPlugin.h>

#import "SquareApp.h"

@import SquarePointOfSaleSDK;

//------------------------------------------------------------------------------
// Delegate to handle orientation functions
//------------------------------------------------------------------------------
/*@protocol CDVBarcodeScannerOrientationDelegate <NSObject>

- (NSUInteger)supportedInterfaceOrientations;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)shouldAutorotate;

@end
*/

//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// plugin class
//------------------------------------------------------------------------------
@interface SquareReader : CDVPlugin {}
- (void)charge:(CDVInvokedUrlCommand*)command;
- (void)returnSuccess:(NSString*)transactioId callback:(NSString*)callback;
- (void)returnError:(NSString*)message callback:(NSString*)callback;
@end


@implementation SquareReader




- (void)charge:(CDVInvokedUrlCommand*)command 
{
    NSString*       callback;

    callback = command.callbackId;
    NSDictionary* options;
    if (command.arguments.count == 0) {
      options = [NSDictionary dictionary];
    } else {
      options = command.arguments[0];
    }

    NSString *appId = options[@"applicationID"];
    NSString *amountString = options[@"amount"];
    NSString *currencyCodeString = options[@"currency"];
    NSString *notes = options[@"notes"];
    NSString *locationID = options[@"locationID"];
    NSString *customerID = options[@"customerID"];
    NSString *userInfoString = options[@"userInfo"];
    NSString *callbackString = options[@"callbackURL"];
    BOOL giftcard = ([options[@"giftcard"] compare:@"1"] == 0);

    [SCCAPIRequest setClientID:appId];
    SCCAPIRequestTenderTypes tender = SCCAPIRequestTenderTypeCard;
    if (giftcard)
        tender |= SCCAPIRequestTenderTypeSquareGiftCard;


    NSError *error = nil;
    SCCMoney *amount = [SCCMoney moneyWithAmountCents:amountString.integerValue currencyCode:currencyCodeString error:&error];
    if (error) {
        //[self _showErrorMessageWithTitle:@"Invalid Amount" error:error];
        [self returnError:error.localizedDescription callback:callback];
        return;
    }
    
    SquareApp *app = (SquareApp *)[[UIApplication sharedApplication] delegate];
    app.commandDelegate = self.commandDelegate;
    app.callback = callback; 

    SCCAPIRequest *request = [SCCAPIRequest requestWithCallbackURL:[NSURL URLWithString:callbackString]
                                                            amount:amount
                                                    userInfoString:userInfoString
                                                        locationID:locationID
                                                             notes:notes
                                                        customerID:customerID
                                              supportedTenderTypes:tender
                                                 clearsDefaultFees:YES // self.clearsDefaultFees
                                   returnAutomaticallyAfterPayment:YES //self.returnAutomaticallyAfterPayment
                                                             error:&error];
    
    if (error) {
        [self returnError:error.localizedDescription callback:callback];
        return;
    }
    
    if (![SCCAPIConnection performRequest:request error:&error]) {
        [self returnError:error.localizedDescription callback:callback];
    }
}


//--------------------------------------------------------------------------
- (void)returnSuccess:(NSString*)transactionId callback:(NSString*)callback {
    NSMutableDictionary* resultDict = [[NSMutableDictionary new] autorelease];
    resultDict[@"transactionId"] = transactionId;

    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
    [self.commandDelegate sendPluginResult:result callbackId:callback];
}

//--------------------------------------------------------------------------
- (void)returnError:(NSString*)message callback:(NSString*)callback {
    CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsString: message
                               ];

    [self.commandDelegate sendPluginResult:result callbackId:callback];
}


@end 




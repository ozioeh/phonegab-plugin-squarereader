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
- (void)pluginInitialize;
- (void)charge:(CDVInvokedUrlCommand*)command;
- (void)returnSuccess:(NSString*)transactioId callback:(NSString*)callback;
- (void)returnError:(NSString*)message callback:(NSString*)callback;
@end


@implementation SquareReader




NSString * yourApplicationID;
// Replace with your app's callback URL as set in the Square Application Dashboard [https://connect.squareup.com/apps].
// You must also declare this URL scheme in HelloCharge-Info.plist, under URL types.
NSString * yourCallbackURLString;


- (void) pluginInitialize {

    NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Values" ofType:@"plist"]];
    //NSLog(@"dictionary = %@", dictionary);
    yourApplicationID = [dictionary objectForKey:@"SquareApplicationID"];
    yourCallbackURLString = [dictionary objectForKey:@"CallbackURL"];
    
}



- (void)charge:(CDVInvokedUrlCommand*)command 
{
    NSString*       callback;


    [SCCAPIRequest setClientID:yourApplicationID];

 
    callback = command.callbackId;
    NSDictionary* options;
    if (command.arguments.count == 0) {
      options = [NSDictionary dictionary];
    } else {
      options = command.arguments[0];
    }

    NSString *amountString = [options[@"amount"] stringValue];
    NSString *currencyCodeString = [options[@"currency"] stringValue];
    NSString *notes = [options[@"notes"] stringValue];
    NSString *locationID = [options[@"locationID"] stringValue];
    NSString *customerID = [options[@"customerID"] stringValue];
    NSString *userInfoString = [options[@"userInfo"] stringValue];
    BOOL giftcard = [options[@"giftcard"] boolValue];

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

    SCCAPIRequest *request = [SCCAPIRequest requestWithCallbackURL:[NSURL URLWithString:yourCallbackURLString]
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




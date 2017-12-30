
#import "SquareApp.h"

@import SquarePointOfSaleSDK;


@implementation SquareApp


- (BOOL)application:(UIApplication*)application openURL:(NSURL*)url sourceApplication:(NSString*)sourceApplication annotation:(id)annotation
{
    // Make sure the URL comes from Square Register; fail if it doesn't.
    if (![sourceApplication hasPrefix:@"com.squareup.square"]) {
        return NO;
    }
    
    // The response data is encoded in the URL and can be decoded as an SCCAPIResponse.
    NSError *decodeError = nil;
    SCCAPIResponse *const response = [SCCAPIResponse responseWithResponseURL:url error:&decodeError];
    
    NSString *message = nil;
 
    NSMutableDictionary* resultDict = [NSMutableDictionary new];
    
    // Process the response as desired.
    if (response.isSuccessResponse && !decodeError) {
        resultDict[@"transactionId"] = response.transactionID;
        CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_OK
                               messageAsDictionary: resultDict
                               ];
        [self.commandDelegate sendPluginResult:result callbackId:self.callback];
    }
    else {
        // An invalid response message error is distinct from a successfully decoded error.
        NSError *const errorToPresent = response ? response.error : decodeError;
        message = [NSString stringWithFormat:@"Request failed: %@", [errorToPresent localizedDescription]];
        CDVPluginResult* result = [CDVPluginResult
                               resultWithStatus: CDVCommandStatus_ERROR
                               messageAsString: message
                               ];
        [self.commandDelegate sendPluginResult:result callbackId:self.callback];

    }
    
    return YES;
}


@end


#import "SquareApp.h"

@import SquarePointOfSaleSDK;


@implementation SquareApp




- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options;
{
    NSString *const sourceApplication = options[UIApplicationOpenURLOptionsSourceApplicationKey];
    // Make sure the URL comes from Square Register; fail if it doesn't.
    if (![sourceApplication hasPrefix:@"com.squareup.square"]) {
        return NO;
    }
    
    // The response data is encoded in the URL and can be decoded as an SCCAPIResponse.
    NSError *decodeError = nil;
    SCCAPIResponse *const response = [SCCAPIResponse responseWithResponseURL:url error:&decodeError];
    
    NSString *message = nil;
    NSString *title = nil;

    NSMutableDictionary* resultDict = [[NSMutableDictionary new] autorelease];
    
    // Process the response as desired.
    if (response.isSuccessResponse && !decodeError) {
        resultDict[@"transactionId"] = response.transactionId;
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

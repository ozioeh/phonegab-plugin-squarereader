#import "AppDelegate.h"

/**
 *  Category for the AppDelegate that overrides application:continueUserActivity:restorationHandler method,
 *  so we could handle application launch when user clicks on the link in the browser.
 */
@interface  SquareApp : AppDelegate 

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation;


@property (nonatomic, weak) id <CDVCommandDelegate> commandDelegate;
@property (nonatomic) NSString *callback; 



@end

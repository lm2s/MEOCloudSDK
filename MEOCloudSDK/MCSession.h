//
//  MEOCSession.h
//  MEOCloudApp
//
//  Created by Luís Silva on 24/01/15.
//
//

#import <Foundation/Foundation.h>
#import "NSString+Utils.h"
#import <AFNetworking/AFNetworking.h>
#import <BDBOAuth1Manager/BDBOAuth1SessionManager.h>
#import <BDBOAuth1Manager/NSDictionary+BDBOAuth1Manager.h>

@interface MCSession : NSObject

@property (nonatomic, readonly) BDBOAuth1SessionManager *networkManager;
@property (nonatomic, readonly) BOOL isLinked;


+ (MCSession*)sharedSession;
@property (NS_NONATOMIC_IOSONLY, getter=isAuthorized, readonly) BOOL authorized;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL logout;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) BDBOAuth1SessionManager *newNetworkManager;
@property (NS_NONATOMIC_IOSONLY, readonly) NSError* authorizationError;
- (void)initWithKey:(NSString*)consumerKey secret:(NSString*)consumerSecret callbackUrl:(NSString*)callbackUrl;
- (void)linkFromController:(id)sender;
- (BOOL)handleAuthorizationCallbackURL:(NSURL*)url;

@end

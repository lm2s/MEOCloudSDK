//
//  MEOCSession.m
//  MEOCloudApp
//
//  Created by Luís Silva on 24/01/15.
//
//

#import "MCSession.h"


@interface MCSession()
@property (nonatomic, strong) BDBOAuth1SessionManager* networkManager;

@property (nonatomic, strong) NSString *consumerKey;
@property (nonatomic, strong) NSString *consumerSecret;
@property (nonatomic, strong) NSString *callbackUrl;
@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic, strong) NSNumber* accountAuthorized;
@end

@implementation MCSession

+ (MCSession*)sharedSession {
    static MCSession *sharedMCSession = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMCSession = [[self alloc] init];
        [sharedMCSession commonInit];
        
    });
    return sharedMCSession;
}

- (void)commonInit {

}

- (void)monitorReachability {
    NSOperationQueue *operationQueue = self.networkManager.operationQueue;
    [self.networkManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                [operationQueue setSuspended:NO];
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                [operationQueue setSuspended:YES];
                break;
        }
    }];
    
    [self.networkManager.reachabilityManager startMonitoring];
}

- (BOOL)logout {
    BOOL wasDeauthorized = _networkManager.deauthorize;
    self.accountAuthorized = @(!wasDeauthorized);

    return wasDeauthorized;
}

- (BOOL)isAuthorized {
    return _networkManager.isAuthorized;
}

- (void)initWithKey:(NSString*)consumerKey secret:(NSString*)consumerSecret callbackUrl:(NSString*)callbackUrl {
    
    NSURL *baseURL = [NSURL URLWithString:@"https://meocloud.pt/"];
    _baseUrl = baseURL;
    
    _consumerKey = consumerKey;
    _consumerSecret = consumerSecret;
    _callbackUrl = callbackUrl;
    
    _networkManager = [[BDBOAuth1SessionManager alloc] initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
    if(self.networkManager.isAuthorized) {
        [self setValue:@(YES) forKey:@"accountAuthorized"];
        [self monitorReachability];
    }
}

- (BDBOAuth1SessionManager*)newNetworkManager {
    return [[BDBOAuth1SessionManager alloc] initWithBaseURL:_baseUrl consumerKey:_consumerKey consumerSecret:_consumerSecret];
}

- (void)linkFromController:(id)sender {
    [_networkManager fetchRequestTokenWithPath:@"/oauth/request_token"
                                        method:@"POST"
                                   callbackURL:[NSURL URLWithString:_callbackUrl]
                                         scope:nil
                                       success:^(BDBOAuth1Credential *requestToken) {
                                           NSString *authURL = [NSString stringWithFormat:@"https://meocloud.pt/oauth/authorize?oauth_token=%@", requestToken.token];
                                           [[UIApplication sharedApplication] openURL:[NSURL URLWithString:authURL]];
                                       }
                                       failure:^(NSError *error) {
                                           NSLog(@"linkFromController Error: %@", error.localizedDescription);
                                       }];
}

- (BOOL)handleAuthorizationCallbackURL:(NSURL*)url {
    BOOL validScheme = NO;
    NSDictionary *parameters = [NSDictionary bdb_dictionaryFromQueryString:url.absoluteString];
    if (parameters[@"oauth_token"] && parameters[@"minhanuvem://success?oauth_verifier"]) {
        validScheme = YES;
        [_networkManager fetchAccessTokenWithPath:@"/oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]
                                          success:^(BDBOAuth1Credential *accessToken) {
                                              [_networkManager.requestSerializer saveAccessToken:accessToken];
                                              [self setValue:@(YES) forKey:@"accountAuthorized"];
                                              [self monitorReachability];
//                                              NSLog(@"fetchAccessTokenWithPath SUCCESS: %@", accessToken);
                                          }
                                          failure:^(NSError *error) {
                                              [self setValue:@(NO) forKey:@"accountAuthorized"];
                                              [self setValue:error forKey:@"authorizationError"];
                                              NSLog(@"handleAuthorizationCallbackURL Error: %@", error.localizedDescription);
                                          }];
    }
    
    return validScheme;
}

@end

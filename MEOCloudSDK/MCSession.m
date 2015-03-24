// MCSession.h
//
// Copyright (c) 2015 Luís M. Marques Silva
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

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
static MCSession *sharedSession = nil;

+ (MCSession*)sharedSession {
//    static MCSession *sharedSession = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sharedSession = [[self alloc] init];
//        [sharedSession commonInit];
//        
//    });
    return sharedSession;
}

- (void)setSharedSession:(MCSession*)session {
    sharedSession = session;
}

- (instancetype)initWithKey:(NSString*)consumerKey secret:(NSString*)consumerSecret urlScheme:(NSString*)urlScheme sandbox:(BOOL)sandbox {
    self = [super init];
    if (self) {
        NSURL *baseURL = [NSURL URLWithString:@"https://meocloud.pt/"];
        _baseUrl = baseURL;
        
        _consumerKey = consumerKey;
        _consumerSecret = consumerSecret;
        _callbackUrl = urlScheme;
        _isSandbox = sandbox;
        
        _networkManager = [[BDBOAuth1SessionManager alloc] initWithBaseURL:baseURL consumerKey:consumerKey consumerSecret:consumerSecret];
        if(self.networkManager.isAuthorized) {
            [self setValue:@(YES) forKey:@"accountAuthorized"];
            [self monitorReachability];
        }
    }
    return self;
}

- (void)commonInit {

}

- (void)monitorReachability {
    NSOperationQueue *operationQueue = self.networkManager.operationQueue;
    [self.networkManager.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//        NSLog(@"Reachability: %@", AFStringFromNetworkReachabilityStatus(status));
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

//- (BDBOAuth1SessionManager*)cloneNetworkManager {
//    return [[BDBOAuth1SessionManager alloc] initWithBaseURL:_baseUrl consumerKey:_consumerKey consumerSecret:_consumerSecret];
//}

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
    NSString* urlParam = [NSString stringWithFormat:@"%@://success?oauth_verifier", _callbackUrl];
    if (parameters[@"oauth_token"] && parameters[urlParam]) {
        validScheme = YES;
        [_networkManager fetchAccessTokenWithPath:@"/oauth/access_token" method:@"POST" requestToken:[BDBOAuth1Credential credentialWithQueryString:url.query]
                                          success:^(BDBOAuth1Credential *accessToken) {
                                              [_networkManager.requestSerializer saveAccessToken:accessToken];
                                              [self setValue:@(YES) forKey:@"accountAuthorized"];
                                              [self monitorReachability];
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

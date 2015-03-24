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

#import <Foundation/Foundation.h>
#import "NSString+Utils.h"
#import <AFNetworking/AFNetworking.h>
#import <BDBOAuth1Manager/BDBOAuth1SessionManager.h>
#import <BDBOAuth1Manager/NSDictionary+BDBOAuth1Manager.h>


/**
 * `MCSession` represents an user session. The authorization and authentication of a
 * user to the MEOCloud and subsequent application authorization token retrieval is handled
 * by this class.
 */
@interface MCSession : NSObject

@property (NS_NONATOMIC_IOSONLY, readonly) BDBOAuth1SessionManager *networkManager;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL isLinked;
@property (NS_NONATOMIC_IOSONLY, getter=isAuthorized, readonly) BOOL authorized;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL logout;
@property (NS_NONATOMIC_IOSONLY, readonly) NSError* authorizationError;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL isSandbox;

/**
 *  A `MCSession` shared instance.
 *
 *  Usually this is the session that will be used through out the application. Think of it as 
 *  a singleton.
 *
 *  @return The `MCSession` shared instance.
 */
+ (MCSession*)sharedSession;

/**
 *  Setter for the instance of `MCSession` to be shared.
 *
 *  @param session An `MCSession` instance.
 */
- (void)setSharedSession:(MCSession*)session;

/**
 *  Initializes a `MCSession` instance.
 *
 *  If used with the `sharedSession` method, the singleton instance will be initialized with
 *  the credentials used in this method.
 *
 *  @param consumerKey      The MEOCloud application key.
 *  @param consumerSecret   The MEOCloud application secret.
 *  @param urlScheme        A string containing the URL scheme for the application to be called
 *                          upon successful user authentication in the browser.
 */
- (instancetype)initWithKey:(NSString*)consumerKey
                     secret:(NSString*)consumerSecret
                  urlScheme:(NSString*)urlScheme
                    sandbox:(BOOL)sandbox NS_DESIGNATED_INITIALIZER;

/**
 *  Requests the authentication of a user and application authorization.
 *
 *  @param sender   The view controller from which this method is called.
 */
- (void)linkFromController:(id)sender;

/**
 *  Handles the browser callback to the application to finish the authorization process.
 *  This method should be called from within `application:openURL:sourceApplication:annotation` in
 *  the application delegate.
 *
 *  @param url The URL argument of the above method.
 *
 *  @return `YES` if the URL scheme is valid, otherwise `NO`.
 */
- (BOOL)handleAuthorizationCallbackURL:(NSURL*)url;

@end

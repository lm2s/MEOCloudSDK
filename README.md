# MEOCloudSDK

MEOCloud SDK is a library for iOS (and soon OS X) that makes it easy to use the [MEOCloud](https://meocloud.pt) services.

## Installation 

Using CocoaPods:

```ruby
platform :ios, '7.0'
pod "MEOCloudSDK", "~> 0.1.0"
```

## Usage

### Session

Register your application URL scheme in the Xcode project settings ([Tutorial](https://dev.twitter.com/cards/mobile/url-schemes)).

Then on your application delegate (e.g.: AppDelegate.m) implement the following:

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // (...)
    NSString *kClientID = @"YOUR_CONSUMER_KEY";
    NSString *kClientSecret = @"YOUR_SECRET";
    NSString *kUrlScheme = @"YOUR_URL_SCHEME://success";

    MCSession* session = [[MCSession alloc] initWithKey:kClientID secret:kClientSecret urlScheme:kUrlScheme sandbox:NO];
    session.sharedSession = session;
    // (...)
}
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [[MCSession sharedSession] handleAuthorizationCallbackURL:url];
}
```

### Client

You are now ready to use the SDK. Try to get all the metadata at the root:

```objective-c
MCClient* cloudClient = [[MCClient alloc] initWithSession:[MCSession sharedSession]];
[cloudClient metadataAtPath:@"/" success:^(NSArray *metadata) {
    for (MCMetadata* m in metadata) {
            NSLog(@"%@ - %@", m.path, m.size);
    }
 } failure:^(NSError *error) {
        NSLog(@"ERROR: %@", error);
 }];
```

### More

See the documentation for all the available methods.

## Contact

Follow me on Twitter ([@_lm2s](https://twitter.com/_lm2s))

## License

MEOCloud SDK for iOS is available under the MIT License. See the LICENSE file for more info.

MEO is a registered trademark of *MEO - Serviços de Comunicações e Multimédia, S.A.*
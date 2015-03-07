//
//  MEOCloudAccount.m
//  MEOCloudApp
//
//  Created by Luís Silva on 04/02/15.
//
//

#import "MCAccount.h"

@implementation MCAccount
- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.name = dictionary[@"display_name"];
        self.identifier = dictionary[@"uid"];
        self.lastEvent = dictionary[@"last_event"];
        self.quotaShared = [dictionary[@"quota_info"][@"shared"] unsignedLongLongValue];
        self.quota = [dictionary[@"quota_info"][@"quota"] unsignedLongLongValue];
        self.quotaNormal = [dictionary[@"quota_info"][@"normal"] unsignedLongLongValue];
        self.isActive = [dictionary[@"active"] boolValue];
        self.email = dictionary[@"email"];
        self.language = dictionary[@"language"];
    }
    return self;
}
@end

//
//  MEOCloudSharedFolder.m
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import "MCShare.h"
#import "MCUser.h"

@implementation MCShare

- (instancetype)initWithIdentifier:(NSString*)identifier dictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.identifier = identifier;
        self.isOwner = [dictionary[@"owner"] boolValue];
        self.path = dictionary[@"shared_folder_path"];
        self.type = dictionary[@"folder_type"];
        
        NSMutableArray* users = [NSMutableArray new];
        for (NSDictionary* dict in dictionary[@"users"]) {
            MCUser* user = [[MCUser alloc] initWithDictionary:dict];
            [users addObject:user];
        }
        self.users = [NSArray arrayWithArray:users];
    }
    return self;
}
@end

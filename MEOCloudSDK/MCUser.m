//
//  MEOCloudUser.m
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import "MCUser.h"

/*
"users":[
         {
             "id":"d6aef5c8-9594-4e4a-ae85-7405cd8a4ee8",
             "owner":true,
             "user":true,
             "name":"Luci Gel"
         },
         {
             "id":"e328c1e9-149c-4065-815e-274de86c5f32",
             "name":"Zé das couves"
         }
         ],
*/

@implementation MCUser
- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        if (dictionary[@"owner"]) {
            self.isOwner = [dictionary[@"owner"] boolValue];
        }
        if (dictionary[@"user"]) {
            self.isUser = [dictionary[@"user"] boolValue];
        }
        
        self.identifier = dictionary[@"id"];
        self.name = dictionary[@"name"];
        self.email = dictionary[@"email"];
    }
    return self;
}
@end

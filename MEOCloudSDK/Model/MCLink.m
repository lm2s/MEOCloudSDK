//
//  MEOCloudLink.m
//  MEOCloudApp
//
//  Created by Luís Silva on 05/02/15.
//
//

#import "MCLink.h"
#import "NSDate+Utils.h"

//"url": "https://meocloud.pt/link/94db8df0-02e9-43b5-b42d-93139a918853/2.jpeg",
//"absolute_path": "/whole/path/to/file/2.jpeg",
//"path": "/2.jpeg",
//"shareid": "94db8df0-02e9-43b5-b42d-93139a918853",
//"expires": "Tue, 01 Jan 2030 00:00:00 +0000",
//"metadata": {
//    "bytes": 164727,
//    "thumb_exists": true,
//    "rev": "6ad7fe0f-2e8a-11e2-b5e0-3c0754179fed",
//    "modified": "Thu, 20 Sep 2012 14:30:05 +0000",
//    "path": "/2.jpeg",
//    "is_dir": false,
//    "icon": "image_jpg",
//    "root": "meocloud",
//    "mime_type": "image/jpeg",
//    "size": "160 KB"
//}
@implementation MCLink
- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.url = dictionary[@"url"];
        self.path = dictionary[@"absolute_path"];
        self.relativePath = dictionary[@"path"];
        self.shareIdentifier = dictionary[@"shareid"];
        
        // Tue, 01 Jan 2030 00:00:00 +0000
        self.expirationDate = [NSDate dateFromString:dictionary[@"expires"] pattern:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        self.metadata = [[MCMetadata alloc] initWithDictionary:dictionary[@"metadata"]];
    }
    return self;
}
@end

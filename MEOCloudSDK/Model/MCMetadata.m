//
//  MEOCFile.m
//  MEOCloudApp
//
//  Created by Luís Silva on 24/01/15.
//
//

#import "MCMetadata.h"
#import "NSString+Utils.h"
#import "NSDate+Utils.h"

@implementation MCMetadata

- (instancetype)initWithDictionary:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.bytes = @([dictionary[@"bytes"] unsignedLongLongValue]);
        self.isDirectory = [dictionary[@"is_dir"] boolValue];
        self.isOwner = [dictionary[@"is_owner"] boolValue];
        self.modified = [NSDate dateFromString:dictionary[@"modified"] pattern:@"EEE, dd MMM yyyy HH:mm:ss Z"];
        //        self.modified = [[item objectForKey:@"modified"] date];
        self.size = dictionary[@"size"];
        self.icon = dictionary[@"icon"];
        self.root = dictionary[@"root"];
        self.path = dictionary[@"path"];
        self.hasThumbnail = [dictionary[@"thumb_exists"] boolValue];
        self.filename = [self.path lastPathComponent];
        
        if (!self.isDirectory) {
            self.mimeType = dictionary[@"mime_type"];
            self.uniqueIdentifier = [self.path MD5Digest];
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder // NSCoding deserialization
{
    if ((self = [self init])) {
        _bytes 		 	= [decoder decodeObjectForKey:@"bytes"];
        _uniqueIdentifier = [decoder decodeObjectForKey:@"filehash"];
        _isDirectory 	= [decoder decodeBoolForKey:@"isDirectory"];
        _isOwner 		= [decoder decodeBoolForKey:@"isOwner"];
        _modified 		= [decoder decodeObjectForKey:@"modified"];
        _path 			= [decoder decodeObjectForKey:@"path"];
        _filename 		= [decoder decodeObjectForKey:@"filename"];
        _revision 		= [decoder decodeObjectForKey:@"revision"];
        _root 			= [decoder decodeObjectForKey:@"root"];
        _size 			= [decoder decodeObjectForKey:@"size"];
        _mimeType 		= [decoder decodeObjectForKey:@"mimeType"];
        _icon 			= [decoder decodeObjectForKey:@"icon"];
        _hasThumbnail 	= [decoder decodeBoolForKey:@"thumbExists"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder // NSCoding serialization
{
    [encoder encodeObject: _bytes forKey:@"bytes"];
    [encoder encodeObject:_uniqueIdentifier forKey:@"filehash"];
    [encoder encodeBool:_isDirectory forKey:@"isDirectory"];
    [encoder encodeBool:_isOwner forKey:@"isOwner"];
    [encoder encodeObject:_modified forKey:@"modified"];
    [encoder encodeObject:_path forKey:@"path"];
    [encoder encodeObject:_filename forKey:@"filename"];
    [encoder encodeObject:_revision forKey:@"revision"];
    [encoder encodeObject:_root forKey:@"root"];
    [encoder encodeObject:_size forKey:@"size"];
    [encoder encodeObject: _mimeType forKey:@"mimeType"];
    [encoder encodeObject: _icon forKey:@"icon"];
    [encoder encodeBool:_hasThumbnail forKey:@"thumbExists"];
}
@end

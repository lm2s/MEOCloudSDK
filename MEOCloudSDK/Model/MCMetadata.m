// MCMetadata.h
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

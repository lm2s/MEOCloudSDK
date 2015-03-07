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

#import <Foundation/Foundation.h>

@interface MCMetadata : NSObject<NSCoding>
@property (NS_NONATOMIC_IOSONLY, strong) NSNumber* bytes;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* uniqueIdentifier;
@property (NS_NONATOMIC_IOSONLY, assign) BOOL isDirectory;
@property (NS_NONATOMIC_IOSONLY, assign) BOOL isOwner;
@property (NS_NONATOMIC_IOSONLY, strong) NSDate* modified;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* path;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* filename;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* revision;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* root;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* size;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* mimeType;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* icon;
@property (NS_NONATOMIC_IOSONLY, assign) BOOL hasThumbnail;

- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;
@end

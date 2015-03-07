// MCLink.h
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
#import "MCMetadata.h"

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

@interface MCLink : NSObject
@property (NS_NONATOMIC_IOSONLY, strong) NSString* url;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* path;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* relativePath;
@property (NS_NONATOMIC_IOSONLY, strong) NSString* shareIdentifier;
@property (NS_NONATOMIC_IOSONLY, strong) NSDate* expirationDate;
@property (NS_NONATOMIC_IOSONLY, strong) MCMetadata* metadata;
- (instancetype)initWithDictionary:(NSDictionary*)dictionary NS_DESIGNATED_INITIALIZER;
@end
